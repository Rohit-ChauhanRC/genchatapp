import 'package:get/get.dart';

import '../controllers/group_chats_controller.dart';

class GroupChatsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GroupChatsController>(
      () => GroupChatsController(),
    );
  }
}
