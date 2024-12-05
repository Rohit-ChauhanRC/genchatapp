import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:genchatapp/app/data/models/user_model.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

class FirebaseController extends GetxController {
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> setUserData(
      {required String uid, required UserModel user}) async {
    await firestore.collection("users").doc(uid).set(user.toMap());
  }

  Future<String> storeFileToFirebase(
      {required String path, required File file}) async {
    UploadTask uploadTask = firebaseStorage.ref().child(path).putFile(file);
    TaskSnapshot snap = await uploadTask;
    String downloadUrl = await snap.ref.getDownloadURL();
    return downloadUrl;
  }

  Stream<UserModel> getUserData(String userId) {
    return firestore.collection('users').doc(userId).snapshots().map(
          (event) => UserModel.fromMap(
            event.data()!,
          ),
        );
  }

  // Stream<List<Status>> getStatusData({
  //   required List<Contact> contacts,
  //   required int i,
  //   required String uid,
  // }) {
  //   List<Status> status = [];
  //   return firestore
  //       .collection('status')
  //       .where(
  //         'phoneNumber',
  //         isEqualTo: contacts[i].phones[0].number.replaceAll(
  //               ' ',
  //               '',
  //             ),
  //       )
  //       .where(
  //         'createdAt',
  //         isGreaterThan: DateTime.now()
  //             .subtract(const Duration(hours: 24))
  //             .millisecondsSinceEpoch,
  //       )
  //       .snapshots()
  //       .map((e) {
  //     for (var i = 0; i < e.docs.length; i++) {
  //       // status.add(Status.fromMap(e.docs[i].data()));
  //     }
  //     return status;
  //   });
  // }

  void setUserState(bool isOnline, String uid) async {
    await firestore.collection('users').doc(uid).update({
      'isOnline': isOnline,
    });
  }

  // Future<UserModel?> getCurrentUserData(String uid) async {
  //   var userData = await firestore.collection('users').doc(uid).get();

  //   UserModel? user;
  //   if (userData.data() != null) {
  //     user = UserModel.fromMap(userData.data()!);
  //   }
  //   return user;
  // }

  // Future<void> readUser() async {
  //   String user = await prefs.getString(userData) ?? "";
  //   if (user.isNotEmpty) {
  //     userModel = UserModel.fromJson(jsonDecode(user));
  //   }
  // }

  // Future<void> sendUserMsg(
  //     {required String reciverId,
  //     required String currentUid,
  //     required ChatConntactModel data}) async {
  //   await firestore
  //       .collection('users')
  //       .doc(reciverId)
  //       .collection("chats")
  //       .doc(currentUid)
  //       .set(data.toMap());
  // }

  // Future<void> setUserMsg({
  //   required String reciverId,
  //   required String currentUid,
  //   required Message data,
  //   required String messageId,
  // }) async {
  //   await firestore
  //       .collection('users')
  //       .doc(currentUid)
  //       .collection("chats")
  //       .doc(reciverId)
  //       .collection('messages')
  //       .doc(messageId)
  //       .set(data.toMap());
  // }

  Future<void> downloadAndStoreFile(String fileUrl) async {
    try {
      // Create a reference to the file in Firebase Storage
      Reference storageRef = FirebaseStorage.instance.refFromURL(fileUrl);

      // Get the file from Firebase Storage
      final byteData = await storageRef.getData();

      if (byteData != null) {
        // Get the device's temporary directory to store the file
        final directory = await getApplicationDocumentsDirectory();
        // final filePath = '${directory.path}/${basename(storageRef.name)}';

        // Create the file on the device
        // final file = File(filePath);

        // Write the file data to local storage
        // await file.writeAsBytes(byteData);

        print('File downloaded and saved locally');
      }
    } catch (e) {
      print('Error downloading or storing file: $e');
    }
  }
}
