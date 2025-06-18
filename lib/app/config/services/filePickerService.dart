import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

class FilePickerService {
  final ImagePicker _picker = ImagePicker();

  /// Pick either image or video from camera (let user decide)
  /// Pick from camera (either image or fallback to video)
  Future<List<File>> pickFromCamera() async {
    final image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      preferredCameraDevice: CameraDevice.rear,
    );

    if (image != null) return [File(image.path)];

    final video = await _picker.pickVideo(source: ImageSource.camera);
    if (video != null) return [File(video.path)];

    return [];
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

