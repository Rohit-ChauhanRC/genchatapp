import 'package:genchatapp/app/common/user_defaults/user_defaults_keys.dart';
import 'package:genchatapp/app/constants/constants.dart';
import 'package:genchatapp/app/modules/chats/controllers/chats_controller.dart';
import 'package:genchatapp/app/routes/app_pages.dart';
import 'package:get/get.dart';

import '../../../services/shared_preference_service.dart';

class SplashController extends GetxController {
  final sharedPreferenceService = Get.find<SharedPreferenceService>();

  @override
  void onInit() {
    // sharedPreferenceService.setBool(createUserProfile, true);
    // sharedPreferenceService.setBool(isNumVerify, false);
    navigateToHome();
    super.onInit();
  }

  bool? getIsNumVerified() {
    return sharedPreferenceService.getBool(UserDefaultsKeys.isNumVerify);
  }

  bool? getIsCreateUserProfile() {
    return sharedPreferenceService.getBool(UserDefaultsKeys.createUserProfile);
  }

  void navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3));
    bool? isVerified = getIsNumVerified();
    bool? isCreatedUserProfile = getIsCreateUserProfile();
    if (isVerified == true) {
      Get.offNamed(Routes.CREATE_PROFILE, arguments: false);
    } else if (isCreatedUserProfile == true) {
      Get.put(ChatsController());
      Get.offNamed(Routes.HOME);
    } else {
      Get.offNamed(Routes.LANDING);
    }
  }
}
