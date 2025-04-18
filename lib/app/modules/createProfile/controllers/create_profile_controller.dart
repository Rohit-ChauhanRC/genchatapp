import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:genchatapp/app/config/services/firebase_controller.dart';
import 'package:genchatapp/app/config/services/folder_creation.dart';
import 'package:genchatapp/app/data/repositories/profile/profile_repository.dart';
import 'package:genchatapp/app/modules/settings/controllers/settings_controller.dart';
import 'package:genchatapp/app/services/shared_preference_service.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../common/user_defaults/user_defaults_keys.dart';
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

  List<String> folderList = [
    "Media",
    "Database",
    "Backup",
    "Media/Profiles",
    "Media/Audio",
    "Media/Video",
    "Media/GIF",
    "Media/Images"
  ];

  @override
  void onInit() {
    super.onInit();
    folder.createAppFolderStructure();
    getUserData();
    isFromInsideApp = Get.arguments;
    // createAppFolders();
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

  // void createAppFolder(String folderName) async {
  //   final dir = Directory('${(await getApplicationSupportDirectory() //FOR IOS
  //       ).path}/$folderName');
  //   var status = await Permission.storage.status;
  //   if (!status.isGranted) {
  //     await Permission.storage.request();
  //   }
  //   if ((await dir.exists())) {
  //   } else {
  //     dir.create();
  //   }
  // }

  void createAppFolders() async {
    // print("CreateAppFolder Calls");
    final appDir = await getApplicationDocumentsDirectory();
    for (String folderPath in folderList) {
      // print("Call one by one $folderPath");
      final dir = Directory('${appDir.path}/GenChatApp/$folderPath');
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        // print(
        //     "calling for storage permission $status \n Directory path:---------> $dir");
        status = await Permission.storage.request();
        if (!status.isGranted) {
          // print("Storage permission denied. Cannot create folder: $folderPath");
          showPermissionDeniedDialog();
          continue; // Skip folder creation if permission is not granted
        }
      }
      if (!(await dir.exists())) {
        // print("creating folders");
        await dir.create(recursive: true);
      }
      // Verify folder creation
      if (await dir.exists()) {
        // print("Folder created successfully: $dir");
      } else {
        // print("Failed to create folder: $dir");
      }
    }
  }

  void showPermissionDeniedDialog() {
    Get.defaultDialog(
      title: "Permission Required",
      content: Text(
          "Storage permission is required to create necessary folders. Please grant the permission in the app settings."),
      textConfirm: "Open Settings",
      onConfirm: () async {
        await openAppSettings();
        Get.back();
      },
      textCancel: "Cancel",
      onCancel: () {
        Get.back();
      },
    );
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
        navigateBack();
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
          navigateBack();
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
}
