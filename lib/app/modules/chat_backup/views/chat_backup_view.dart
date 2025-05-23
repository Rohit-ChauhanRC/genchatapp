import 'package:flutter/material.dart';
import 'package:genchatapp/app/common/widgets/gradient_container.dart';
import 'package:genchatapp/app/config/theme/app_colors.dart';

import 'package:get/get.dart';

import '../controllers/chat_backup_controller.dart';

class ChatBackupView extends GetView<ChatBackupController> {
  const ChatBackupView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.textBarColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('Chat backup', style: TextStyle(
          fontSize: 18,
          color: AppColors.whiteColor,
          fontWeight: FontWeight.w400,
        ),),
        centerTitle: true,
      ),
      body: Obx(() => GradientContainer(
        child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Backup Path:", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(controller.backupPath.value, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            const Text("Last Backup Time:", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(controller.lastBackupTime.value),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                onPressed: controller.createBackup,
                icon: Icon(Icons.cloud_upload, color: AppColors.whiteColor,),
                label: Text("Backup Now", style: TextStyle(
                  fontSize: 14,
                  color: AppColors.whiteColor,
                  fontWeight: FontWeight.w400,
                ),),
              ),
            ),
          ],
        ),
            ),
      )),
    );
  }
}
