import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:genchatapp/app/services/shared_preference_service.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../config/services/firebase_controller.dart';
import '../../../data/models/contact_model.dart';
import '../../../data/models/user_model.dart';
import '../../../routes/app_pages.dart';
import '../../../utils/utils.dart';

class SelectContactsController extends GetxController {
//
  final FirebaseController firebaseController = Get.put<FirebaseController>(FirebaseController());
  final SharedPreferenceService _sharedPreferenceService = Get.find<SharedPreferenceService>();
  final RxList<ContactModel> _contacts = <ContactModel>[].obs;
  List<ContactModel> get contacts => _contacts;
  set contacts(List<ContactModel> cts) => _contacts.assignAll(cts);

  final RxBool _isContactRefreshed = true.obs;
  bool get isContactRefreshed => _isContactRefreshed.value;
  set isContactRefreshed(bool v) => _isContactRefreshed.value = v;

  @override
  void onInit() async{
    await getContacts();
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

  Future<List<ContactModel>> getContacts() async {
    isContactRefreshed = false;
    try {
      if (await FlutterContacts.requestPermission()) {
        List<Contact> allContacts = await FlutterContacts.getContacts(
            withProperties: true, withPhoto: true);

        // Fetch all registered users from Firebase
        var userCollection = await firebaseController.firestore.collection('users').get();
        Map<String, UserModel> registeredUsers = {};
        for (var document in userCollection.docs) {
          var userData = UserModel.fromJson(document.data());
          registeredUsers[userData.phoneNumber] = userData;
          print(registeredUsers);
        }

        // Filter contacts to include only registered users and exclude the current user
         UserModel? userdata = _sharedPreferenceService.getUserDetails();
        String? currentUserPhoneNumber = userdata?.phoneNumber;

        List<ContactModel> contactList = [];
        for (var contact in allContacts) {
          String phoneNumber = contact.phones.isNotEmpty ? contact.phones[0].number.replaceAll(' ', '') : '';
          if (registeredUsers.containsKey(phoneNumber) && phoneNumber != currentUserPhoneNumber) {
            UserModel? user = registeredUsers[phoneNumber];
            Uint8List? profilePicBytes = user != null ? await downloadProfilePicture(user.profilePic) : null;
            contactList.add(ContactModel(
              fullName: contact.displayName,
              contactNumber: phoneNumber,
              image: profilePicBytes,
            ));
          }
        }
        contacts = contactList;
        isContactRefreshed = true;
        print("All contacts:-----> $contacts");
      }
    } catch (e) {
      debugPrint(e.toString());
      isContactRefreshed = true;
    }
    return contacts;
  }

  Future<Uint8List?> downloadProfilePicture(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  void selectContact(ContactModel selectedContact, BuildContext context) async {
    try {
      var userCollection = await firebaseController.firestore.collection('users').get();
      bool isFound = false;
      debugPrint("no: ${selectedContact.contactNumber.toString()}");

      for (var document in userCollection.docs) {
        var userData = UserModel.fromJson(document.data());
        String selectedPhoneNum = selectedContact.contactNumber[0].replaceAll(' ', '');
        if (selectedPhoneNum == userData.phoneNumber) {
          isFound = true;
          Get.toNamed(Routes.SINGLE_CHAT, arguments: userData);
        }
      }

      if (!isFound) {
        showSnackBar(
          context: context,
          content: 'This number does not exist on this app.',
        );
      }
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  // Future<List<Contact>> getContacts() async {
  //   try {
  //     if (await FlutterContacts.requestPermission()) {
  //       contacts = await FlutterContacts.getContacts(
  //           withProperties: true, withPhoto: true);
  //     }
  //   } catch (e) {
  //     debugPrint(e.toString());
  //   }
  //   return contacts;
  // }
  //
  // void selectContact(Contact selectedContact, BuildContext context) async {
  //   try {
  //     var userCollection =
  //     await firebaseController.firestore.collection('users').get();
  //     bool isFound = false;
  //     debugPrint("no: ${selectedContact.phones[0].number.toString()}");
  //
  //     for (var document in userCollection.docs) {
  //       var userData = UserModel.fromMap(document.data());
  //       String selectedPhoneNum = selectedContact.phones[0].number.replaceAll(
  //         ' ',
  //         '',
  //       );
  //       if (selectedPhoneNum == userData.phoneNumber) {
  //         isFound = true;
  //         // Get.toNamed(Routes.SINGLE_CHAT, arguments: userData);
  //       }
  //     }
  //
  //     if (!isFound) {
  //       showSnackBar(
  //         context: context,
  //         content: 'This number does not exist on this app.',
  //       );
  //     }
  //   } catch (e) {
  //     showSnackBar(context: context, content: e.toString());
  //   }
  // }
}
