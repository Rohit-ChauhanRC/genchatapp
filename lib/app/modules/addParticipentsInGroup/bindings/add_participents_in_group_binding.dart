import 'package:get/get.dart';

import '../controllers/add_participents_in_group_controller.dart';

class AddParticipentsInGroupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddParticipentsInGroupController>(
      () => AddParticipentsInGroupController(),
    );
  }
}
