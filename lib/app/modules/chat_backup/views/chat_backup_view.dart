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
        title: Text(
          'Chat backup',
          style: TextStyle(
            fontSize: 18,
            color: AppColors.whiteColor,
            fontWeight: FontWeight.w400,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        final isBackingUp = controller.backupProgress.value > 0 &&
            controller.backupProgress.value < 1;
        return Stack(
          children: [
            GradientContainer(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Backup Path:",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(controller.backupPath.value,
                        style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 20),
                    const Text("Last Backup Time:",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(controller.lastBackupTime.value),
                    const SizedBox(height: 30),
                    const Text("Backup Size:",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(controller.backupSize.value),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: controller.createBackup,
                        icon: Icon(
                          Icons.cloud_upload,
                          color: AppColors.whiteColor,
                        ),
                        label: Text(
                          "Backup Now",
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.whiteColor,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                    Obx(() {
                      if (controller.backupProgress.value > 0 &&
                          controller.backupProgress.value < 1) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            LinearProgressIndicator(
                                value: controller.backupProgress.value),
                            const SizedBox(height: 8),
                            Text(
                                "Uploading ${controller.copiedFiles.value} of ${controller.totalFiles.value} files"),
                            const SizedBox(height: 20),
                          ],
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    }),
                  ],
                ),
              ),
            ),
            // POPUP LOADER UI
            if (isBackingUp)
              Container(
                color: Colors.black.withOpacity(0.5),
                alignment: Alignment.center,
                child: Container(
                  width: Get.width * 0.8,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Uploading Backup…",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: controller.backupProgress.value,
                        backgroundColor: Colors.grey[300],
                        minHeight: 6,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Uploaded ${controller.copiedFiles.value} of ${controller.totalFiles.value} files",
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "${controller.uploadedSizeMB.value} / ${controller.totalSizeMB.value}",
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      const CircularProgressIndicator(),
                    ],
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}
