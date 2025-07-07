import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:genchatapp/app/config/services/connectivity_service.dart';
import 'package:genchatapp/app/config/services/firebase_controller.dart';
import 'package:genchatapp/app/config/services/notification_service.dart';
import 'package:genchatapp/app/config/services/socket_service.dart';
import 'package:genchatapp/app/data/repositories/group/group_repository.dart';
import 'package:genchatapp/app/modules/call/controllers/call_controller.dart';
import 'package:genchatapp/app/modules/chats/controllers/chats_controller.dart';
import 'package:genchatapp/app/modules/select_contacts/controllers/select_contacts_controller.dart';
import 'package:genchatapp/app/modules/updates/controllers/updates_controller.dart';
import 'package:genchatapp/app/services/shared_preference_service.dart';
import 'package:genchatapp/app/utils/utils.dart';
import 'package:get/get.dart';

import '../../../../main.dart';
import '../../../data/local_database/chatconnect_table.dart';
import '../../../data/local_database/groups_table.dart';
import '../../../data/models/chat_conntact_model.dart';
import '../../../data/models/new_models/response_model/create_group_model.dart';

class HomeController extends GetxController with WidgetsBindingObserver {
  //
  final sharedPreferenceService = Get.find<SharedPreferenceService>();
  final connectivityService = Get.find<ConnectivityService>();
  final selectedContactController = Get.find<SelectContactsController>();
  final groupRepository = Get.find<GroupRepository>();

  final socketService = Get.find<SocketService>();
  final RxList<GroupData> groupsList = <GroupData>[].obs;
  final ChatConectTable chatConectTable = ChatConectTable();
  final GroupsTable groupsTable = GroupsTable();

  final RxInt _currentPageIndex = 0.obs;
  int get currentPageIndex => _currentPageIndex.value;
  set currentPageIndex(int currentPageIndex) =>
      _currentPageIndex.value = currentPageIndex;

  @override
  void onInit() async {
    super.onInit();
    closeKeyboard();
    // FocusManager.instance.primaryFocus?.unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');


    controllerInit();

    String? userId = sharedPreferenceService.getUserData()?.userId.toString();
    await socketService.initSocket(userId!, onConnected: () {
      print(
          'Initial socket connection established in HomeController: UserId for socket connection: $userId');
    });
    var subscriptionTopic = ["genchat-message-$userId"];
    await NotificationService.subscribeToTopics(subscriptionTopic);
    await getGroups();
    // connectSocket();
    // print(sharedPreferenceService.getUserDetails()?.name);
    // print(connectivityService.isConnected.value);
    SchedulerBinding.instance.addPostFrameCallback((timestamp) async {
      if (connectivityService.isConnected.value) {
        // await setUserOnline();
      } else {
        // await setUserOffline();
      }
    });
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        print('📱 App Resumed: Trying to reconnect socket...');
        if (connectivityService.isConnected.value) {
          // await setUserOnline();
          await connectSocket();
          await selectedContactController.syncContactsWithServer();
        }

        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.paused:
        print('📴 App Backgrounded: Disposing socket...');
        disConnectSocket();

        break;
      default:
    }
  }

  Future<void> connectSocket() async {
    String? userId = sharedPreferenceService.getUserData()?.userId.toString();
    if (userId != null && !socketService.isConnected) {
      await socketService.initSocket(userId);
    }
  }

  void disConnectSocket() async {
    socketService.disposeSocket();
  }

  void controllerInit() {
    Get.lazyPut<ChatsController>(
      () => ChatsController(),
    );
    Get.lazyPut<UpdatesController>(
      () => UpdatesController(),
    );
    Get.lazyPut<CallController>(
      () => CallController(),
    );
  }

  Future<void> getGroups() async {
    try {
      // Step 1: Create group
      final response = await groupRepository.fetchGroup();

      if (response != null && response.statusCode == 200) {
        List<GroupData> modelList = (response.data['data'] as List)
            .map((e) => GroupData.fromJson(e))
            .toList();
        groupsList.assignAll(modelList);

        // final rawList = response.data as List;
        // groupsList.assignAll(
        //     rawList.map((e) => CreateGroupModel.fromJson(e)).toList());

        // groupsList.assignAll(response.data);
        // final createGroupModelResponse =
        //     CreateGroupModel.fromJson(response.data);
        if (groupsList.isNotEmpty) {
          for (var i in groupsList) {
            final groupId = i.group!.id ?? 0;

            // Step 2: Insert initial group data into DB
            await groupsTable.insertOrUpdateGroup(i);

            // Step 3: Only upload image if selected

            await chatConectTable.insert(
              contact: ChatConntactModel(
                lastMessageId: 0,
                contactId: groupId.toString(),
                lastMessage: "",
                name: i.group?.name ?? '',
                profilePic: i.group?.displayPictureUrl ?? '',
                timeSent: i.group?.updatedAt ??
                    "", //DateTime.now().toString(), //?? data.group?.createdAt,
                uid: groupId.toString(),
                isGroup: 1,
              ),
            );
          }
        }
      }
    } catch (e) {
      // showAlertMessage("Something went wrong: $e");
    } finally {}
  }
}
