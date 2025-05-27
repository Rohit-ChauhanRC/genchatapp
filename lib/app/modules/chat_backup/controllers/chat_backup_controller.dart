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

  Future<void> loadBackupInfo() async {
    final userId = sharedPref.getUserData()?.userId.toString();
    if (userId == null) return;

    final path = '/storage/emulated/0/GenChatBackup/genchat_$userId.db';
    backupPath.value = path;

    final file = File(path);
    final exists = await file.exists();
    backupExists.value = exists;

    if (exists) {
      final lastModified = await file.lastModified();
      lastBackupTime.value = DateFormat('yyyy-MM-dd – hh:mm a').format(lastModified);
    } else {
      lastBackupTime.value = "No backup found";
    }
  }

  Future<void> createBackup() async {
    try {
      dbService.setUserId(sharedPref.getString(UserDefaultsKeys.backupUserId).toString());
      await dbService.backupDatabase();
      await loadBackupInfo();
      showAlertMessage("Backup created successfully");
    } catch (e) {
      showAlertMessage("Backup failed");
      // Get.snackbar("Error", "");
    }
  }
}
