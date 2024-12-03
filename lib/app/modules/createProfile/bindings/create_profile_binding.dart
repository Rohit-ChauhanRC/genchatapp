import 'package:get/get.dart';

import '../controllers/create_profile_controller.dart';

class CreateProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateProfileController>(
      () => CreateProfileController(),
    );
  }
}
