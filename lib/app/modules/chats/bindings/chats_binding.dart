import 'package:get/get.dart';

import '../controllers/chats_controller.dart';

class ChatsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ChatsController>(
      ChatsController(),
    );
  }
}
