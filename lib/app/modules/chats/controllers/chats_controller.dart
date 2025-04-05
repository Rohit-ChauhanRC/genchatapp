import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:genchatapp/app/config/services/firebase_controller.dart';
import 'package:genchatapp/app/config/services/folder_creation.dart';
import 'package:genchatapp/app/constants/constants.dart';
import 'package:genchatapp/app/data/local_database/chatconnect_table.dart';
import 'package:genchatapp/app/data/local_database/contacts_table.dart';
import 'package:genchatapp/app/data/local_database/local_database.dart';
import 'package:genchatapp/app/data/models/chat_conntact_model.dart';
import 'package:genchatapp/app/data/models/contact_model.dart';
import 'package:genchatapp/app/data/models/user_model.dart';
import 'package:genchatapp/app/routes/app_pages.dart';
import 'package:genchatapp/app/services/shared_preference_service.dart';
import 'package:get/get.dart';

class ChatsController extends GetxController {
  //

  final sharedPreferenceService = Get.find<SharedPreferenceService>();
  final firebaseController = Get.find<FirebaseController>();

  final RxList<ChatConntactModel> contactsList = <ChatConntactModel>[].obs;

  final ChatConectTable chatConectTable = ChatConectTable();

  final FolderCreation folderCreation = Get.find<FolderCreation>();

  final DataBaseService db = Get.find<DataBaseService>();

  final ContactsTable contactsTable = ContactsTable();

  final RxList<ContactModel> _contacts = <ContactModel>[].obs;
  List<ContactModel> get contacts => _contacts;
  set contacts(List<ContactModel> cts) => _contacts.assignAll(cts);

  @override
  void onInit() {
    loadLocalContacts();
    bindChatUsersStream();
    super.onInit();
    // bindStream();
  }

  @override
  void onReady() {
    bindChatUsersStream();

    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
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

  void bindStream() {
    contactsList.bindStream(getChatContacts());
  }

  void bindChatUsersStream() {
    final stream = getChatUsersStream();
    stream.listen((firebaseContacts) async {
      // Save new data locally
      // await chatConectTable.deleteTable();
      for (var contact in firebaseContacts) {
        ChatConntactModel? ct =
            await chatConectTable.fetchById(uid: contact.uid);
        if (ct != null) {
          await chatConectTable.updateContact(
              uid: contact.uid,
              lastMessage: contact.lastMessage,
              profilePic: contact.profilePic,
              timeSent: contact.timeSent.microsecondsSinceEpoch);
        } else {
          await chatConectTable.insert(contact: contact);
        }
      }

      // Update the UI list
      contactsList.assignAll(firebaseContacts);
    });
  }

  Stream<List<ChatConntactModel>> getChatUsersStream() async* {
    UserModel? userdata = sharedPreferenceService.getUserDetails();

    yield* firebaseController.firestore
        .collection('users')
        .doc(userdata!.uid)
        .collection('chats')
        .snapshots()
        .asyncMap((snapshot) async {
      List<ChatConntactModel> firebaseContacts = [];
      Set<String> usersSet = {};

      //  Set<String> seenPhoneNumbers = {};

      for (var document in snapshot.docs) {
        var chatContact = ChatConntactModel.fromMap(document.data());
        var userData = await firebaseController.firestore
            .collection('users')
            .doc(chatContact.contactId)
            .get();
        var user = UserModel.fromJson(userData.data()!);

        if (!usersSet.contains(user.phoneNumber!)) {
          Uint8List? profilePicBytes = user != null
              ? await firebaseController.firebaseStorage
                  .refFromURL(user.profilePic!)
                  .getData()
              : null;

          // final now = DateTime.now();
          // final date =
          //     "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}";
          // final fileName = "IMG-$date-GA${user.uid}.jpg";
          final fileName = "IMG-GA${user.uid}.jpg";

          // final String fileName = path
          //     .basename(Uri.parse(user.profilePic!).path); // e.g., "image.jpg"

          final imgePath = await folderCreation.saveFile(
            fileBytes: profilePicBytes!,
            fileName: fileName,
            subFolder: "Images",
          );

          // ContactModel? contactModel =
          //     await contactsTable.fetchByUid(user.uid!);
          // await contactsTable.create(
          //     fullName: user.name!,
          //     contactNumber: user.phoneNumber!,
          //     uid: user.uid!,
          //     imagePath: imgePath);

          firebaseContacts.add(ChatConntactModel(
            name: chatContact.name,
            profilePic: imgePath,
            contactId: chatContact.contactId,
            timeSent: chatContact.timeSent,
            lastMessage: chatContact.lastMessage,
            uid: user.uid!,
          ));
          usersSet.add(user.phoneNumber!);
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

  Stream<List<ChatConntactModel>> getChatContacts() async* {
    UserModel? userdata = sharedPreferenceService.getUserDetails();

    // List<ChatConntactModel> contacts = [];

    try {
      Set<String> usersSet = {};

      QuerySnapshot snapshot =
          await firebaseController.firestore.collection('users').get();

      firebaseController.firestore
          .collection('users')
          .doc(userdata!.uid)
          .collection('chats')
          .snapshots()
          .asyncMap((event) async {
        if (event.docs.isNotEmpty) {
          for (var document in event.docs) {
            var chatContact = ChatConntactModel.fromMap(document.data());
            var userData = await firebaseController.firestore
                .collection('users')
                .doc(chatContact.contactId)
                .get();
            var user = UserModel.fromJson(userData.data()!);

            if (!usersSet.contains(user.phoneNumber!)) {
              contactsList.add(
                ChatConntactModel(
                  name: user.name!,
                  profilePic: chatContact.profilePic,
                  contactId: chatContact.contactId,
                  timeSent: chatContact.timeSent,
                  lastMessage: chatContact.lastMessage,
                  uid: user.uid!,
                ),
              );
              usersSet.add(user.phoneNumber!);
            }
          }
        }
        // return contactsList.stream;
      });
      yield* contactsList.stream;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> logout() async {
    db.closeDb();
    await sharedPreferenceService.clear().then((onValue) {
      Get.offAllNamed(Routes.LANDING);
    });
  }
}
