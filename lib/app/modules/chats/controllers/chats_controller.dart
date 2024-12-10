import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:genchatapp/app/config/services/firebase_controller.dart';
import 'package:genchatapp/app/data/local_database/contacts_table.dart';
import 'package:genchatapp/app/data/models/chat_conntact_model.dart';
import 'package:genchatapp/app/data/models/user_model.dart';
import 'package:genchatapp/app/routes/app_pages.dart';
import 'package:genchatapp/app/services/shared_preference_service.dart';
import 'package:get/get.dart';

class ChatsController extends GetxController {
  //

  final sharedPreferenceService = Get.find<SharedPreferenceService>();
  final firebaseController = Get.find<FirebaseController>();

  final RxList<ChatConntactModel> contactsList = <ChatConntactModel>[].obs;

  final ContactsTable contactsTable = ContactsTable();


  @override
  void onInit() {
    super.onInit();
    // bindStream();
    bindChatUsersStream();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void bindStream() {
    contactsList.bindStream(getChatContacts());
  }

  Stream<List<ChatConntactModel>> getChatUsersStream() {
    UserModel? userdata = sharedPreferenceService.getUserDetails();

    return firebaseController.fetchUsersWithChats(userdata!.uid!);
  }

  void bindChatUsersStream() {
    contactsList.bindStream(getChatUsersStream());
  }

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
                  profilePic: user.profilePic!,
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
    await sharedPreferenceService.clear().then((onValue) {
      Get.offAllNamed(Routes.LANDING);
    });
  }
}
