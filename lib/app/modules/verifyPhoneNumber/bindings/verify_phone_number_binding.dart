import 'package:genchatapp/app/network/api_client.dart';
import 'package:get/get.dart';

import '../../../data/repositories/auth/auth_repository.dart';
import '../controllers/verify_phone_number_controller.dart';

class VerifyPhoneNumberBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(()=>ApiClient());
    Get.lazyPut(() => AuthRepository(apiClient: Get.find(), sharedPreferences: Get.find()));
    Get.lazyPut<VerifyPhoneNumberController>(
      () => VerifyPhoneNumberController(authRepository: Get.find()),
    );
  }
}
