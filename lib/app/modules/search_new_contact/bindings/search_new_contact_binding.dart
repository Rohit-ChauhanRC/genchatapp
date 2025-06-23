import 'package:get/get.dart';

import '../controllers/search_new_contact_controller.dart';

class SearchNewContactBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SearchNewContactController>(
      () => SearchNewContactController(),
    );
  }
}
