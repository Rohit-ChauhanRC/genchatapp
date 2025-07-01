// import 'package:audioplayers/audioplayers.dart';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:genchatapp/app/constants/colors.dart';
import 'package:genchatapp/app/constants/message_enum.dart';
import 'package:genchatapp/app/modules/singleChat/controllers/single_chat_controller.dart';
import 'package:genchatapp/app/modules/singleChat/widgets/display_gif_image.dart';
import 'package:genchatapp/app/modules/singleChat/widgets/image_widget.dart';
import 'package:genchatapp/app/modules/singleChat/widgets/video_player_item.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import 'document_message_widget.dart';

class DisplayTextImageGIF extends StatelessWidget {
  final String message;
  final MessageType type;
  final bool? isReply;
  final String? url;

  final String? assetThumbnail;

  const DisplayTextImageGIF({
    Key? key,
    required this.message,
    required this.type,
    this.url,
    this.isReply = false,
    this.assetThumbnail,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SingleChatController>();
    final path = controller.getFilePath(type, message);
    final thumbnailPath = "${controller.rootPath}Thumbnail/$assetThumbnail";
    final gifPath = "${controller.rootPath}GIFs/$assetThumbnail";

    if (type == MessageType.text || type == MessageType.deleted) {
      return SelectableText(
        type == MessageType.text
            ? controller.encryptionService.decryptText(message)
            : message,
        maxLines: isReply == true ? 2 : null,
        style: TextStyle(
          fontSize: 16,
          fontStyle:
              type == MessageType.deleted ? FontStyle.italic : FontStyle.normal,
          color: type == MessageType.deleted ? greyMsgColor : blackColor,
        ),
      );
    }

    return FutureBuilder(
      future: controller.checkIfFileExists(type, message),
      builder: (context, snapshot) {
        return Obx(() {
          final isDownloaded = controller.isDownloaded[message] ?? false;
          final isDownloading = controller.isDownloading[message] ?? false;

          if (!isDownloaded) {
            return GestureDetector(
              onTap: () => isReply == true
                  ? null
                  : controller.downloadFile(type, message, url ?? ''),
              child: Container(
                width: isReply == true ? 80 : 200,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                height: isReply == true ? 80 : 200,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_getIcon(type, message),
                            size: isReply == true ? 25 : 50,
                            color: Colors.grey[700]),
                        const SizedBox(height: 10),
                        Text(
                          _getLabel(type, message),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          _truncate(message),
                          style: TextStyle(
                              fontSize: isReply == true ? 4 : 12,
                              color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 5),
                        FutureBuilder<String>(
                          future: _getRemoteFileSize(url ?? ''),
                          builder: (context, snapshot) {
                            return Text(
                              snapshot.hasData ? snapshot.data! : '',
                              style: TextStyle(
                                  fontSize: isReply == true ? 3 : 11,
                                  color: Colors.grey[500]),
                            );
                          },
                        ),
                      ],
                    ),
                    if (isDownloading)
                      const CircularProgressIndicator()
                    else
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(6),
                          child: Icon(Icons.download,
                              size: isReply == true ? 10 : 20,
                              color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }

          // Already downloaded → show real widget
          switch (type) {
            case MessageType.document:
              return DocumentMessageWidget(
                  localFilePath: path,
                  url: url ?? '',
                  isReply: isReply ?? false);
            case MessageType.video:
              return VideoPlayerItem(
                  videoUrl: path,
                  localFilePath: thumbnailPath ?? "",
                  url: url ?? '',
                  isReply: isReply ?? false);
            case MessageType.image:
              return ImageWidget(
                  rootFolderPath: path, url: url ?? '', isReply: isReply);
            case MessageType.audio:
            // return AudioMessageWidget(localPath: path); // if using
            case MessageType.gif:
              return DisplayGifImage(filePath: gifPath,  isReply: isReply ?? false); // if using
            default:
              return const SizedBox();
          }
        });
      },
    );
  }

  // 📦 File label (type label)
  String _getLabel(MessageType type, String fileName) {
    // if (fileName.toLowerCase().endsWith('.gif')) return 'GIF';
    if (fileName.toLowerCase().endsWith('.pdf')) return 'PDF';
    switch (type) {
      case MessageType.image:
        return 'Image';
      case MessageType.video:
        return 'Video';
      case MessageType.document:
        return 'Document';
      case MessageType.audio:
        return 'Audio';
      case MessageType.gif:
        return 'GIF';
      default:
        return 'Media';
    }
  }

  // 🎨 Icon based on type
  IconData _getIcon(MessageType type, String fileName) {
    // if (fileName.toLowerCase().endsWith('.gif')) return Icons.gif_box;
    if (fileName.toLowerCase().endsWith('.pdf')) return Icons.picture_as_pdf;
    switch (type) {
      case MessageType.image:
        return Icons.image;
      case MessageType.video:
        return Icons.videocam;
      case MessageType.document:
        return Icons.insert_drive_file;
      case MessageType.audio:
        return Icons.audiotrack;
      case MessageType.gif:
        return Icons.gif_box_outlined;
      default:
        return Icons.download;
    }
  }

  // ✂️ Shorten file name if too long
  String _truncate(String name) {
    return name.length > 25 ? '${name.substring(0, 22)}...' : name;
  }

  // 📏 Get file size from URL (approximate)
  Future<String> _getRemoteFileSize(String url) async {
    try {
      final uri = Uri.parse(url);
      final response =
          await HttpClient().headUrl(uri).then((req) => req.close());
      final contentLength = response.contentLength;
      if (contentLength < 0) return '';
      return _formatBytes(contentLength, 2);
    } catch (e) {
      return '';
    }
  }

  // 🔢 Format bytes to MB/KB
  String _formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB"];
    final i = (bytes != 0) ? (log(bytes) / log(1024)).floor() : 0;
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }
}
