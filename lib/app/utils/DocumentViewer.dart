// import 'dart:io';
// import 'package:permission_handler/permission_handler.dart';
// class DocumentScannerService {
//   static Future<List<File>> scanDocuments() async {
//     // Request permissions
//     var status = await Permission.manageExternalStorage.request();
//     if (!status.isGranted) {
//       status = await Permission.storage.request();
//       if (!status.isGranted) return [];
//     }

//     List<String> extensions = [
//       'pdf', 'doc', 'docx', 'xls', 'xlsx', 'txt', 'ppt', 'pptx'
//     ];

//     Directory root = Directory('/storage/emulated/0/');

//     List<File> results = [];

//     Future<void> scanFolder(Directory dir) async {
//       try {
//         await for (var entity in dir.list(followLinks: false)) {
//           final path = entity.path;

//           if (entity is Directory) {
//             if (path.contains("/Android/data") || path.contains("/Android/obb")) {
//               continue;
//             }
//             await scanFolder(entity); // manually recurse
//           }

//           if (entity is File) {
//             final ext = path.split('.').last.toLowerCase();
//             if (extensions.contains(ext)) {
//               results.add(entity);
//             }
//           }
//         }
//       } catch (e) {
//         // Ignore permission denied folders
//       }
//     }

//     await scanFolder(root);

//     return results;
//   }
// }
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

// class DocumentScannerService {
//   static Future<List<File>> scanDocuments() async {
//     List<String> extensions = [
//       'pdf',
//       'doc',
//       'docx',
//       'xls',
//       'xlsx',
//       'txt',
//       'ppt',
//       'pptx',
//     ];
//
//     // PLATFORM CHECK
//     if (Platform.isAndroid) {
//       return _scanAndroid(extensions);
//     } else if (Platform.isIOS) {
//       return _scanIOS(extensions);
//     }
//
//     return [];
//   }
//
//   // ---------------------------------------------------------
//   // ANDROID
//   // ---------------------------------------------------------
//   static Future<List<File>> _scanAndroid(List<String> extensions) async {
//     // Android 13+ permissions
//     await [
//       Permission.storage,
//       Permission.photos,
//       Permission.videos,
//       Permission.audio,
//     ].request();
//
//     // For older devices also request storage
//     if (!await Permission.storage.isGranted) {
//       return [];
//     }
//
//     // safer root directory for Android
//     Directory? root = Directory('/storage/emulated/0/');
//
//     List<File> results = [];
//
//     Future<void> scanFolder(Directory dir) async {
//       try {
//         await for (var entity in dir.list(followLinks: false)) {
//           final path = entity.path;
//
//           if (entity is Directory) {
//             // skip protected Android system folders
//             if (path.contains("/Android/data") ||
//                 path.contains("/Android/obb")) {
//               continue;
//             }
//             await scanFolder(entity);
//           }
//
//           if (entity is File) {
//             final ext = path.split('.').last.toLowerCase();
//             if (extensions.contains(ext)) {
//               results.add(entity);
//             }
//           }
//         }
//       } catch (e) {
//         // ignore folders without permission
//       }
//     }
//
//     await scanFolder(root);
//     return results;
//   }
//
//   // ---------------------------------------------------------
//   // iOS
//   // ---------------------------------------------------------
//   static Future<List<File>> _scanIOS(List<String> extensions) async {
//     final dir = await getApplicationDocumentsDirectory();
//     List<File> results = [];
//
//     Future<void> scanFolder(Directory dir) async {
//       await for (var entity in dir.list(recursive: true)) {
//         if (entity is File) {
//           final path = entity.path;
//           final ext = path.split('.').last.toLowerCase();
//           if (extensions.contains(ext)) {
//             results.add(entity);
//           }
//         }
//       }
//     }
//
//     await scanFolder(dir);
//     return results;
//   }
// }
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