import 'package:genchatapp/app/data/repositories/profile/profile_repository.dart';
import 'package:get/get.dart';

import '../../../network/api_client.dart';
import '../controllers/create_profile_controller.dart';

class CreateProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(()=>ApiClient());
    Get.lazyPut(() => ProfileRepository(apiClient: Get.find()));
    Get.lazyPut<CreateProfileController>(
      () => CreateProfileController(profileRepository: Get.find()),
    );
  }
}
