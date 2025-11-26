import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
class DocumentScannerService {
  static Future<List<File>> scanDocuments() async {
    // Request permissions
    var status = await Permission.manageExternalStorage.request();
    if (!status.isGranted) {
      status = await Permission.storage.request();
      if (!status.isGranted) return [];
    }

    List<String> extensions = [
      'pdf', 'doc', 'docx', 'xls', 'xlsx', 'txt', 'ppt', 'pptx'
    ];

    Directory root = Directory('/storage/emulated/0/');

    List<File> results = [];

    Future<void> scanFolder(Directory dir) async {
      try {
        await for (var entity in dir.list(followLinks: false)) {
          final path = entity.path;

          if (entity is Directory) {
            if (path.contains("/Android/data") || path.contains("/Android/obb")) {
              continue;
            }
            await scanFolder(entity); // manually recurse
          }

          if (entity is File) {
            final ext = path.split('.').last.toLowerCase();
            if (extensions.contains(ext)) {
              results.add(entity);
            }
          }
        }
      } catch (e) {
        // Ignore permission denied folders
      }
    }

    await scanFolder(root);

    return results;
  }
}
