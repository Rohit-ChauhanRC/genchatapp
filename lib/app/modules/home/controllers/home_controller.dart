import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:genchatapp/app/common/user_defaults/user_defaults_keys.dart';
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
import 'package:path_provider/path_provider.dart';

import '../../../../main.dart';
import '../../../data/local_database/chatconnect_table.dart';
import '../../../data/local_database/groups_table.dart';
import '../../../data/models/chat_conntact_model.dart';
import '../../../data/models/new_models/response_model/create_group_model.dart';

import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

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
    await getStatusTime();

    await getGroups();
    await selectedContactController.syncContactsWithServer();
    String? userPhoneNumber = sharedPreferenceService
        .getUserData()
        ?.phoneNumber;

    await socketService.initSocket(
      userId!,
      onConnected: () {
        // debugPrint(
        //   'Initial socket connection established in HomeController: UserId for socket connection: $userId',
        // );
      },
    );

    var subscriptionTopic = ["genchat-message-$userPhoneNumber"];
    await NotificationService.subscribeToTopics(subscriptionTopic);

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
        // debugPrint('📱 App Resumed: Trying to reconnect socket...');
        if (connectivityService.isConnected.value) {
          // await setUserOnline();
          await connectSocket();
          // await getGroups();

          // await selectedContactController.syncContactsWithServer();
        }

        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.paused:
        // debugPrint('📴 App Backgrounded: Disposing socket...');
        await disConnectSocket();

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

  Future<void> disConnectSocket() async {
    socketService.disposeSocket();
  }

  void controllerInit() {
    Get.lazyPut<ChatsController>(() => ChatsController());
    Get.lazyPut<UpdatesController>(() => UpdatesController());
    Get.lazyPut<CallController>(() => CallController());
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
            if (i.group!.displayPictureUrl!.isNotEmpty &&
                connectivityService.isConnected.value) {
              _downloadAndCacheProfileImage(
                i.group!.displayPictureUrl!,
                i.group!.displayPictureUrl!.split(
                  "/",
                )[i.group!.displayPictureUrl!.split("/").length - 1],
              );
            }

            await chatConectTable.insertOrUpdateGroupChat(
              ChatConntactModel(
                lastMessageId: 0,
                contactId: groupId.toString(),
                lastMessage: "",
                name: i.group?.name ?? '',
                profilePic: i.group?.displayPictureUrl ?? '',
                timeSent:
                    i.group?.updatedAt ??
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

  Future<void> _downloadAndCacheProfileImage(
    String imageUrl,
    String fileName,
  ) async {
    try {
      final directory = await getApplicationDocumentsDirectory();

      final pngFileName = fileName.replaceAll(
        RegExp(r'\.jpg$'),
        '.png',
      ); // ensure .png
      final filePath = '${directory.path}/$pngFileName';

      final file = File(filePath);

      if (file.existsSync()) {
        // debugPrint("file exist already!");
      } else {
        final response = await http.get(Uri.parse(imageUrl));
        if (response.statusCode != 200) {
          throw Exception("Failed to download image");
        }

        final imageBytes = response.bodyBytes;
        final originalImage = img.decodeImage(imageBytes);
        if (originalImage == null) throw Exception("Image decode failed");

        await file.writeAsBytes(img.encodePng(originalImage));

        // debugPrint("✅ Circular PNG with transparency saved: $filePath");
      }
    } catch (e) {
      // debugPrint("❌ Silent crop failed: $e");
    }
  }

  Future<void> getStatusTime() async {
    try {
      // Step 1: Create group
      final response = await groupRepository.fetchStatusTime();

      if (response != null && response.statusCode == 200) {
        int? modelList = int.parse(
          (response.data['data']['statusDuration']).toString(),
        );

        //
        int? messageTime = int.parse(
          (response.data['data']['messageDuration']).toString(),
        );

        if (modelList != null) {
          sharedPreferenceService.setInt(
            UserDefaultsKeys.statusDurationKey,
            int.parse(modelList.toString()),
          );
          // messageDurationKey
          sharedPreferenceService.setInt(
            UserDefaultsKeys.messageDurationKey,
            int.parse(messageTime.toString()),
          );
        }
      }
    } catch (e) {
      // showAlertMessage("Something went wrong: $e");
    } finally {}
  }
}
