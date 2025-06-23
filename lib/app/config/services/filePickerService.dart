import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class FilePickerService {
  final ImagePicker _picker = ImagePicker();

  /// Pick either image or video from camera (let user decide)
  /// Pick from camera (either image or fallback to video)
  Future<List<File>> pickFromCamera() async {
    List<File> _imageFiles = [];

    final image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      preferredCameraDevice: CameraDevice.rear,
    );

    if (image != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: File(image!.path).path,
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
        _imageFiles.add(File(croppedFile!.path));
      }
      return _imageFiles;
    }

    // final video = await _picker.pickVideo(source: ImageSource.camera);
    // if (video != null) return [File(video.path)];

    return [];
  }

  /// Pick multiple images/videos from gallery
  Future<List<File>> pickFromGallery() async {
    List<File> _imageFiles = [];

    final result = await FilePicker.platform.pickFiles(
      type: FileType.image, // This allows images & videos both
      allowMultiple: true,
    );
    if (result == null || result.files.isEmpty) return [];
    final f =
        result.paths.whereType<String>().map((path) => File(path)).toList();
    for (var file in f) {
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
        _imageFiles.add(File(croppedFile!.path));
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
