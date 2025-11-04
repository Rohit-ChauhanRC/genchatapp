// import 'package:audioplayers/audioplayers.dart';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:genchatapp/app/constants/colors.dart';
import 'package:genchatapp/app/constants/colors.dart' as AppColors;
import 'package:genchatapp/app/constants/message_enum.dart';
import 'package:genchatapp/app/modules/group_chats/controllers/group_chats_controller.dart';
import 'package:genchatapp/app/modules/singleChat/widgets/audio_preview.dart';
import 'package:genchatapp/app/modules/singleChat/widgets/display_gif_image.dart';
import 'package:genchatapp/app/modules/singleChat/widgets/document_message_widget.dart';
import 'package:genchatapp/app/modules/singleChat/widgets/image_widget.dart';
import 'package:genchatapp/app/modules/singleChat/widgets/video_player_item.dart';
import 'package:get/get.dart';

class GroupDisplayTextImageGIF extends StatelessWidget {
  final String message;
  final MessageType type;
  final bool? isReply;
  final String? url;
  final bool? isSentByMe; // New parameter to identify sent messages

  final String? assetThumbnail;
  final String? audioMessage;

  const GroupDisplayTextImageGIF({
    Key? key,
    required this.message,
    required this.type,
    this.url,
    this.isReply = false,
    this.isSentByMe = false, // Default to false for received messages
    this.assetThumbnail,
    this.audioMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GroupChatsController>();
    final path = controller.getFilePath(type, message);
    final thumbnailPath = "${controller.rootPath}Thumbnail/$assetThumbnail";
    final gifPath = "${controller.rootPath}GIFs/$assetThumbnail";
    final audioPath = "${controller.rootPath}Audio/$assetThumbnail";

    if (type == MessageType.text || type == MessageType.deleted) {
      return SelectableText(
        type == MessageType.text && isReply != true
            ? controller.encryptionService.decryptText(message)
            : message,
        autofocus: true,
        maxLines: isReply == true ? 2 : null,
        style: TextStyle(
          fontSize: 16,
          fontStyle: type == MessageType.deleted
              ? FontStyle.italic
              : FontStyle.normal,
          color: type == MessageType.deleted ? greyMsgColor : blackColor,
        ),
      );
    }

    return FutureBuilder(
      future: _checkFileAvailability(controller, type, message),
      builder: (context, snapshot) {
        return Obx(() {
          final isDownloaded = controller.isDownloaded[message] ?? false;
          final isDownloading = controller.isDownloading[message] ?? false;

          print("🔍 [GroupDisplayTextImageGIF] Display check - message: $message, isDownloaded: $isDownloaded, isDownloading: $isDownloading, isSentByMe: $isSentByMe");

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
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getIcon(type, message),
                          size: isReply == true ? 25 : 50,
                          color: Colors.grey[700],
                        ),
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
                            color: Colors.grey[600],
                          ),
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
                                color: Colors.grey[500],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    if (isDownloading)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                value: controller.totalBytes[message]! > 0
                                    ? controller.downloadedBytes[message]! /
                                          controller.totalBytes[message]!
                                    : null,
                                strokeWidth: 3,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.whiteColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (controller.totalBytes[message]! > 0)
                                Text(
                                  "${(controller.downloadedBytes[message]! / (1024 * 1024)).toStringAsFixed(1)} MB"
                                  " / ${(controller.totalBytes[message]! / (1024 * 1024)).toStringAsFixed(1)} MB",
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.whiteColor,
                                  ),
                                ),
                              const SizedBox(height: 12),
                              InkWell(
                                onTap: () {
                                  controller.cancelDownload(type, message);
                                },
                                child: const Icon(
                                  Icons.cancel_outlined,
                                  size: 40,
                                  color: AppColors.whiteColor,
                                ),
                              ),
                              // ElevatedButton.icon(
                              //   style: ElevatedButton.styleFrom(
                              //     backgroundColor: Colors.redAccent,
                              //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              //   ),
                              //   onPressed: () {
                              //     controller.cancelDownload(message); // Cancel logic (see below)
                              //   },
                              //   icon: const Icon(Icons.cancel, size: 16),
                              //   label: const Text("Cancel", style: TextStyle(fontSize: 12)),
                              // ),
                            ],
                          ),
                        ),
                      )
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
                          child: Icon(
                            Icons.download,
                            size: isReply == true ? 10 : 20,
                            color: Colors.white,
                          ),
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
                isReply: isReply ?? false,
              );
            case MessageType.video:
              return VideoPlayerItem(
                videoUrl: path,
                localFilePath: thumbnailPath,
                url: url ?? '',
                isReply: isReply ?? false,
              );
            case MessageType.image:
              return ImageWidget(
                rootFolderPath: path,
                url: url ?? '',
                isReply: isReply,
              );
            case MessageType.audio:
              return AudioPreview(
                audioPath: path,
                audioUrl: url,
                isReply: isReply,
                message: audioMessage,
              ); // if using
            case MessageType.gif:
              return DisplayGifImage(
                filePath: gifPath,
                isReply: isReply ?? false,
              ); // if using
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
      final response = await HttpClient()
          .headUrl(uri)
          .then((req) => req.close());
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

  /// Check file availability with special handling for sent messages
  Future<void> _checkFileAvailability(
    GroupChatsController controller,
    MessageType type,
    String fileName,
  ) async {
    print("🔍 [GroupDisplayTextImageGIF] Checking file availability for: $fileName, isSentByMe: $isSentByMe");
    
    // For sent messages, check if file exists locally first
    if (isSentByMe == true) {
      final path = controller.getFilePath(type, fileName);
      final file = File(path);
      final exists = await file.exists();
      final size = exists ? await file.length() : 0;

      print("🔍 [GroupDisplayTextImageGIF] File path: $path, exists: $exists, size: $size");

      if (exists && size > 0) {
        // File exists locally, mark as downloaded immediately
        controller.isDownloaded[fileName] = true;
        print("✅ [GroupDisplayTextImageGIF] File marked as downloaded: $fileName");
        return;
      } else {
        // File doesn't exist locally, clean up any corrupt file
        if (exists) await file.delete();
        controller.isDownloaded[fileName] = false;
        print("❌ [GroupDisplayTextImageGIF] File not found or empty: $fileName");
      }
    } else {
      // For received messages, use the standard check
      print("📥 [GroupDisplayTextImageGIF] Using standard check for received message");
      await controller.checkIfFileExists(type, fileName);
    }
  }
}
