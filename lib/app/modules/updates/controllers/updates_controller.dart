import 'dart:async';

import 'package:flutter/material.dart';
import 'package:genchatapp/app/config/services/folder_creation.dart';
import 'package:genchatapp/app/config/services/socket_service.dart';
import 'package:genchatapp/app/data/local_database/chatconnect_table.dart';
import 'package:genchatapp/app/data/local_database/contacts_table.dart';
import 'package:genchatapp/app/data/local_database/groups_table.dart';
import 'package:genchatapp/app/data/local_database/local_database.dart';
import 'package:genchatapp/app/data/models/chat_conntact_model.dart';
import 'package:genchatapp/app/data/models/new_models/response_model/contact_response_model.dart';
import 'package:genchatapp/app/data/models/new_models/response_model/create_group_model.dart';
import 'package:genchatapp/app/data/models/new_models/response_model/verify_otp_response_model.dart';
import 'package:genchatapp/app/data/models/status_model.dart';
import 'package:genchatapp/app/services/shared_preference_service.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart' as rx;

class UpdatesController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final GroupsTable groupsTable = GroupsTable();

  final socketService = Get.find<SocketService>();
  final sharedPreferenceService = Get.find<SharedPreferenceService>();

  FocusNode focusNode = FocusNode();

  final RxList<ChatConntactModel> contactsList = <ChatConntactModel>[].obs;
  // CreateGroupModel
  final RxList<GroupData> groupsList = <GroupData>[].obs;

  final ChatConectTable chatConectTable = ChatConectTable();

  final FolderCreation folderCreation = Get.find<FolderCreation>();

  final DataBaseService db = Get.find<DataBaseService>();

  final ContactsTable contactsTable = ContactsTable();

  final RxList<UserList> contacts = <UserList>[].obs;

  final Rx<UserData?> _senderuserData = UserData().obs;
  UserData? get senderuserData => _senderuserData.value;
  set senderuserData(UserData? userData) => _senderuserData.value = (userData);

  final RxSet<String> selectedChatUids = <String>{}.obs;

  final RxString _searchText = ''.obs;
  String get searchText => _searchText.value;
  set searchText(String searchText) => _searchText.value = searchText;

  final RxList<ChatConntactModel> filteredContacts = <ChatConntactModel>[].obs;

  var statusList = <StatusModel>[].obs;

  RxDouble progress = 0.0.obs;
  Timer? timer;

  @override
  void onInit() {
    senderuserData = sharedPreferenceService.getUserData();

    ever<List<ChatConntactModel>>(contactsList, (_) => filterContacts());
    ever<String>(_searchText, (_) => filterContacts());
    // bindChatUsersStream();
    // bindCombinedStreams();

    loadStatuses();

    // getGroups();
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
    contactsList.clear();
    selectedChatUids.clear();
    timer?.cancel();
  }

  void startProgress({double durationSeconds = 5, required Function onFinish}) {
    stopProgress();
    progress.value = 0;

    const tick = Duration(milliseconds: 50);
    final totalTicks = (durationSeconds * 1000 / tick.inMilliseconds).round();
    int currentTick = 0;

    timer = Timer.periodic(tick, (timer) {
      currentTick++;
      progress.value = currentTick / totalTicks;
      if (currentTick >= totalTicks) {
        stopProgress();
        onFinish(); // call when finished
      }
    });
  }

  void skip() {
    timer?.cancel();
    Get.back();
  }

  void loadStatuses() {
    statusList.assignAll([
      StatusModel(
        name: "Alice",
          media: [
            {'type': 'image', 'url': 'https://i.pravatar.cc/150?img=2'},
            {'type': 'video', 'url': 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'},
            {'type': 'image', 'url': 'https://i.pravatar.cc/150?img=2'},
            {'type':'text', 'text':'www.google.com'}



          ],
        ProfilePic: "https://i.pravatar.cc/150?img=2",

        time: "Today, 9:00 AM",
      ),
      StatusModel(
        name: "Bob",
          media: [
          {'type': 'image', 'url': 'https://i.pravatar.cc/150?img=2'},
          {'type': 'video', 'url': 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'},
          {'type': 'image', 'url': 'https://picsum.photos/801/1400'},
            {'type':'text', 'text':'Hello Abhi Jha'}
        ],
           time: "Today, 10:30 AM",
        ProfilePic: "https://i.pravatar.cc/150?img=2",


      ),
      StatusModel(
        name: "Charlie",
        media: [
        {'type': 'image', 'url': 'https://picsum.photos/800/1400'},
        {'type': 'video', 'url': 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'},
        {'type': 'image', 'url': 'https://picsum.photos/801/1400'},
          {'type':'text', 'text':'https://i.pravatar.cc/150?img=2                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   '}




        ],
        time: "Yesterday, 8:15 PM",
        ProfilePic: "https://i.pravatar.cc/150?img=2",
        viewed: true,

      ),
    ]);
  }
  void stopProgress() {
    timer?.cancel();
    timer = null;
  }
  void setProgress(double p) {
    progress.value = p.clamp(0.0, 1.0);
  }
  void markAsViewed(StatusModel status) {
    status.viewed = true;
    statusList.refresh();
  }

  // Stream<List<ChatConntactModel>> getChatUsersStream({
  //   Duration interval = const Duration(seconds: 1),
  // }) async* {
  //   while (true) {
  //     await Future.delayed(interval); // controls polling frequency
  //     final messages = await ChatConectTable().fetchAll();

  //     yield messages;
  //   }
  // }

  // void bindCombinedStreams() {
  //   final userId = senderuserData?.userId;
  //   if (userId == null) return;

  //   getChatUsersStream()
  //       .map((contacts) {
  //         // Add unread count logic (placeholder for now)
  //         return contacts.map((contact) {
  //           int unreadCount = 0; // TODO: real calculation

  //           return ChatConntactModel(
  //             uid: contact.uid,
  //             name: contact.name,
  //             unreadCount: unreadCount,
  //             lastMessage: contact.lastMessage,
  //             profilePic: contact.profilePic,
  //             timeSent: contact.timeSent,
  //             contactId: contact.contactId,
  //             isGroup: contact.isGroup,
  //             isBlocked: contact.isBlocked,
  //           );
  //         }).toList();
  //       })
  //       .listen((updatedList) {
  //         // Sort by latest time
  //         updatedList.sort((a, b) {
  //           final aTime =
  //               DateTime.tryParse(a.timeSent ?? '') ??
  //               DateTime.fromMillisecondsSinceEpoch(0);
  //           final bTime =
  //               DateTime.tryParse(b.timeSent ?? '') ??
  //               DateTime.fromMillisecondsSinceEpoch(0);
  //           return bTime.compareTo(aTime);
  //         });

  //         contactsList.assignAll(updatedList);
  //       });
  // }

  void filterContacts() async {
    if (searchText.isEmpty) {
      filteredContacts.assignAll(contactsList); // Show full list
    } else {
      filteredContacts.assignAll(
        contactsList.where((contact) {
          final name = contact.name?.toLowerCase() ?? '';

          return name.contains(searchText);
        }).toList(),
      );
    }
  }

  void showKeyboard() => focusNode.requestFocus();
  void hideKeyboard() => focusNode.unfocus();
}
