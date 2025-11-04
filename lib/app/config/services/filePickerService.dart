import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:genchatapp/app/constants/message_enum.dart';
import 'package:genchatapp/app/utils/utils.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

class FilePickerService {
  final ImagePicker _picker = ImagePicker();

  /// Pick either image or video from camera (let user decide)
  /// Pick from camera (either image or fallback to video)
  Future<List<File>> pickFromCamera(BuildContext context) async {
    List<File> _files = [];

    final choice = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select media type'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, 'image'),
              child: const Text('Photo')),
          TextButton(
              onPressed: () => Navigator.pop(context, 'video'),
              child: const Text('Video')),
        ],
      ),
    );

    if (choice == 'image') {
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

        if (croppedFile != null) _files.add(File(croppedFile.path));
      }
    } else if (choice == 'video') {
      final video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 5),
      );
      if (video != null) _files.add(File(video.path));
    }

    return _files;
  }

  /// Pick multiple images/videos from gallery
  Future<List<File>> pickFromGallery() async {
    List<File> _imageFiles = [];

    final result = await FilePicker.platform.pickFiles(
      type: FileType.media, // This allows images & videos both
      allowMultiple: true,
    );
    if (result == null || result.files.isEmpty) return [];
    final f = result.paths
        .whereType<String>()
        .map((path) => File(path))
        .toList();
    for (var file in f) {
      if (getMessageType(file) == MessageType.image) {
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: file.path,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: Colors.deepOrange,
              toolbarWidgetColor: Colors.white,
              aspectRatioPresets: [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio16x9,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio5x3,
                CropAspectRatioPreset.ratio5x4,
                CropAspectRatioPreset.ratio7x5,
              ],
            ),
            IOSUiSettings(
              title: 'Cropper',
              aspectRatioPresets: [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
              ],
            ),
          ],
        );
        if (croppedFile != null) {
          _imageFiles.add(File(croppedFile.path));
        }
      } else if (getMessageType(file) == MessageType.video) {
        final sizeInBytes = await file.length();
        final sizeInMB = sizeInBytes / (1024 * 1024);
        if (sizeInMB >= 50) {
          showSnackBar(
            context: Get.context!,
            content:
                "The selected video is ${sizeInMB.toStringAsFixed(2)} MB. Please select a file under 50 MB.",
          );
        } else {
          _imageFiles.add(file);
        }
      } else {
        _imageFiles.add(file);
      }
    }
    return _imageFiles;
    // return result.paths.whereType<String>().map((path) => File(path)).toList();
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
}
