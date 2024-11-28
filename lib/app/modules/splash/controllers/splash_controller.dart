import 'package:genchatapp/app/routes/app_pages.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {

  final count = 0.obs;
  @override
  void onInit() {
    print("OnInit Called");
    navigateToHome();
    super.onInit();

  }

  void navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3));
    Get.offNamed(Routes.LANDING);
  }
}
