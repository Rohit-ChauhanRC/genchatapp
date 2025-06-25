import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:genchatapp/app/modules/singleChat/widgets/video_preview.dart';
import 'package:genchatapp/app/utils/alert_popup_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:get/get.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class VideoPlayerItem extends StatelessWidget {
  final String videoUrl;
  final bool isReply;

  final String localFilePath;
  final String url;

  VideoPlayerItem({
    Key? key,
    required this.videoUrl,
    this.isReply = false,
    required this.localFilePath,
    required this.url,
  }) : super(key: key);

  File? _thumbnailBytes;
  bool _isLoading = true;

  Future<void> _downloadAndOpenFile(BuildContext context) async {
    final file = File(videoUrl);
    if (file.existsSync()) {
      Get.to(() => VideoPreviewScreen(videoUrl: videoUrl));
      return;
    }

    try {
      final dio = Dio();
      await dio.download(url, url);
      // await OpenFile.open(localFilePath);
      Get.to(() => VideoPreviewScreen(videoUrl: videoUrl));
      return;
    } catch (e) {
      // Replace this with your own error handler if needed
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Failed to download file: $e')),
      // );
      showAlertMessage("Failed to download file: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // _generateThumbnail();
    print(localFilePath);
    return GestureDetector(
      onTap: () => isReply ? null : _downloadAndOpenFile(context),
      child: SizedBox(
        width: isReply ? 80 : 280,
        height: isReply ? 80 : 200,
        child: localFilePath.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(!localFilePath.contains(".")
                          ? "$localFilePath.jpg"
                          : localFilePath),
                      width: 280,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(30)),
                    child: Icon(Icons.play_circle_filled,
                        color: Colors.white, size: isReply ? 32 : 64),
                  ),
                ],
              ),
      ),
    );
  }
}
