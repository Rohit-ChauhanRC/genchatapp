import 'package:get/get.dart';

import '../controllers/chat_backup_controller.dart';

class ChatBackupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatBackupController>(
      () => ChatBackupController(),
    );
  }
}
