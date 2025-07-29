import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:genchatapp/app/constants/constants.dart';
import 'package:genchatapp/app/modules/group_chats/controllers/group_chats_controller.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;

import '../../modules/singleChat/controllers/single_chat_controller.dart';

class FolderCreation {
  Future<void> createAppFolderStructure() async {
    try {
      // Get the app's internal storage directory

      final status = await Permission.storage.request();
      final statusAndroid = await Permission.manageExternalStorage.request();
      if (status.isGranted || statusAndroid.isGranted) {
        // final Directory appDir = await getApplicationDocumentsDirectory();
        final Directory appDir;
        if (Platform.isAndroid) {
          appDir = Directory("/storage/emulated/0/Android/media");
        } else {
          appDir = await getApplicationDocumentsDirectory();
        }

        // Define the root folder
        final String rootFolderPath = '${appDir.path}/$appPackageName/$appName';

        // Define subfolders
        final List<String> subFolders = [
          '$rootFolderPath/Database',
          '$rootFolderPath/Image',
          '$rootFolderPath/Video',
          '$rootFolderPath/Audio',
          '$rootFolderPath/GIFs',
          '$rootFolderPath/Document',
          '$rootFolderPath/Backups',
          '$rootFolderPath/Thumbnail',
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
      // final Directory appDir = await getApplicationDocumentsDirectory();
      final Directory appDir;
      if (Platform.isAndroid) {
        appDir = Directory("/storage/emulated/0/Android/media");
      } else {
        appDir = await getApplicationDocumentsDirectory();
      }
      final String subFolderPath =
          '${appDir.path}/$appPackageName/$appName/$subFolder';

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
      // final Directory appDir = await getApplicationDocumentsDirectory();
      final Directory appDir;
      if (Platform.isAndroid) {
        appDir = Directory("/storage/emulated/0/Android/media");
      } else {
        appDir = await getApplicationDocumentsDirectory();
      }

      final String subFolderPath =
          '${appDir.path}/$appPackageName/$appName/$subFolder';

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
    // final directory = await getApplicationDocumentsDirectory();
    final Directory directory;
    if (Platform.isAndroid) {
      directory = Directory("/storage/emulated/0/Android/media");
    } else {
      directory = await getApplicationDocumentsDirectory();
    }
    final filePath = "${directory.path}/$appPackageName/$appName/";
    // print('RootFolderPath:---------> $filePath');
    return filePath;
  }

  Future<String?> checkAndHandleFile({
    required String fileName,
    required String subFolderName,
    required String messageType,
    required String fileUrl,
    void Function(int received, int total)? onReceiveProgress,
    void Function()? onCancel,
  }) async {
    try {
      // final directory = await getApplicationDocumentsDirectory();
      final Directory directory;
      if (Platform.isAndroid) {
        directory = Directory("/storage/emulated/0/Android/media");
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      final filePath =
          "${directory.path}/$appPackageName/$appName/$subFolderName/$fileName";

      if (await File(filePath).exists()) {
        return filePath;
      } else {
        final downloadedFilePath = await _downloadFile(
          fileUrl,
          filePath,
          fileName,
          onReceiveProgress,
          onCancel,
        );
        return downloadedFilePath;
      }
    } catch (e) {
      // print("Error checking file existence: $e");
      return null;
    }
  }

  Future<String?> _downloadFile(
    String url,
    String savePath,
    String fileName,
    void Function(int received, int total)? onReceiveProgress,
    Function()? onCancel,
  ) async {
    final completer = Completer<String?>();
    try {
      // Perform the file download
      // final response = await http.get(Uri.parse(url));
      final uri = Uri.parse(url);
      final request = http.Request('GET', uri);
      final response = await request.send();
      if (response.statusCode == 200) {
        final file = File(savePath);
        final sink = file.openWrite();
        final contentLength = response.contentLength ?? 0;
        int received = 0;

        final sub = response.stream.listen(
          (chunk) {
            received += chunk.length;
            sink.add(chunk);
            if (onReceiveProgress != null) {
              onReceiveProgress(received, contentLength);
            }
          },
          onDone: () async {
            try {
              await sink.flush();
              await sink.close();

              if (received < contentLength) {
                if (await file.exists()) await file.delete();
                completer.complete(null);
              } else {
                completer.complete(savePath);
              }
            } catch (e) {
              completer.complete(null);
            }

            Get.find<SingleChatController>().activeDownloads.remove(fileName);
          },
          onError: (e) async {
            await sink.close();
            try {
              if (await file.exists()) await file.delete();
            } catch (_) {}
            onCancel?.call();
            completer.complete(null);

            Get.find<SingleChatController>().activeDownloads.remove(fileName);
          },
          cancelOnError: true,
        );
        Get.find<SingleChatController>().activeDownloads[fileName] = sub;

        // return savePath;
        // await file.writeAsBytes(response.bodyBytes); // Save the file
        // print("File downloaded to $savePath");
        // return savePath;
      } else {
        // print("Failed to download file: ${response.statusCode}");
        completer.complete(null);
      }
    } catch (e) {
      // print("Error downloading file: $e");
      completer.complete(null);
    }
    return completer.future;
  }

  Future<void> clearMediaFiles() async {
    // Directory appDir = await getApplicationDocumentsDirectory();
    final Directory appDir;
    if (Platform.isAndroid) {
      appDir = Directory("/storage/emulated/0/Android/media");
    } else {
      appDir = await getApplicationDocumentsDirectory();
    }
    final String rootFolderPath = '${appDir.path}/$appPackageName/$appName';

    final List<String> subFolders = [
      '$rootFolderPath/Database',
      '$rootFolderPath/Image',
      '$rootFolderPath/Video',
      '$rootFolderPath/Audio',
      '$rootFolderPath/GIFs',
      '$rootFolderPath/Document',
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
      // final Directory appDir = await getApplicationDocumentsDirectory();
      final Directory appDir;
      if (Platform.isAndroid) {
        appDir = Directory("/storage/emulated/0/Android/media");
      } else {
        appDir = await getApplicationDocumentsDirectory();
      }
      final String filePath =
          '${appDir.path}/$appPackageName/$appName/$subFolder/$fileName';

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

  Future<String?> checkAndHandleFileFromGroup({
    required String fileName,
    required String subFolderName,
    required String messageType,
    required String fileUrl,
    void Function(int received, int total)? onReceiveProgress,
    void Function()? onCancel,
  }) async {
    try {
      // final directory = await getApplicationDocumentsDirectory();
      final Directory directory;
      if (Platform.isAndroid) {
        directory = Directory("/storage/emulated/0/Android/media");
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      final filePath =
          "${directory.path}/$appPackageName/$appName/$subFolderName/$fileName";

      if (await File(filePath).exists()) {
        return filePath;
      } else {
        final downloadedFilePath = await _downloadFileFromGroup(
          fileUrl,
          filePath,
          fileName,
          onReceiveProgress,
          onCancel,
        );
        return downloadedFilePath;
      }
    } catch (e) {
      // print("Error checking file existence: $e");
      return null;
    }
  }

  Future<String?> _downloadFileFromGroup(
    String url,
    String savePath,
    String fileName,
    void Function(int received, int total)? onReceiveProgress,
    Function()? onCancel,
  ) async {
    final completer = Completer<String?>();
    try {
      // Perform the file download
      // final response = await http.get(Uri.parse(url));
      final uri = Uri.parse(url);
      final request = http.Request('GET', uri);
      final response = await request.send();
      if (response.statusCode == 200) {
        final file = File(savePath);
        final sink = file.openWrite();
        final contentLength = response.contentLength ?? 0;
        int received = 0;

        final sub = response.stream.listen(
          (chunk) {
            received += chunk.length;
            sink.add(chunk);
            if (onReceiveProgress != null) {
              onReceiveProgress(received, contentLength);
            }
          },
          onDone: () async {
            try {
              await sink.flush();
              await sink.close();

              if (received < contentLength) {
                if (await file.exists()) await file.delete();
                completer.complete(null);
              } else {
                completer.complete(savePath);
              }
            } catch (e) {
              completer.complete(null);
            }

            Get.find<GroupChatsController>().activeDownloads.remove(fileName);
          },
          onError: (e) async {
            await sink.close();
            try {
              if (await file.exists()) await file.delete();
            } catch (_) {}
            onCancel?.call();
            completer.complete(null);

            Get.find<GroupChatsController>().activeDownloads.remove(fileName);
          },
          cancelOnError: true,
        );
        Get.find<GroupChatsController>().activeDownloads[fileName] = sub;

        // return savePath;
        // await file.writeAsBytes(response.bodyBytes); // Save the file
        // print("File downloaded to $savePath");
        // return savePath;
      } else {
        // print("Failed to download file: ${response.statusCode}");
        completer.complete(null);
      }
    } catch (e) {
      // print("Error downloading file: $e");
      completer.complete(null);
    }
    return completer.future;
  }

  //  group
}
