import 'dart:async';

import 'package:genchatapp/app/config/services/folder_creation.dart';
import 'package:genchatapp/app/config/services/socket_service.dart';
import 'package:genchatapp/app/constants/message_enum.dart';
import 'package:genchatapp/app/data/local_database/chatconnect_table.dart';
import 'package:genchatapp/app/data/local_database/contacts_table.dart';
import 'package:genchatapp/app/data/local_database/local_database.dart';
import 'package:genchatapp/app/data/local_database/message_table.dart';
import 'package:genchatapp/app/data/models/chat_conntact_model.dart';
import 'package:genchatapp/app/data/models/new_models/response_model/contact_response_model.dart';
import 'package:genchatapp/app/data/models/new_models/response_model/new_message_model.dart';
import 'package:genchatapp/app/data/models/new_models/response_model/verify_otp_response_model.dart';
import 'package:genchatapp/app/routes/app_pages.dart';
import 'package:genchatapp/app/services/shared_preference_service.dart';
import 'package:get/get.dart';

import 'package:rxdart/rxdart.dart' as rx;

class ChatsController extends GetxController {
  //

  final socketService = Get.find<SocketService>();
  final sharedPreferenceService = Get.find<SharedPreferenceService>();
  final MessageTable messageTable = MessageTable();

  final RxList<ChatConntactModel> contactsList = <ChatConntactModel>[].obs;

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


  @override
  void onInit() {
    senderuserData = sharedPreferenceService.getUserData();

    // bindChatUsersStream();
    bindCombinedStreams();
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
    selectedChatUids.clear();
  }

  Stream<List<ChatConntactModel>> getChatUsersStream(
      {Duration interval = const Duration(seconds: 1)}) async* {
    while (true) {
      await Future.delayed(interval); // controls polling frequency
      final messages = await ChatConectTable().fetchAll();

      yield messages;
    }
  }

  Stream<List<NewMessageModel>> getMessagesStream() async* {
    while (true) {
      await Future.delayed(const Duration(seconds: 1));
      final messages =
          await MessageTable().getAllMessages(); // Make sure this exists
      yield messages;
    }
  }

  void bindCombinedStreams() {
    final userId = senderuserData?.userId;
    if (userId == null) return;

    rx.Rx.combineLatest2(
      getChatUsersStream(),
      getMessagesStream(),
      (List<ChatConntactModel> contacts, List<NewMessageModel> messages) {
        // Update each contact with unread count
        final updatedContacts = contacts.map((contact) {
          final unreadCount = messages
              .where((msg) =>
                  msg.senderId == int.parse(contact.uid!) &&
                  msg.recipientId == userId &&
                  msg.state != MessageState.read)
              .length;

          return ChatConntactModel(
            uid: contact.uid,
            name: contact.name,
            unreadCount: unreadCount,
            lastMessage: contact.lastMessage,
            profilePic: contact.profilePic,
            timeSent: contact.timeSent,
            contactId: contact.contactId,
          );
        }).toList();

        return updatedContacts;
      },
    ).listen((updatedList) {
      updatedList.sort((a, b) {
        final aTime = DateTime.tryParse(a.timeSent ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = DateTime.tryParse(b.timeSent ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime); // descending (latest first)
      });
      contactsList.assignAll(updatedList);
    });
  }

  void toggleChatSelection(String uid) {
    if (selectedChatUids.contains(uid)) {
      selectedChatUids.remove(uid);
    } else {
      selectedChatUids.add(uid);
    }
    selectedChatUids.refresh();
  }

  void clearChatSelection(){
    selectedChatUids.clear();
  }

  Future<void> deleteSelectedChatsForMeOnly() async {
    try {
      final uidsToDelete = selectedChatUids.toList();

      for (String uid in uidsToDelete) {
        final userId = int.parse(uid); // Assuming UIDs are stored as String but are numeric

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


}
