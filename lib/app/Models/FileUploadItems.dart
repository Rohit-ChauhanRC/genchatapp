import 'dart:io';
import 'package:get/get.dart';

import '../constants/message_enum.dart';

class FileUploadItem {
  final File file;
  final MessageType type;
  final RxDouble progress;

  FileUploadItem({
    required this.file,
    required this.type,
    required this.progress,
  });
}
