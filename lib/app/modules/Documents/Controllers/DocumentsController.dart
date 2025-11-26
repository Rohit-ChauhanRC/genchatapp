import 'dart:io';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import 'dart:io';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class DocumentPickerController extends GetxController {
  RxList<File> files = <File>[].obs;
  RxList<File> selected = <File>[].obs;
  RxBool isLoading = true.obs;

  final List<String> extensions = [
    'pdf', 'doc', 'docx', 'xls', 'xlsx', 'txt', 'ppt', 'pptx'
  ];

  @override
  void onInit() {
    super.onInit();
    fetchDocuments();
  }

  Future<bool> requestPermission() async {
    // Android 13+ uses different permissions
    if (Platform.isAndroid) {
      if (await Permission.manageExternalStorage.isGranted) return true;
      if (await Permission.manageExternalStorage.request().isGranted) return true;

      // Android 13+ fallback
      if (await Permission.photos.request().isGranted ||
          await Permission.videos.request().isGranted ||
          await Permission.audio.request().isGranted) {
        return true;
      }

      // Normal storage permission
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

    Directory root = Directory('/storage/emulated/0/');
    await scanFolder(root);

    isLoading.value = false;
  }

  Future<void> scanFolder(Directory dir) async {
    try {
      await for (var entity in dir.list(followLinks: false)) {
        final path = entity.path;

        // Skip restricted Android folders
        if (path.contains("/Android/data") || path.contains("/Android/obb")) {
          continue;
        }

        if (entity is Directory) {
          await scanFolder(entity);
        } else if (entity is File) {
          final ext = path.split('.').last.toLowerCase();
          if (extensions.contains(ext)) {
            files.add(entity);
          }
        }
      }
    } catch (_) {}
  }

  void toggleSelection(File file) {
    selected.contains(file)
        ? selected.remove(file)
        : selected.add(file);
  }
}
