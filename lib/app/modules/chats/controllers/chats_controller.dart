import 'dart:async';

import 'package:genchatapp/app/config/services/firebase_controller.dart';
import 'package:genchatapp/app/config/services/folder_creation.dart';
import 'package:genchatapp/app/config/services/socket_service.dart';
import 'package:genchatapp/app/constants/constants.dart';
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

class ChatsController extends GetxController {
  //

  final socketService = Get.find<SocketService>();
  final sharedPreferenceService = Get.find<SharedPreferenceService>();
  // final firebaseController = Get.find<FirebaseController>();
  final MessageTable messageTable = MessageTable();

  final RxList<ChatConntactModel> contactsList = <ChatConntactModel>[].obs;

  final ChatConectTable chatConectTable = ChatConectTable();

  final FolderCreation folderCreation = Get.find<FolderCreation>();

  final DataBaseService db = Get.find<DataBaseService>();

  final ContactsTable contactsTable = ContactsTable();

  final RxList<UserList> contacts = <UserList>[].obs;
  // List<UserList> get contacts => _contacts;
  // set contacts(List<UserList> cts) => _contacts.assignAll(cts);

  final RxList<NewMessageModel> messageList = <NewMessageModel>[].obs;
  // List<NewMessageModel> get messageList => _messageList;
  // set messageList(List<NewMessageModel> cts) => _messageList.assignAll(cts);

  final Rx<UserData?> _senderuserData = UserData().obs;
  UserData? get senderuserData => _senderuserData.value;
  set senderuserData(UserData? userData) => _senderuserData.value = (userData);

  // late StreamSubscription<UserList?> contactsSubscription;

  @override
  void onInit() {
    senderuserData = sharedPreferenceService.getUserData();

    // bindContactsStream();
    // messageBindStream();
    // bindChatUsersStream();
    // loadLocalContacts();
    bindChatUsersStream();
    super.onInit();
    // bindStream();
    // connectSocket();
  }

  @override
  void onReady() {
    // bindChatUsersStream();

    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
    // contactsSubscription.cancel();
  }

  void connectSocket() async {
    String? userId = sharedPreferenceService.getUserData()?.userId.toString();
    if (!socketService.isConnected) {
      await socketService.initSocket(userId!);
    }
  }

  void bindContactsStream() {
    contacts.bindStream(getContactsFromDBStream());
  }

  Stream<List<UserList>> getContactsFromDBStream() {
    return Stream.periodic(const Duration(seconds: 1)).asyncMap((_) async {
      return await contactsTable.fetchAll();
    });
  }

  Future<void> loadLocalContacts() async {
    final dbs = await db.database;
    final result = await dbs.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='$chatConnectTable'");
    if (result.isEmpty) {
      chatConectTable.createTable(dbs);
    }
    final localContacts = await chatConectTable.fetchAll();
    contactsList.assignAll(localContacts);
  }

  void bindChatUsersStream() {
    final stream = getChatUsersStream();
    stream.listen((firebaseContacts) async {
      // for (var contact in firebaseContacts) {
      //   ChatConntactModel? ct =
      //       await chatConectTable.fetchById(uid: contact.uid!);
      //   if (ct != null) {
      //     await chatConectTable.updateContact(
      //         uid: contact.uid!,
      //         lastMessage: contact.lastMessage,
      //         profilePic: contact.profilePic,
      //         timeSent: contact.timeSent!.toString());
      //   } else {
      //     await chatConectTable.insert(contact: contact);
      //   }
      // }

      // Update the UI list
      contactsList.assignAll(firebaseContacts);
    });
  }

  // void messageBindStream() {
  //   messageList.bindStream(getMessageStream());
  // }

  Stream<List<ChatConntactModel>> getChatUsersStream(
      {Duration interval = const Duration(seconds: 1)}) async* {
    while (true) {
      await Future.delayed(interval); // controls polling frequency
      final messages = await ChatConectTable().fetchAll();

      yield messages;
    }
  }

  // Stream<List<ChatConntactModel>> getChatUsersStream() {
  //   final senderUserData = sharedPreferenceService.getUserData();

  //   return Stream.periodic(const Duration(seconds: 1)).asyncMap((_) async {

  //     if (messageList.length > 1) {
  //       messageList.sort((a, b) {
  //         final dateA = DateTime.tryParse(a.createdAt ?? '') ??
  //             DateTime.fromMillisecondsSinceEpoch(0);
  //         final dateB = DateTime.tryParse(b.createdAt ?? '') ??
  //             DateTime.fromMillisecondsSinceEpoch(0);
  //         return dateB.compareTo(dateA); // descending
  //       });
  //     }

  //     List<ChatConntactModel> chatContacts = [];
  //     Set<int> processedUserIds = {};

  //     for (var message in messageList) {
  //       // Get the other user's ID (not the current user)
  //       int? otherUserId;
  //       if (message.senderId == senderUserData?.userId) {
  //         otherUserId = message.recipientId;
  //       } else if (message.recipientId == senderUserData?.userId) {
  //         otherUserId = message.senderId;
  //       }

  //       if (otherUserId == null || processedUserIds.contains(otherUserId))
  //         continue;

  //       final user = contacts.firstWhereOrNull((u) => u.userId == otherUserId);
  //       if (user != null) {
  //         chatContacts.add(ChatConntactModel(
  //           contactId: user.userId.toString(),
  //           lastMessage: message.message ?? '',
  //           name: user.name ?? '',
  //           profilePic: user.displayPictureUrl ?? '',
  //           timeSent: DateTime.parse((message.messageSentFromDeviceTime ?? '')),
  //           uid: user.userId.toString(),
  //         ));
  //         processedUserIds.add(otherUserId);
  //       }
  //     }

  //     return chatContacts;
  //   });
  // }

  Future<void> logout() async {
    db.closeDb();
    await sharedPreferenceService.clear().then((onValue) {
      Get.offAllNamed(Routes.LANDING);
    });
  }
}
