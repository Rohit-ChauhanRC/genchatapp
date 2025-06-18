import 'dart:io';
import 'package:flutter/material.dart';
import 'package:genchatapp/app/modules/singleChat/widgets/video_preview.dart';
import 'package:video_player/video_player.dart';
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
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoUrl));
    _controller.initialize().then((_) {
      setState(() {
        _isInitialized = true;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openPreviewScreen() {
    Get.to(() => VideoPreviewScreen(videoUrl: widget.videoUrl));
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const SizedBox(
        height: 200,
        width: 280,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return GestureDetector(
      onTap: _openPreviewScreen,
      child: SizedBox(
        child: Stack(
          alignment: Alignment.center,
          children: [
            AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
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
