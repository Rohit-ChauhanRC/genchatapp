import 'dart:io';
import 'package:flutter/material.dart';
import 'package:genchatapp/app/config/theme/app_colors.dart';
import 'package:genchatapp/app/utils/alert_popup_utils.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:open_file/open_file.dart';

class DocumentMessageWidget extends StatelessWidget {
  final String localFilePath;
  final String url;
  final bool isReply;

  const DocumentMessageWidget({
    Key? key,
    required this.localFilePath,
    required this.url,
    this.isReply = false,
  }) : super(key: key);

  Future<void> _downloadAndOpenFile(BuildContext context) async {
    final file = File(localFilePath);
    if (file.existsSync()) {
      await OpenFile.open(localFilePath);
      return;
    }

    try {
      final dio = Dio();
      await dio.download(url, localFilePath);
      await OpenFile.open(localFilePath);
    } catch (e) {
      // Replace this with your own error handler if needed
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Failed to download file: $e')),
      // );
      showAlertMessage("Failed to download file: $e");
    }
  }

  IconData _getIconForExtension(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Symbols.picture_as_pdf_rounded;
      case 'doc':
      case 'docx':
        return Symbols.description_rounded;
      case 'xls':
      case 'xlsx':
        return Symbols.grid_on_rounded;
      case 'ppt':
      case 'pptx':
        return Symbols.slideshow_rounded;
      case 'txt':
        return Symbols.notes_rounded;
      case 'zip':
      case 'rar':
        return Symbols.archive_rounded;
      default:
        return Symbols.insert_drive_file_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final file = File(localFilePath);
    final fileName = localFilePath.split('/').last;
    final fileExtension = fileName.contains('.') ? fileName.split('.').last : '';

    return GestureDetector(
      onTap: () => _downloadAndOpenFile(context),
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.blackColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          // border: Border.all(color: Colors.grey.shade400),
        ),
        width: isReply ? 180 : 280,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              _getIconForExtension(fileExtension),
              size: 36,
              color: AppColors.textBarColor,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                fileName,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            if (!file.existsSync()) ...[
              const SizedBox(width: 5),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.download_rounded),
                onPressed: () => _downloadAndOpenFile(context),
              ),
            ],
          ],
        ),
      ),
    );
  }
}


