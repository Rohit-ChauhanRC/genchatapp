import 'package:get/get.dart';

import '../controllers/forward_messages_controller.dart';

class ForwardMessagesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ForwardMessagesController>(
      () => ForwardMessagesController(),
    );
  }
}
