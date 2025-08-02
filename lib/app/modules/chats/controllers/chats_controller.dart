import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:genchatapp/app/config/services/encryption_service.dart';
import 'package:genchatapp/app/config/services/folder_creation.dart';
import 'package:genchatapp/app/config/services/socket_service.dart';
import 'package:genchatapp/app/constants/message_enum.dart';
import 'package:genchatapp/app/data/local_database/chatconnect_table.dart';
import 'package:genchatapp/app/data/local_database/contacts_table.dart';
import 'package:genchatapp/app/data/local_database/groups_table.dart';
import 'package:genchatapp/app/data/local_database/local_database.dart';
import 'package:genchatapp/app/data/local_database/message_table.dart';
import 'package:genchatapp/app/data/models/chat_conntact_model.dart';
import 'package:genchatapp/app/data/models/new_models/response_model/contact_response_model.dart';
import 'package:genchatapp/app/data/models/new_models/response_model/create_group_model.dart';
import 'package:genchatapp/app/data/models/new_models/response_model/new_message_model.dart';
import 'package:genchatapp/app/data/models/new_models/response_model/verify_otp_response_model.dart';
import 'package:genchatapp/app/data/repositories/group/group_repository.dart';
import 'package:genchatapp/app/services/shared_preference_service.dart';
import 'package:get/get.dart';

import 'package:rxdart/rxdart.dart' as rx;

class ChatsController extends GetxController {
  //

  // final GroupRepository groupRepository;
  //
  // ChatsController({required this.groupRepository});
  final GroupsTable groupsTable = GroupsTable();

  final socketService = Get.find<SocketService>();
  final sharedPreferenceService = Get.find<SharedPreferenceService>();
  final MessageTable messageTable = MessageTable();

  final EncryptionService encryptionService = Get.find();

  FocusNode focusNode = FocusNode();

  final RxList<ChatConntactModel> contactsList = <ChatConntactModel>[].obs;
  // CreateGroupModel
  final RxList<GroupData> groupsList = <GroupData>[].obs;

  final ChatConectTable chatConectTable = ChatConectTable();

  final FolderCreation folderCreation = Get.find<FolderCreation>();

  final DataBaseService db = Get.find<DataBaseService>();

  final ContactsTable contactsTable = ContactsTable();

  final RxList<UserList> contacts = <UserList>[].obs;

  final RxList<NewMessageModel> messageList = <NewMessageModel>[].obs;

  final Rx<UserData?> _senderuserData = UserData().obs;
  UserData? get senderuserData => _senderuserData.value;
  set senderuserData(UserData? userData) => _senderuserData.value = (userData);

  final RxSet<String> selectedChatUids = <String>{}.obs;

  final RxString _searchText = ''.obs;
  String get searchText => _searchText.value;
  set searchText(String searchText) => _searchText.value = searchText;

  final RxList<ChatConntactModel> filteredContacts = <ChatConntactModel>[].obs;

  @override
  void onInit() {
    senderuserData = sharedPreferenceService.getUserData();

    ever<List<ChatConntactModel>>(contactsList, (_) => filterContacts());
    ever<String>(_searchText, (_) => filterContacts());
    // bindChatUsersStream();
    bindCombinedStreams();

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
  }

  Stream<List<ChatConntactModel>> getChatUsersStream({
    Duration interval = const Duration(seconds: 1),
  }) async* {
    while (true) {
      await Future.delayed(interval); // controls polling frequency
      final messages = await ChatConectTable().fetchAll();
      // print("All Chats:----> $messages");

      yield messages;
    }
  }

  Stream<List<NewMessageModel>> getMessagesStream() async* {
    while (true) {
      await Future.delayed(const Duration(seconds: 1));
      final messages = await MessageTable()
          .getAllMessages(); // Make sure this exists
      yield messages;
    }
  }

  void bindCombinedStreams() {
    final userId = senderuserData?.userId;
    if (userId == null) return;

    rx.Rx.combineLatest2(getChatUsersStream(), getMessagesStream(), (
      List<ChatConntactModel> contacts,
      List<NewMessageModel> messages,
    ) {
      // Update each contact with unread count
      final updatedContacts = contacts.map((contact) {
        int unreadCount = 0;

        if (contact.isGroup == 1) {
          // 🔁 For GROUPS: unread if userId != senderId and not read
          unreadCount = messages
              .where(
                (msg) =>
                    msg.isGroupMessage == true &&
                    msg.recipientId.toString() == contact.uid &&
                    msg.senderId != userId &&
                    msg.state != MessageState.delivered,
              )
              .length;
        } else {
          // 🔁 For PERSONAL chats
          unreadCount = messages
              .where(
                (msg) =>
                    msg.senderId.toString() == contact.uid &&
                    msg.recipientId == userId &&
                    msg.state != MessageState.read,
              )
              .length;
        }

        return ChatConntactModel(
          uid: contact.uid,
          name: contact.name,
          unreadCount: unreadCount,
          lastMessage: contact.lastMessage,
          profilePic: contact.profilePic,
          timeSent: contact.timeSent,
          contactId: contact.contactId,
          isGroup: contact.isGroup,
        );
      }).toList();

      return updatedContacts;
    }).listen((updatedList) {
      updatedList.sort((a, b) {
        final aTime =
            DateTime.tryParse(a.timeSent ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);
        final bTime =
            DateTime.tryParse(b.timeSent ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime); // descending (latest first)
      });
      contactsList.assignAll(updatedList);
    });
  }

  void filterContacts() {
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

  void toggleChatSelection(String uid) {
    if (selectedChatUids.contains(uid)) {
      selectedChatUids.remove(uid);
    } else {
      selectedChatUids.add(uid);
    }
    selectedChatUids.refresh();
  }

  void clearChatSelection() {
    selectedChatUids.clear();
  }

  Future<void> deleteSelectedChatsForMeOnly() async {
    try {
      final uidsToDelete = selectedChatUids.toList();

      for (String uid in uidsToDelete) {
        final userId = int.parse(
          uid,
        ); // Assuming UIDs are stored as String but are numeric

        await messageTable.deleteMessagesForUser(userId);

        await chatConectTable.deleteChatUser(uid);
      }

      selectedChatUids.clear();

      update();

      // Get.snackbar("Deleted", "Selected chats were deleted from your side only");
    } catch (e) {
      // debugPrint("Error in deleting chats: $e");
      // Get.snackbar("Error", "Failed to delete selected chats");
    }
  }

  void showKeyboard() => focusNode.requestFocus();
  void hideKeyboard() => focusNode.unfocus();

  String? getTypingStatusText(String chatId, bool isGroup) {
    if (isGroup) {
      final typingUsersMap = socketService.typingGroupUsersMap[chatId];
      if (typingUsersMap != null && typingUsersMap.isNotEmpty) {
        final names = typingUsersMap.values.toList();

        if (names.length == 1) {
          return "${names.first} is typing...";
        } else if (names.length == 2) {
          return "${names[0]}, ${names[1]} are typing...";
        } else {
          final firstTwo = names.take(2).join(', ');
          return "$firstTwo & ${names.length - 2} others are typing...";
        }
      }
    } else {
      final isTyping = socketService.typingStatusMap[chatId] == true;
      if (isTyping) return "Typing...";
    }

    return "";
  }

  // Future<void> getGroups() async {
  //   try {
  //     // Step 1: Create group
  //     final response = await groupRepository.fetchGroup();
  //
  //     if (response != null && response.statusCode == 200) {
  //       List<GroupData> modelList = (response.data['data'] as List)
  //           .map((e) => GroupData.fromJson(e))
  //           .toList();
  //       groupsList.assignAll(modelList);
  //
  //       // final rawList = response.data as List;
  //       // groupsList.assignAll(
  //       //     rawList.map((e) => CreateGroupModel.fromJson(e)).toList());
  //
  //       // groupsList.assignAll(response.data);
  //       // final createGroupModelResponse =
  //       //     CreateGroupModel.fromJson(response.data);
  //       if (groupsList.isNotEmpty) {
  //         for (var i in groupsList) {
  //           final groupId = i.group!.id ?? 0;
  //
  //           // Step 2: Insert initial group data into DB
  //           await groupsTable.insertOrUpdateGroup(i);
  //
  //           // Step 3: Only upload image if selected
  //
  //           await chatConectTable.insert(
  //             contact: ChatConntactModel(
  //               lastMessageId: 0,
  //               contactId: groupId.toString(),
  //               lastMessage: "",
  //               name: i.group?.name ?? '',
  //               profilePic: i.group?.displayPictureUrl ?? '',
  //               timeSent: DateTime.now().toString(), //?? data.group?.createdAt,
  //               uid: groupId.toString(),
  //               isGroup: 1,
  //             ),
  //           );
  //         }
  //       }
  //     }
  //   } catch (e) {
  //     // showAlertMessage("Something went wrong: $e");
  //   } finally {}
  // }
}
