import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class DocumentPickerController extends GetxController {
  RxList<String> files = <String>[].obs;
  RxList<String> selected = <String>[].obs;
  RxBool isLoading = true.obs;
  final List<String> extensions = [
    'pdf', 'doc', 'docx', 'xls', 'xlsx', 'txt', 'ppt', 'pptx', 'zip', 'rar'
  ];
  @override
  void onInit() {
    super.onInit();
    fetchDocuments();
  }

  Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      if (await Permission.manageExternalStorage.isGranted) return true;
      if (await Permission.manageExternalStorage.request().isGranted) return true;
      if (await Permission.photos.request().isGranted ||
          await Permission.videos.request().isGranted ||
          await Permission.audio.request().isGranted) return true;

      if (await Permission.storage.isGranted) return true;
      if (await Permission.storage.request().isGranted) return true;
    }
    return false;
  }

  Future<void> fetchDocuments() async {
    isLoading.value = true;
    files.clear();
    selected.clear();

    bool granted = await requestPermission();
    if (!granted) {
      isLoading.value = false;
      return;
    }

    await scanFolder(Directory('/storage/emulated/0/'));

    isLoading.value = false;
  }

  Future<void> scanFolder(Directory dir) async {
    try {
      await for (var entity in dir.list(followLinks: false)) {
        final path = entity.path;

        if (path.contains("/Android/data") || path.contains("/Android/obb")) {
          continue;
        }

        if (entity is Directory) {
          await scanFolder(entity);
        } else if (entity is File) {
          String ext = path.split('.').last.toLowerCase();
          if (extensions.contains(ext)) {
            files.add(path);
          }
        }
      }
    } catch (_) {}
  }
  void toggleSelection(String path) {
    // If already selected → allow unselect
    if (selected.contains(path)) {
      selected.remove(path);
      return;
    }

    if (selected.length >= 5) {
      Get.snackbar(
        "Limit Reached",
        "You can select only up to 5 documents.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
      return;
    }

    // Add new selection
    selected.add(path);
  }

}
