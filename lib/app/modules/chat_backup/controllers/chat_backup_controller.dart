import 'dart:io';

import 'package:genchatapp/app/common/user_defaults/user_defaults_keys.dart';
import 'package:genchatapp/app/utils/alert_popup_utils.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../data/local_database/local_database.dart';
import '../../../services/shared_preference_service.dart';

class ChatBackupController extends GetxController {
  final dbService = Get.find<DataBaseService>();
  final sharedPref = Get.find<SharedPreferenceService>();

  final backupExists = false.obs;
  final backupPath = ''.obs;
  final lastBackupTime = ''.obs;

  final RxDouble backupProgress = 0.0.obs;
  final RxInt totalFiles = 0.obs;
  final RxInt copiedFiles = 0.obs;

  final RxString backupSize = ''.obs;

  final RxString uploadedSizeMB = '0.00 MB'.obs;
  final RxString totalSizeMB = '0.00 MB'.obs;



  @override
  void onInit() {
    super.onInit();
    loadBackupInfo();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  // Future<void> loadBackupInfo() async {
  //   final userId = sharedPref.getUserData()?.userId.toString();
  //   if (userId == null) return;
  //
  //   final path = '/storage/emulated/0/GenChatBackup/genchat_$userId.db';
  //   backupPath.value = path;
  //
  //   final file = File(path);
  //   final exists = await file.exists();
  //   backupExists.value = exists;
  //
  //   if (exists) {
  //     final lastModified = await file.lastModified();
  //     lastBackupTime.value = DateFormat('yyyy-MM-dd – hh:mm a').format(lastModified);
  //   } else {
  //     lastBackupTime.value = "No backup found";
  //   }
  // }
  Future<void> loadBackupInfo() async {
    final userId = sharedPref.getUserData()?.userId.toString();
    if (userId == null) return;

    final backupDir = Directory('/storage/emulated/0/GenChatBackup/$userId');
    final dbFile = File('${backupDir.path}/genchat_$userId.db');

    backupPath.value = backupDir.path;

    final exists = await dbFile.exists();
    backupExists.value = exists;

    if (exists) {
      final lastModified = await dbFile.lastModified();
      lastBackupTime.value = DateFormat('yyyy-MM-dd – hh:mm a').format(lastModified);
    } else {
      lastBackupTime.value = "No backup found";
    }

    // Optional: Show total size of backup (DB + media files)
    if (await backupDir.exists()) {
      final totalBytes = await _getFolderSize(backupDir);
      final sizeInMB = (totalBytes / (1024 * 1024)).toStringAsFixed(2);
      print('Backup size: $sizeInMB MB');
      backupSize.value = '$sizeInMB MB';

      // You can expose it with an RxString like: backupSize.value = '$sizeInMB MB';
    }
  }

  Future<int> _getFolderSize(Directory dir) async {
    int size = 0;
    try {
      await for (final entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          size += await entity.length();
        }
      }
    } catch (e) {
      print("Error calculating folder size: $e");
    }
    return size;
  }

  Future<void> createBackup() async {
    try {
      backupProgress.value = 0;
      copiedFiles.value = 0;
      totalFiles.value = 0;
      uploadedSizeMB.value = '0.00 MB';
      totalSizeMB.value = '0.00 MB';

      dbService.setUserId(sharedPref.getString(UserDefaultsKeys.backupUserId).toString());

      await dbService.backupAllData(onProgress: (done, total, uploadedBytes, totalBytes) {
        copiedFiles.value = done;
        totalFiles.value = total;
        backupProgress.value = done / total;
        uploadedSizeMB.value = (uploadedBytes / (1024 * 1024)).toStringAsFixed(2) + ' MB';
        totalSizeMB.value = (totalBytes / (1024 * 1024)).toStringAsFixed(2) + ' MB';
      });

      await loadBackupInfo();
      showAlertMessage("Backup completed!");
    } catch (e) {
      showAlertMessage("Backup failed: $e");
    }
  }

  // Future<void> createBackup() async {
  //   try {
  //     dbService.setUserId(sharedPref.getString(UserDefaultsKeys.backupUserId).toString());
  //     await dbService.backupAllData();
  //     await loadBackupInfo();
  //     showAlertMessage("Backup created successfully");
  //   } catch (e) {
  //     showAlertMessage("Backup failed");
  //     // Get.snackbar("Error", "");
  //   }
  // }
}
