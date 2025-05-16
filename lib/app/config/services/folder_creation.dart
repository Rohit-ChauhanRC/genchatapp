import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:genchatapp/app/constants/constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;

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
      // print("Error creating folder structure: $e");
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
      // print("Error saving file: $e");
      return "error!";
    }
  }

  Future<String> saveFileFromFile({
    required String subFolder,
    required String fileName,
    required File sourceFile,
  }) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();

      final String subFolderPath = '${appDir.path}/$appName/$subFolder';

      final Directory dir = Directory(subFolderPath);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      final File destinationFile = File('$subFolderPath/$fileName');

      // Copy the file to the destination
      await sourceFile.copy(destinationFile.path);
      // print("Destination File Path:---------> ${destinationFile.path}");
      return destinationFile.path;
    } catch (e) {
      // print("Error saving file: $e");
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

  Future<String> getRootFolderPath() async {
    final directory = await getApplicationDocumentsDirectory();

    final filePath = "${directory.path}/$appName/";
    // print('RootFolderPath:---------> $filePath');
    return filePath;
  }

  Future<String?> checkAndHandleFile(
      {required String fileName,
      required String messageType,
      required String fileUrl}) async {
    try {
      final directory = await getApplicationDocumentsDirectory();

      final filePath = "${directory.path}/$appName/$fileName";

      if (await File(filePath).exists()) {
        return filePath;
      } else {
        final downloadedFilePath = await _downloadFile(fileUrl, filePath);
        return downloadedFilePath;
      }
    } catch (e) {
      // print("Error checking file existence: $e");
      return null;
    }
  }

  Future<String?> _downloadFile(String url, String savePath) async {
    try {
      // Perform the file download
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final file = File(savePath);
        await file.writeAsBytes(response.bodyBytes); // Save the file
        // print("File downloaded to $savePath");
        return savePath;
      } else {
        // print("Failed to download file: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      // print("Error downloading file: $e");
      return null;
    }
  }

  Future<void> clearMediaFiles() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    final String rootFolderPath = '${appDir.path}/$appName';

    final List<String> subFolders = [
      '$rootFolderPath/Database',
      '$rootFolderPath/Images',
      '$rootFolderPath/Videos',
      '$rootFolderPath/Audio',
      '$rootFolderPath/GIFs',
      '$rootFolderPath/Files',
      '$rootFolderPath/Backups',
    ];
    try {
      for (final folder in subFolders) {
        final Directory dir = Directory(folder);
        if (await dir.exists()) {
          List<FileSystemEntity> files = dir.listSync();
          for (FileSystemEntity file in files) {
            if (file is File &&
                (file.path.endsWith('.jpg') ||
                    file.path.endsWith('.png') ||
                    file.path.endsWith('.mp4') ||
                    file.path.endsWith('.mp3'))) {
              await file.delete();
              print('Deleted: ${file.path}');
            } else {
              print('Media directory does not exist.');
            }
          }
        } else {
          if (kDebugMode) {
            print(dir.path);
          }
        }
      }
      // Get the application's documents directory

      // Specify your media folder (change as needed)
      Directory mediaDir = Directory('${appDir.path}/media');

      // Check if the directory exists
    } catch (e) {
      print('Error clearing media files: $e');
    }
  }

  Future<bool> deleteFileByName({
    required String subFolder,
    required String fileName,
  }) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String filePath = '${appDir.path}/$appName/$subFolder/$fileName';

      final File file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        print('Deleted file: $filePath');
        return true;
      } else {
        print('File not found: $filePath');
        return false;
      }
    } catch (e) {
      print('Error deleting file: $e');
      return false;
    }
  }
}
