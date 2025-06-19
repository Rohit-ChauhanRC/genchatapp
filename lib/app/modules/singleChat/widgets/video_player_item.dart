import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:genchatapp/app/modules/singleChat/widgets/video_preview.dart';
import 'package:video_compress/video_compress.dart';
import 'package:get/get.dart';

class VideoPlayerItem extends StatefulWidget {
  final String videoUrl;
  final bool isReply;

  const VideoPlayerItem({
    Key? key,
    required this.videoUrl,
    this.isReply = false,
  }) : super(key: key);

  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  Uint8List? _thumbnailBytes;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _generateThumbnail();
  }

  Future<void> _generateThumbnail() async {
    try {
      final thumb = await VideoCompress.getByteThumbnail(
        widget.videoUrl,
        quality: 60,
        position: -1,
      );
      setState(() {
        _thumbnailBytes = thumb;
        _isLoading = false;
      });
    } catch (e) {
      print("Thumbnail error: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _openPreviewScreen() {
    Get.to(() => VideoPreviewScreen(videoUrl: widget.videoUrl));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openPreviewScreen,
      child: SizedBox(
        width: 280,
        height: 200,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                alignment: Alignment.center,
                children: [
                  _thumbnailBytes != null
                      ? Image.memory(
                          _thumbnailBytes!,
                          width: 280,
                          height: 200,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: Colors.black12,
                          child: const Icon(Icons.broken_image, size: 64),
                        ),
                  Container(
                    color: Colors.black38,
                    child: const Icon(Icons.play_circle_filled,
                        color: Colors.white, size: 64),
                  ),
                ],
              ),
      ),
    );
  }
}
