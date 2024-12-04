import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:genchatapp/app/config/firebase_controller/firebase_controller.dart';
import 'package:genchatapp/app/constants/constants.dart';
import 'package:genchatapp/app/data/models/user_model.dart';
import 'package:genchatapp/app/services/shared_preference_service.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../routes/app_pages.dart';
import '../../../utils/utils.dart';

import 'package:path_provider/path_provider.dart';

class CreateProfileController extends GetxController {
  //

  final FirebaseController firebaseController =
      Get.put<FirebaseController>(FirebaseController());

  final sharedPreferenceService = Get.find<SharedPreferenceService>();

  GlobalKey<FormState>? createProfileKey = GlobalKey<FormState>();

  final Rx<File?> _image = Rx<File?>(null);
  File? get image => _image.value;
  set image(File? img) => _image.value = img;

  final RxString _profileName = ''.obs;
  String get profileName => _profileName.value;
  set profileName(String profileName) => _profileName.value = profileName;

  final RxString _email = ''.obs;
  String get email => _email.value;
  set email(String email) => _email.value = email;

  List folderList = [
    "GenchatApp Profile Photos",
    "GenchatApp Audio",
    "GenchatApp Video",
    "GenchatApp GIF",
    "GenchatApp Images"
  ];

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
    _profileName.close();
    _email.close();
  }

  void createAppFolder(String folderName) async {
    final dir = Directory('${(await getApplicationSupportDirectory() //FOR IOS
        ).path}/$folderName');
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    if ((await dir.exists())) {
    } else {
      dir.create();
    }
  }

  void selectImage() async {
    showImagePicker(onGetImage: (img) {
      if (img != null) {
        image = img;
      }
    });
  }

  void createProfile() async {
    String profileNam = profileName;
    String emailId = email;
    if (profileNam.isNotEmpty && emailId.isNotEmpty) {
      await validateProfileData();
    } else {
      showSnackBar(context: Get.context!, content: 'Fill out all the fields');
    }
  }

  Future validateProfileData() async {
    if (!createProfileKey!.currentState!.validate()) {
      return null;
    }
    Get.toNamed(Routes.HOME);
  }

  void storeUserData() async {
    var uid = sharedPreferenceService.getString(userUId);
    var mob = sharedPreferenceService.getString(userMob);

    String photoUrl =
        'https://png.pngitem.com/pimgs/s/649-6490124_katie-notopoulos-katienotopoulos-i-write-about-tech-round.png';

    if (image != null) {
      photoUrl = await firebaseController.storeFileToFirebase(
        file: image!,
        path: "profilePic/$uid",
      );

      var user = UserModel(
        name: profileName,
        uid: uid!,
        profilePic: photoUrl,
        isOnline: true,
        phoneNumber: mob!,
        groupId: [],
        email: email,
        fcmToken: "",
        lastSeen: DateTime.now().microsecondsSinceEpoch.toString(),
      );

      // createProfile

      firebaseController.setUserData(uid: uid, user: user).then((onValu) {
        sharedPreferenceService.setBool(createUserProfile, true);
        sharedPreferenceService.setBool(isNumVerify, false);
        sharedPreferenceService.setString(userDetail, user.toJson());
        // Future.delayed(const Duration(seconds: 1));
        Get.offNamed(Routes.HOME);
      });
    }
  }
}
