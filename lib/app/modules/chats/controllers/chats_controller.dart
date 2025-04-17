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

  final RxList<UserList> _contacts = <UserList>[].obs;
  List<UserList> get contacts => _contacts;
  set contacts(List<UserList> cts) => _contacts.assignAll(cts);

  final RxList<NewMessageModel> _messageList = <NewMessageModel>[].obs;
  List<NewMessageModel> get messageList => _messageList;
  set messageList(List<NewMessageModel> cts) => _messageList.assignAll(cts);

  final Rx<UserData?> _senderuserData = UserData().obs;
  UserData? get senderuserData => _senderuserData.value;
  set senderuserData(UserData? userData) => _senderuserData.value = (userData);

  @override
  void onInit() {
    senderuserData = sharedPreferenceService.getUserData();

    getContactsFromDB();
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
  }

  void connectSocket() async {
    String? userId = sharedPreferenceService.getUserData()?.userId.toString();
    if (!socketService.isConnected) {
      await socketService.initSocket(userId!);
    }
  }

  getContactsFromDB() async {
    return contacts.assignAll(await contactsTable.fetchAll());
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

  // void bindStream() {
  //   contactsList.bindStream(getChatContacts());
  // }

  void bindChatUsersStream() {
    final stream = getChatUsersStream();
    stream.listen((firebaseContacts) async {
      // Save new data locally
      // await chatConectTable.deleteTable();
      for (var contact in firebaseContacts) {
        ChatConntactModel? ct =
            await chatConectTable.fetchById(uid: contact.uid!);
        if (ct != null) {
          await chatConectTable.updateContact(
              uid: contact.uid!,
              lastMessage: contact.lastMessage,
              profilePic: contact.profilePic,
              timeSent: contact.timeSent!.microsecondsSinceEpoch);
        } else {
          await chatConectTable.insert(contact: contact);
        }
      }

      // Update the UI list
      contactsList.assignAll(firebaseContacts);
    });
  }

  // Stream<List<NewMessageModel>> getMessageStream() async* {
  //   yield* Stream.periodic(const Duration(seconds: 1), (_) async {
  //     return await MessageTable();

  //     );
  //   }).asyncMap((event) async => await event);
  // }

  // Stream<List<ChatConntactModel>> getChatUsersStream() async* {
  //   // UserModel? userdata = sharedPreferenceService.getUserDetails();

  //   yield* Stream.periodic(const Duration(seconds: 1), (_) async {
  //     return await MessageTable().getAllMessages();
  //   }).asyncMap((snapshot) async {
  //     List<NewMessageModel> newMessageList = await snapshot;
  //     List<ChatConntactModel> firebaseContacts = [];
  //     Set<String> usersSet = {};

  //     firebaseContacts = newMessageList
  //         .where((message) =>
  //             contacts.any((user) => user.userId == message.recipientId))
  //         .map((message) {
  //       final user = contacts.lastWhere((user) =>
  //           (user.userId == message.recipientId) &&
  //           (senderuserData!.userId != message.recipientId));
  //       return ChatConntactModel(
  //         contactId: user.userId.toString(),
  //         lastMessage: message.message.toString(),
  //         name: user.name.toString(),
  //         profilePic: user.displayPictureUrl.toString(),
  //         timeSent: DateTime.now(),
  //         uid: user.userId.toString(),
  //       );
  //     }).toList();

  //     return firebaseContacts;
  //   });
  // }
  Stream<List<ChatConntactModel>> getChatUsersStream() {
    final senderUserData = sharedPreferenceService.getUserData();

    return Stream.periodic(const Duration(seconds: 1)).asyncMap((_) async {
      List<NewMessageModel> newMessageList =
          await MessageTable().getAllMessages();

      // newMessageList.sort((a, b) => DateTime.parse(b.createdAt ?? '')
      //     .compareTo(DateTime.parse(a.createdAt ?? '')));

      List<ChatConntactModel> firebaseContacts = [];
      Set<int> addedUserIds = {};

      for (var message in newMessageList) {
        final recipientId = message.recipientId == senderUserData!.userId
            ? message.senderId
            : message.recipientId;

        if (recipientId == null || addedUserIds.contains(recipientId)) {
          continue;
        }

        final user =
            contacts.firstWhereOrNull((user) => user.userId == recipientId);

        if (user != null) {
          firebaseContacts.add(ChatConntactModel(
            contactId: user.userId.toString(),
            lastMessage: message.message ?? '',
            name: user.localName ?? '',
            profilePic: user.displayPictureUrl ?? '',
            timeSent: DateTime.fromMicrosecondsSinceEpoch(
              int.tryParse(message.messageSentFromDeviceTime ?? '') ??
                  DateTime.now().microsecondsSinceEpoch,
            ),
            uid: user.userId.toString(),
          ));
          addedUserIds.add(recipientId);
        }
      }

      return firebaseContacts;
    });
  }

  // Stream<List<ChatConntactModel>> getChatUsersStream() {
  //   UserModel? userdata = sharedPreferenceService.getUserDetails();

  //   return firebaseController.fetchUsersWithChats(userdata!.uid!);
  // }

  // void bindChatUsersStream() {
  //   contactsList.bindStream(getChatUsersStream());
  // }

  // Stream<List<ChatConntactModel>> getChatContacts() async* {
  //   UserModel? userdata = sharedPreferenceService.getUserDetails();

  //   // List<ChatConntactModel> contacts = [];

  //   try {
  //     Set<String> usersSet = {};

  //     QuerySnapshot snapshot =
  //         await firebaseController.firestore.collection('users').get();

  //     firebaseController.firestore
  //         .collection('users')
  //         .doc(userdata!.uid)
  //         .collection('chats')
  //         .snapshots()
  //         .asyncMap((event) async {
  //       if (event.docs.isNotEmpty) {
  //         for (var document in event.docs) {
  //           var chatContact = ChatConntactModel.fromMap(document.data());
  //           var userData = await firebaseController.firestore
  //               .collection('users')
  //               .doc(chatContact.contactId)
  //               .get();
  //           var user = UserModel.fromJson(userData.data()!);

  //           if (!usersSet.contains(user.phoneNumber!)) {
  //             contactsList.add(
  //               ChatConntactModel(
  //                 name: user.name!,
  //                 profilePic: chatContact.profilePic,
  //                 contactId: chatContact.contactId,
  //                 timeSent: chatContact.timeSent,
  //                 lastMessage: chatContact.lastMessage,
  //                 uid: user.uid!,
  //               ),
  //             );
  //             usersSet.add(user.phoneNumber!);
  //           }
  //         }
  //       }
  //       // return contactsList.stream;
  //     });
  //     yield* contactsList.stream;
  //   } catch (e) {
  //     throw e.toString();
  //   }
  // }

  Future<void> logout() async {
    db.closeDb();
    await sharedPreferenceService.clear().then((onValue) {
      Get.offAllNamed(Routes.LANDING);
    });
  }
}
