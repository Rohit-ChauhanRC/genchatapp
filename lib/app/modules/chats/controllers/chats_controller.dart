import 'dart:async';

import 'package:genchatapp/app/config/services/folder_creation.dart';
import 'package:genchatapp/app/config/services/socket_service.dart';
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

  @override
  void onInit() {
    senderuserData = sharedPreferenceService.getUserData();

    bindChatUsersStream();
    super.onInit();
  }

  @override
  void onReady() {
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

  void bindContactsStream() {
    contacts.bindStream(getContactsFromDBStream());
  }

  Stream<List<UserList>> getContactsFromDBStream() {
    return Stream.periodic(const Duration(seconds: 1)).asyncMap((_) async {
      return await contactsTable.fetchAll();
    });
  }

  void bindChatUsersStream() {
    final stream = getChatUsersStream();
    stream.listen((firebaseContacts) async {
      firebaseContacts.sort((a, b) {
        final aTime = DateTime.tryParse(a.timeSent ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = DateTime.tryParse(b.timeSent ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime); // descending (latest first)
      });
      contactsList.assignAll(firebaseContacts);
    });
  }

  Stream<List<ChatConntactModel>> getChatUsersStream(
      {Duration interval = const Duration(seconds: 1)}) async* {
    while (true) {
      await Future.delayed(interval); // controls polling frequency
      final messages = await ChatConectTable().fetchAll();

      yield messages;
    }
  }

  Future<void> logout() async {
    db.closeDb();
    await sharedPreferenceService.clear().then((onValue) {
      Get.offAllNamed(Routes.LANDING);
    });
  }
}
