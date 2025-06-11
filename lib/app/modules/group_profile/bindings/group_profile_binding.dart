import 'package:get/get.dart';

import '../controllers/group_profile_controller.dart';

class GroupProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GroupProfileController>(
      () => GroupProfileController(),
    );
  }
}
