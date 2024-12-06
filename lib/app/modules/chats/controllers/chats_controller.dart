import 'package:genchatapp/app/config/services/firebase_controller.dart';
import 'package:genchatapp/app/data/models/chat_conntact_model.dart';
import 'package:genchatapp/app/data/models/user_model.dart';
import 'package:genchatapp/app/services/shared_preference_service.dart';
import 'package:get/get.dart';

class ChatsController extends GetxController {
  //

  final sharedPreferenceService = Get.find<SharedPreferenceService>();
  final FirebaseController firebaseController = Get.find();

  final RxList<ChatConntactModel> contactsList = <ChatConntactModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    bindStream();
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

  Stream<List<ChatConntactModel>> getChatContacts() {
    UserModel? userdata = sharedPreferenceService.getUserDetails();

    // List<ChatConntactModel> contacts = [];

    try {
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

            contactsList.add(
              ChatConntactModel(
                name: user.name!,
                profilePic: user.profilePic!,
                contactId: chatContact.contactId,
                timeSent: chatContact.timeSent,
                lastMessage: chatContact.lastMessage,
                uid: user.uid!,
                user: user,
              ),
            );
          }
        }
        // return contactsList.stream;
      });
      return contactsList.stream;
    } catch (e) {
      throw e.toString();
    }
  }
}
