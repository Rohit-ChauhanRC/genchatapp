import 'package:genchatapp/app/constants/constants.dart';
import 'package:genchatapp/app/routes/app_pages.dart';
import 'package:get/get.dart';

import '../../../services/shared_preference_service.dart';

class SplashController extends GetxController {
  final sharedPreferenceService = Get.find<SharedPreferenceService>();

  @override
  void onInit() {
    print("OnInit Called");
    navigateToHome();
    super.onInit();

  }
  bool? getIsNumVerified() {
    return sharedPreferenceService.getBool(isNumVerify);
  }

  void navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3));
    bool? isVerified = getIsNumVerified();
    if(isVerified == true){
      Get.offNamed(Routes.CREATE_PROFILE);
    }else{
      Get.offNamed(Routes.LANDING);
    }
  }
}
