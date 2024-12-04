import 'package:get/get.dart';

import '../controllers/select_contacts_controller.dart';

class SelectContactsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SelectContactsController>(
      () => SelectContactsController(),
    );
  }
}
