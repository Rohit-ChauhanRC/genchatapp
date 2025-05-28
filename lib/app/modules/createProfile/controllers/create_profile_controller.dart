import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:genchatapp/app/config/services/folder_creation.dart';
import 'package:genchatapp/app/data/repositories/profile/profile_repository.dart';
import 'package:genchatapp/app/modules/settings/controllers/settings_controller.dart';
import 'package:genchatapp/app/services/shared_preference_service.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../main.dart';
import '../../../common/user_defaults/user_defaults_keys.dart';
import '../../../data/local_database/local_database.dart';
import '../../../data/models/new_models/response_model/verify_otp_response_model.dart';
import '../../../routes/app_pages.dart';
import '../../../utils/alert_popup_utils.dart';
import '../../../utils/utils.dart';

import 'package:path_provider/path_provider.dart';

import '../../chats/controllers/chats_controller.dart';

class CreateProfileController extends GetxController {
  //

  final ProfileRepository profileRepository;

  CreateProfileController({required this.profileRepository});
  // final FirebaseController firebaseController =
  //     Get.put<FirebaseController>(FirebaseController());

  final sharedPreferenceService = Get.find<SharedPreferenceService>();

  final folder = Get.find<FolderCreation>();
  final dbService = Get.find<DataBaseService>();

  GlobalKey<FormState>? createProfileKey = GlobalKey<FormState>();

  final Rx<File?> _image = Rx<File?>(null);
  File? get image => _image.value;
  set image(File? img) => _image.value = img;

  final RxString _photoUrl = ''.obs;
  String get photoUrl => _photoUrl.value;
  set photoUrl(String photoUrl) => _photoUrl.value = photoUrl;

  final RxString _profileName = ''.obs;
  String get profileName => _profileName.value;
  set profileName(String pr) => _profileName.value = pr;

  final RxString _email = ''.obs;
  String get email => _email.value;
  set email(String email) => _email.value = email;

  final RxBool _circularProgress = false.obs;
  bool get circularProgress => _circularProgress.value;
  set circularProgress(bool v) => _circularProgress.value = v;

  bool isFromInsideApp = false;

  // StreamSubscription<UserModel>? _userDataSubscription;
  final TextEditingController profileNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    // folder.createAppFolderStructure();
    _checkAndRequestStoragePermissionOnce();
    getUserData();
    isFromInsideApp = Get.arguments;
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

  Future<void> _checkAndRequestStoragePermissionOnce() async {
    bool alreadyAsked =
        sharedPreferenceService.getBool(UserDefaultsKeys.permissionAsked) ??
            false;

    if (!alreadyAsked) {
      // Delay to let UI build before showing dialog
      await Future.delayed(Duration(milliseconds: 300));

      Get.dialog(
        WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title: Text(
              "Contacts and Media",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            content: const Text(
                "To easily send messages and photos to friends and family, allow GenChat to access your contacts, photo"
                " and other media.",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
            actions: [
              TextButton(
                onPressed: () async {
                  Get.back(); // Close dialog
                  final status = await Permission.storage.request();
                  final statusAndroid =
                      await Permission.manageExternalStorage.request();

                  if (status.isGranted || statusAndroid.isGranted) {
                    await folder
                        .createAppFolderStructure(); // 👈 your existing method
                  }

                  sharedPreferenceService.setBool(
                      UserDefaultsKeys.permissionAsked, true);
                },
                child: const Text("Continue"),
              ),
            ],
          ),
        ),
        barrierDismissible: false, // 👈 prevent closing with tap outside
      );
    } else {
      // If already asked and permission granted, auto create folders
      final status = await Permission.storage.status;
      final statusAndroid = await Permission.manageExternalStorage.status;
      if (status.isGranted || statusAndroid.isGranted) {
        await folder.createAppFolderStructure();
      }
    }
  }

  void selectImage() async {
    showImagePicker(onGetImage: (img) {
      if (img != null) {
        image = img;
      }
    });
  }

  void getUserData() async {
    UserData? userData = sharedPreferenceService.getUserData();

    // print("📢 Fetched User Data: $userData"); // Debugging Log

    profileName = userData?.name ?? "";
    email = userData?.email ?? '';

    profileNameController.text = profileName;
    emailController.text = email;

    photoUrl = userData?.displayPictureUrl ?? '';

    // print("📢 Profile Name: $profileName, Email: $email, Photo URL: $photoUrl");
    // ✅ Set up the database with the user-specific ID
    if (userData?.userId != null) {
       sharedPreferenceService.setString(UserDefaultsKeys.backupUserId, userData!.userId.toString());
      dbService
          .setUserId(userData.userId.toString()); // Set before accessing DB
      await dbService.database; // Ensures DB is initialized
    } else {
      print("⚠️ No user ID found, DB not initialized.");
    }
  }

  Future<void> updateProfile() async {
    if (!createProfileKey!.currentState!.validate()) return;

    circularProgress = true;
    update();

    try {
      String? uploadedImageUrl;
      File? processedImage;

      /// ✅ Step 1: Upload Image if Changed
      if (image != null) {
        processedImage = image!;
        final uploadResponse =
            await profileRepository.uploadProfilePicture(processedImage);

        if (uploadResponse?.statusCode == 200) {
          final result = VerifyOtpResponseModel.fromJson(uploadResponse!.data);
          if (result.status == true) {
            final user = result.data?.userData;
            uploadedImageUrl = user?.displayPictureUrl;
            // print("✅ Profile picture uploaded: $uploadedImageUrl");

            if (user != null) {
              await sharedPreferenceService.setString(
                  UserDefaultsKeys.userDetail, userDataToJson(user));
            }
          }
        } else {
          showAlertMessage('Failed to upload profile picture.');
          return;
        }
      }

      /// ✅ Step 2: Check if Name/Email Changed
      final storedUserData = sharedPreferenceService.getUserData();
      final nameChanged =
          profileNameController.text.trim() != storedUserData?.name;
      final emailChanged = emailController.text.trim() != storedUserData?.email;

      if (!nameChanged && !emailChanged) {
        // navigateBack();
        checkAndPromptForBackup();
        return;
      }

      /// ✅ Step 3: Update User Details
      final updateResponse = await profileRepository.updateUserDetails(
        name: profileNameController.text.trim(),
        email: emailController.text.trim(),
      );

      if (updateResponse?.statusCode == 200) {
        final result = VerifyOtpResponseModel.fromJson(updateResponse!.data);
        if (result.status == true) {
          final user = result.data?.userData;
          uploadedImageUrl = user?.displayPictureUrl;
          // print("✅ Profile updated successfully: $uploadedImageUrl");

          if (user != null) {
            await sharedPreferenceService.setString(
                UserDefaultsKeys.userDetail, userDataToJson(user));
          }

          showAlertMessage('Profile updated successfully!');
          // navigateBack();
          checkAndPromptForBackup();
        } else {
          showAlertMessage('Failed to update profile.');
        }
      } else {
        showAlertMessage('Failed to update profile.');
      }
    } catch (e) {
      // print("🔥 Error updating profile: $e");
      showAlertMessage('Something went wrong. Please try again.');
    } finally {
      circularProgress = false;
      update(); // if you're using GetBuilder or Obx
    }
  }

  /// ✅ Navigate Back Based on Where the User Came From
  void navigateBack() {
    if (isFromInsideApp) {
      SettingsController settingsController = Get.find<SettingsController>();
      settingsController.isRefreshed();
      Get.until((route) => route.settings.name == Routes.SETTINGS);
    } else {
      sharedPreferenceService.setBool(UserDefaultsKeys.createUserProfile, true);
      sharedPreferenceService.setBool(UserDefaultsKeys.isNumVerify, false);
      Get.offAllNamed(Routes.HOME);
    }
  }

  Future<void> checkAndPromptForBackup() async {
    final hasBackup = await dbService.hasBackup();
    if (hasBackup && !isFromInsideApp) {
      showAlertMessageWithAction(
          title: "Backup Found",
          message:
              "A backup exists for this user. Would you like to restore it?",
          cancelText: "Skip",
          confirmText: "Restore",
          showCancel: true,
          onCancel: () {
            Get.back();
            navigateBack();
          },
          onConfirm: () async {
            Get.back();
            try {
              await dbService.restoreDatabase();
              showAlertMessage("Backup restored successfully.");
            } catch (e) {
              showAlertMessage("Failed to restore backup.");
            }finally {
              navigateBack();  // ✅ Move ahead after restore (success or fail)
            }
          },
          context: navigatorKey.currentContext!);
    }else{
      navigateBack();
    }
  }
}
