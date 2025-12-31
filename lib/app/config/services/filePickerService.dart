import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:genchatapp/app/constants/message_enum.dart';
import 'package:genchatapp/app/utils/utils.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:v_video_compressor/v_video_compressor.dart';

import '../../utils/DocumentViewer.dart';

class FilePickerService {
  final ImagePicker _picker = ImagePicker();

  /// Pick either image or video from camera (let user decide)
  /// Pick from camera (either image or fallback to video)
  Future<List<File>> pickFromCamera(BuildContext context) async {
    List<File> _files = [];

    // Directly open CAMERA for IMAGE
    final image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      preferredCameraDevice: CameraDevice.rear,
    );

    if (image != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
            ],
          ),
          IOSUiSettings(title: 'Cropper'),
        ],
      );

      if (croppedFile != null) {
        _files.add(File(croppedFile.path));
      }
    }

    return _files;
  }

  Future<List<File>> pickFromVideoCamera(BuildContext context) async {
    List<File> _files = [];

    final choice = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select media type'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'video'),
            child: const Text('Video'),
          ),
        ],
      ),
    );

    if (choice == 'video') {
      final video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 5),
      );
      if (video != null) _files.add(File(video.path));
    }

    return _files;
  }

  /// Pick multiple images/videos from gallery
  // Future<List<File>> pickFromGallery() async {
  //   List<File> _imageFiles = [];

  //   final result = await FilePicker.platform.pickFiles(
  //     type: FileType.media, // This allows images & videos both
  //     allowMultiple: true,
  //   );
  //   if (result == null || result.files.isEmpty) return [];
  //   final f = result.paths
  //       .whereType<String>()
  //       .map((path) => File(path))
  //       .toList();
  //   for (var file in f) {
  //     if (getMessageType(file) == MessageType.image) {
  //       final croppedFile = await ImageCropper().cropImage(
  //         compressQuality: 70,
  //         sourcePath: file.path,
  //         uiSettings: [
  //           AndroidUiSettings(
  //             toolbarTitle: 'Cropper',
  //             toolbarColor: Colors.deepOrange,
  //             toolbarWidgetColor: Colors.white,
  //             aspectRatioPresets: [
  //               CropAspectRatioPreset.original,
  //               CropAspectRatioPreset.square,
  //               CropAspectRatioPreset.ratio16x9,
  //               CropAspectRatioPreset.ratio3x2,
  //               CropAspectRatioPreset.ratio4x3,
  //               CropAspectRatioPreset.ratio5x3,
  //               CropAspectRatioPreset.ratio5x4,
  //               CropAspectRatioPreset.ratio7x5,
  //             ],
  //           ),
  //           IOSUiSettings(
  //             title: 'Cropper',
  //             aspectRatioPresets: [
  //               CropAspectRatioPreset.original,
  //               CropAspectRatioPreset.square,
  //             ],
  //           ),
  //         ],
  //       );
  //       if (croppedFile != null) {
  //         _imageFiles.add(File(croppedFile.path));
  //       }
  //     } else if (getMessageType(file) == MessageType.video) {
  //       final sizeInBytes = await file.length();
  //       final sizeInMB = sizeInBytes / (1024 * 1024);

  //       if (sizeInMB >= 50) {
  //         showSnackBar(
  //           context: Get.context!,
  //           content:
  //               "The selected video is ${sizeInMB.toStringAsFixed(2)} MB. Please select a file under 50 MB.",
  //         );
  //       } else {
  //         _imageFiles.add(file);
  //       }
  //     } else {
  //       _imageFiles.add(file);
  //     }
  //   }
  //   return _imageFiles;
  //   // return result.paths.whereType<String>().map((path) => File(path)).toList();
  // }

  Future<List<File>> pickFromGallery() async {
    List<File> _imageFiles = [];

    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );

    if (result == null || result.files.isEmpty) return [];

    final startTime = DateTime.now();
    if (kDebugMode) {
    }

    final pickedFiles = result.paths
        .whereType<String>()
        .map((path) => File(path))
        .toList();

    for (var file in pickedFiles) {
      final type = getMessageType(file);
      if (type == MessageType.image) {
        final croppedFile = await ImageCropper().cropImage(
          compressQuality: 70,
          sourcePath: file.path,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: Colors.deepOrange,
              toolbarWidgetColor: Colors.white,
            ),
            IOSUiSettings(title: 'Cropper'),
          ],
        );

        if (croppedFile != null) {
          _imageFiles.add(File(croppedFile.path));
        }
      } else if (type == MessageType.video) {
        final endTime = DateTime.now();
        if (kDebugMode) {
        }

        final totalSeconds = endTime.difference(startTime).inSeconds;
        if (kDebugMode) {
        }
        final sizeInBytes = await file.length();
        final sizeInMB = sizeInBytes / (1024 * 1024);

        // if (sizeInMB >= 50) {
        //   showSnackBar(
        //     context: Get.context!,
        //     content:
        //         "The selected video is ${sizeInMB.toStringAsFixed(2)} MB. Please select a file under 50 MB.",
        //   );
        //   continue;
        // }

        if (sizeInMB >= 50) {
          try {
            final compressed = await VVideoCompressor().compressVideo(
              file.path,
              const VVideoCompressionConfig(
                quality: VVideoCompressQuality.low,
                deleteOriginal: false,
              ),
            );

            final endTime = DateTime.now();
            if (kDebugMode) {
            }

            final totalSeconds = endTime.difference(startTime).inSeconds;
            if (kDebugMode) {
            }
            final sizeInBytes1 = await File(
              compressed!.compressedFilePath,
            ).length();
            final sizeInMB1 = sizeInBytes1 / (1024 * 1024);
            if (kDebugMode) {
            }

            if (sizeInMB1 >= 50) {
              showSnackBar(
                context: Get.context!,
                content:
                    "The selected video is ${sizeInMB.toStringAsFixed(2)} MB. Please select a file under 50 MB.",
              );
              continue;
            }

            if (compressed != null &&
                compressed.compressedFilePath != null &&
                sizeInMB1 <= 50) {
              _imageFiles.add(File(compressed.compressedFilePath));
            } else {
              _imageFiles.add(file);
            }
          } catch (e) {
            // debugPrint("Compression failed: $e");
            _imageFiles.add(file);
          }
        } else {
          _imageFiles.add(file); // small → no compression
        }
      } else {
        _imageFiles.add(file);
      }
    }

    return _imageFiles;
  }

  Future<List<File>> pickVideoFromCamera() async {
    final pickedVideo = await ImagePicker().pickVideo(
      source: ImageSource.camera,
      maxDuration: const Duration(minutes: 5),
      preferredCameraDevice: CameraDevice.rear,
    );

    if (pickedVideo == null) return [];

    return [File(pickedVideo.path)];
  }
  // Future<List<File>> pickFromGalleryVideo() async {
  //   List<File> finalFiles = [];

  //   final XFile? pickedVideo = await ImagePicker().pickVideo(
  //     source: ImageSource.gallery,
  //     maxDuration: const Duration(minutes: 10), // optional
  //   );

  //   if (pickedVideo == null) return [];

  //   final File file = File(pickedVideo.path);

  //   final sizeInBytes = await file.length();
  //   final sizeInMB = sizeInBytes / (1024 * 1024);

  //   if (sizeInMB >= 50) {
  //     try {
  //       final compressed = await VVideoCompressor().compressVideo(
  //         file.path,
  //         const VVideoCompressionConfig(
  //           quality: VVideoCompressQuality.low,
  //           deleteOriginal: false,
  //         ),
  //       );

  //       if (compressed != null &&
  //           compressed.compressedFilePath.isNotEmpty) {
  //         final compressedFile = File(compressed.compressedFilePath);
  //         final compressedSizeMB =
  //             (await compressedFile.length()) / (1024 * 1024);

  //         if (compressedSizeMB > 50) {
  //           showSnackBar(
  //             context: Get.context!,
  //             content:
  //             "Video is ${compressedSizeMB.toStringAsFixed(2)}MB. Please select below 50MB.",
  //           );
  //         } else {
  //           finalFiles.add(compressedFile);
  //         }
  //       } else {
  //         finalFiles.add(file);
  //       }
  //     } catch (e) {
  //       debugPrint("Compression failed: $e");
  //       finalFiles.add(file);
  //     }
  //   } else {
  //     finalFiles.add(file);
  //   }

  //   return finalFiles;
  // }

  Future<List<File>> pickFromGalleryVideo() async {
    List<File> finalFiles = [];

    // Pick multiple videos
    final List<XFile>? pickedVideos = await ImagePicker().pickMultiVideo();

    if (pickedVideos == null || pickedVideos.isEmpty) return [];

    for (var xfile in pickedVideos) {
      final file = File(xfile.path);

      final sizeBytes = await file.length();
      final sizeMB = sizeBytes / (1024 * 1024);

      if (sizeMB >= 50) {
        try {
          final compressed = await VVideoCompressor().compressVideo(
            file.path,
            const VVideoCompressionConfig(
              quality: VVideoCompressQuality.low,
              deleteOriginal: false,
            ),
          );

          if (compressed != null) {
            final compressedFile = File(compressed.compressedFilePath);
            final compressedMB =
                (await compressedFile.length()) / (1024 * 1024);

            if (compressedMB <= 50) {
              finalFiles.add(compressedFile);
            } else {
              showSnackBar(
                context: Get.context!,
                content:
                    "Video is still ${compressedMB.toStringAsFixed(2)} MB. Choose under 50MB.",
              );
            }
          } else {
            finalFiles.add(file);
          }
        } catch (e) {
          // debugPrint("Compression failed: $e");
          finalFiles.add(file);
        }
      }
      // ─────────────────────────────
      // SMALL → DIRECT
      // ─────────────────────────────
      else {
        finalFiles.add(file);
      }
    }

    return finalFiles;
  }

  Future<List<File>> pickImagesFromGalleryWithCrop() async {
    List<File> resultFiles = [];

    final picked = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );

    if (picked == null || picked.files.isEmpty) return [];

    final paths = picked.paths.whereType<String>().toList();

    for (final path in paths) {
      final cropped = await ImageCropper().cropImage(
        sourcePath: path,
        compressQuality: 80,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.deepOrange,

            statusBarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            activeControlsWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            hideBottomControls: false,
          ),
          IOSUiSettings(title: 'Cropper'),
        ],
      );

      if (cropped != null) {
        resultFiles.add(File(cropped.path));
      }
    }

    return resultFiles;
  }

  /// Pick multiple documents (pdf, docx, etc.)
  Future<List<File>> pickDocuments() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: true,
      allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'txt', 'ppt'],
    );

    if (result == null || result.files.isEmpty) return [];

    return result.paths.whereType<String>().map((path) => File(path)).toList();
  }
  // Future<List<File>> pickDocuments() async {
  //   return await DocumentScannerService.scanDocuments();
  // }

  Future<List<File>> pickAudios() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: true,
      allowedExtensions: ['m4a', 'aac'],
    );

    if (result == null || result.files.isEmpty) return [];

    return result.paths.whereType<String>().map((path) => File(path)).toList();
  }
}
