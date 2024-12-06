import 'package:genchatapp/app/routes/app_pages.dart';
import 'package:get/get.dart';

import '../../../services/shared_preference_service.dart';

class ChatsController extends GetxController {
  //
  final SharedPreferenceService sharedPreferenceService = Get.find<SharedPreferenceService>();

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
  }

  Future<void> logout() async{
    await sharedPreferenceService.clear().then((onValue){
      Get.offAllNamed(Routes.LANDING);
    });
  }
}
