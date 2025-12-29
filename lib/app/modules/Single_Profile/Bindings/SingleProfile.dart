import 'package:get/get.dart';

import '../Controller/SIngle_profile_controller.dart';

class SingleUserProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SingleProfileController>(
          () => SingleProfileController(),
      fenix: true,
    );
  }
}
