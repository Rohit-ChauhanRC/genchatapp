import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:genchatapp/app/constants/constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;

class FolderCreation {
  Future<void> createAppFolderStructure() async {
    try {
      // Get the app's internal storage directory

      final status = await Permission.storage.request();
      final statusAndroid = await Permission.manageExternalStorage.request();
      if (status.isGranted || statusAndroid.isGranted) {
        final Directory appDir = await getApplicationDocumentsDirectory();

        // Define the root folder
        final String rootFolderPath = '${appDir.path}/$appName';

        // Define subfolders
        final List<String> subFolders = [
          '$rootFolderPath/Database',
          '$rootFolderPath/Images',
          '$rootFolderPath/Videos',
          '$rootFolderPath/Audio',
          '$rootFolderPath/GIFs',
          '$rootFolderPath/Files',
          '$rootFolderPath/Backups',
        ];

        // Create the root and subfolders
        for (final folder in subFolders) {
          final Directory dir = Directory(folder);
          if (!await dir.exists()) {
            await dir.create(recursive: true);
          } else {
            if (kDebugMode) {
              print(dir.path);
            }
          }
        }
      } else {
        await Permission.storage.request();
        await Permission.manageExternalStorage.request();
      }
      // print("App folder structure created successfully.");
    } catch (e) {
      print("Error creating folder structure: $e");
    }
  }

  Future<String> saveFile({
    required String subFolder,
    required String fileName,
    required Uint8List fileBytes,
  }) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();

      final String subFolderPath = '${appDir.path}/$appName/$subFolder';

      final Directory dir = Directory(subFolderPath);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      final File file = File('$subFolderPath/$fileName');
      await file.writeAsBytes(fileBytes);
      // return file.path;
      return "$subFolderPath/$fileName";
    } catch (e) {
      print("Error saving file: $e");
      return "error!";
    }
  }

  String getImageName(String imagePath) {
    // Get the image file name with extension from the path
    return path.basename(imagePath); // e.g., "image.jpg"
  }

  String getImageExtension(String imagePath) {
    // Get the file extension
    return path.extension(imagePath); // e.g., ".jpg"
  }
}
