import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

class FilePickerService {
  final ImagePicker _picker = ImagePicker();

  /// Pick either image or video from camera (let user decide)
  Future<List<File>> pickFromCamera() async {
    // Camera cannot choose both media types in one prompt, so we prompt twice
    final media = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      preferredCameraDevice: CameraDevice.rear,
    );

    // If media is null, fallback to video (or prompt separately if needed)
    if (media == null) {
      final video = await _picker.pickVideo(source: ImageSource.camera);
      if (video != null) return [File(video.path)];
      return [];
    }

    return [File(media.path)];
  }

  /// Pick multiple images/videos from gallery
  Future<List<File>> pickFromGallery() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.media, // This allows images & videos both
      allowMultiple: true,
    );

    if (result == null || result.files.isEmpty) return [];

    return result.paths.whereType<String>().map((path) => File(path)).toList();
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

