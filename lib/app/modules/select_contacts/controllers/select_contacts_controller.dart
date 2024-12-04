import 'package:flutter/cupertino.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';

import '../../../config/firebase_controller/firebase_controller.dart';
import '../../../data/models/user_model.dart';
import '../../../routes/app_pages.dart';
import '../../../utils/utils.dart';

class SelectContactsController extends GetxController {
//
  final FirebaseController firebaseController = Get.put<FirebaseController>(FirebaseController());
  final RxList<Contact> _contacts = <Contact>[].obs;
  List<Contact> get contacts => _contacts;
  set contacts(List<Contact> cts) => _contacts.assignAll(cts);

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
  Future<List<Contact>> getContacts() async {
    try {
      if (await FlutterContacts.requestPermission()) {
        List<Contact> allContacts = await FlutterContacts.getContacts(
            withProperties: true, withPhoto: true);

        // Fetch all registered users from Firebase
        var userCollection = await firebaseController.firestore.collection('users').get();
        Map<String, UserModel> registeredUsers = {};
        for (var document in userCollection.docs) {
          var userData = UserModel.fromMap(document.data());
          registeredUsers[userData.phoneNumber!] = userData;
        }

        // Filter contacts to include only registered users and exclude the current user
        String currentUserPhoneNumber = firebaseController.getCurrentUserPhoneNumber();
        contacts = allContacts.where((contact) {
          String phoneNumber = contact.phones.isNotEmpty ? contact.phones[0].number.replaceAll(' ', '') : '';
          return registeredUsers.containsKey(phoneNumber) && phoneNumber != currentUserPhoneNumber;
        }).toList();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return contacts;
  }

  void selectContact(Contact selectedContact, BuildContext context) async {
    try {
      var userCollection = await firebaseController.firestore.collection('users').get();
      bool isFound = false;
      debugPrint("no: ${selectedContact.phones[0].number.toString()}");

      for (var document in userCollection.docs) {
        var userData = UserModel.fromMap(document.data());
        String selectedPhoneNum = selectedContact.phones[0].number.replaceAll(' ', '');
        if (selectedPhoneNum == userData.phoneNumber) {
          isFound = true;
          // Get.toNamed(Routes.SINGLE_CHAT, arguments: userData);
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
