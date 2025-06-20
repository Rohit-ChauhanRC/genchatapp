import 'dart:io';

import 'package:flutter/material.dart';
import 'package:genchatapp/app/constants/colors.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class VideoPreviewScreen extends StatefulWidget {
  final String videoUrl;

  const VideoPreviewScreen({Key? key, required this.videoUrl})
      : super(key: key);

  @override
  State<VideoPreviewScreen> createState() => _VideoPreviewScreenState();
}

class _VideoPreviewScreenState extends State<VideoPreviewScreen> {
  late VideoPlayerController _controller;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    debugPrint((widget.videoUrl));
    _controller = VideoPlayerController.file(File(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
    _controller.setLooping(true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _controller.setVolume(_isMuted ? 0.0 : 1.0);
    });
  }

  void _togglePlayPause() {
    setState(() {
      _controller.value.isPlaying ? _controller.pause() : _controller.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: textBarColor,
          iconTheme: const IconThemeData(color: Colors.white),
          // automaticallyImplyLeading: false,
          centerTitle: false,
          title: const Text(
            "Video Preview",
            style: TextStyle(
              fontSize: 20,
              color: whiteColor,
              fontWeight: FontWeight.bold,
            ),
          )),
      backgroundColor: bgColor,
      body: _controller.value.isInitialized
          ? Container(
              height: Get.height * 0.8,
              padding: const EdgeInsets.all(18.0),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Center(
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                  VideoProgressIndicator(_controller, allowScrubbing: true),
                  // Positioned(
                  //   top: 40,
                  //   right: 20,
                  //   child: IconButton(
                  //     icon:
                  //         const Icon(Icons.close, color: Colors.white, size: 30),
                  //     onPressed: () {
                  //       _controller.pause();
                  //       Get.back();
                  //     },
                  //   ),
                  // ),
                  Positioned(
                    left: 20,
                    bottom: 30,
                    child: IconButton(
                      icon: Icon(
                        _isMuted ? Icons.volume_off : Icons.volume_up,
                        color: textBarColor,
                        size: 28,
                      ),
                      onPressed: _toggleMute,
                    ),
                  ),
                  Positioned(
                    right: 20,
                    bottom: 30,
                    child: IconButton(
                      icon: Icon(
                        _controller.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: textBarColor,
                        size: 32,
                      ),
                      onPressed: _togglePlayPause,
                    ),
                  ),
                ],
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
