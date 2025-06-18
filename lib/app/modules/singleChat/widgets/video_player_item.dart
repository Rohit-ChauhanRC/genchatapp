import 'dart:io';
import 'package:flutter/material.dart';
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
  bool _showPreview = false;

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

  void _openPreview() {
    Get.dialog(
      VideoPreviewDialog(videoUrl: widget.videoUrl),
      barrierDismissible: true,
    );
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
      onTap: _openPreview,
      child: SizedBox(
        // height: 200,
        // width: double.infinity,
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

class VideoPreviewDialog extends StatefulWidget {
  final String videoUrl;

  const VideoPreviewDialog({Key? key, required this.videoUrl})
      : super(key: key);

  @override
  State<VideoPreviewDialog> createState() => _VideoPreviewDialogState();
}

class _VideoPreviewDialogState extends State<VideoPreviewDialog> {
  late VideoPlayerController _controller;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
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
    return Dialog(
      backgroundColor: Colors.black87,
      child: _controller.value.isInitialized
          ? Stack(
              alignment: Alignment.bottomCenter,
              children: [
                AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
                VideoProgressIndicator(_controller, allowScrubbing: true),
                Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      _controller.pause();
                      Get.back();
                    },
                  ),
                ),
                Positioned(
                  left: 10,
                  bottom: 10,
                  child: IconButton(
                    icon: Icon(
                      _isMuted ? Icons.volume_off : Icons.volume_up,
                      color: Colors.white,
                    ),
                    onPressed: _toggleMute,
                  ),
                ),
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: IconButton(
                    icon: Icon(
                      _controller.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.white,
                    ),
                    onPressed: _togglePlayPause,
                  ),
                ),
              ],
            )
          : const Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
    );
  }
}

// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';
// import 'package:get/get.dart'; // For full screen navigation, optional

// class VideoPlayerItem extends StatefulWidget {
//   final String videoUrl;
//   final bool isReply;

//   const VideoPlayerItem({
//     Key? key,
//     required this.videoUrl,
//     this.isReply = false,
//   }) : super(key: key);

//   @override
//   State<VideoPlayerItem> createState() => _VideoPlayerItemState();
// }

// class _VideoPlayerItemState extends State<VideoPlayerItem> {
//   late VideoPlayerController _controller;
//   bool _isPlaying = false;
//   bool _isInitialized = false;

//   @override
//   void initState() {
//     super.initState();
//     _controller = VideoPlayerController.file(File(widget.videoUrl)) // for local
//       // _controller = VideoPlayerController.network(widget.videoUrl) // for network
//       ..initialize().then((_) {
//         setState(() {
//           _isInitialized = true;
//         });
//       });
//     _controller.addListener(() {
//       if (_controller.value.isInitialized) {
//         setState(() {});
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   void _togglePlayPause() {
//     setState(() {
//       _isPlaying ? _controller.pause() : _controller.play();
//       _isPlaying = !_isPlaying;
//     });
//   }

//   void _goFullScreen() {
//     Get.to(() => FullScreenVideoPlayer(controller: _controller));
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!_isInitialized) return const CircularProgressIndicator();

//     return SizedBox(
//       height: 200,
//       width: 280,
//       child: AspectRatio(
//         aspectRatio: _controller.value.aspectRatio,
//         child: Stack(
//           alignment: Alignment.bottomCenter,
//           children: [
//             VideoPlayer(_controller),
//             _PlayPauseOverlay(controller: _controller),
//             VideoProgressIndicator(_controller, allowScrubbing: true),
//             Positioned(
//               top: 8,
//               right: 8,
//               child: IconButton(
//                 icon: const Icon(Icons.fullscreen),
//                 onPressed: _goFullScreen,
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _PlayPauseOverlay extends StatelessWidget {
//   final VideoPlayerController controller;

//   const _PlayPauseOverlay({required this.controller});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () =>
//           controller.value.isPlaying ? controller.pause() : controller.play(),
//       child: Stack(
//         children: [
//           if (!controller.value.isPlaying)
//             Center(
//               child: Icon(
//                 Icons.play_circle,
//                 color: Colors.white,
//                 size: 64,
//               ),
//             )
//         ],
//       ),
//     );
//   }
// }

// class FullScreenVideoPlayer extends StatelessWidget {
//   final VideoPlayerController controller;

//   const FullScreenVideoPlayer({Key? key, required this.controller})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     controller.play(); // auto play

//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Center(
//         child: AspectRatio(
//           aspectRatio: controller.value.aspectRatio,
//           child: Stack(
//             alignment: Alignment.bottomCenter,
//             children: [
//               VideoPlayer(controller),
//               VideoProgressIndicator(controller, allowScrubbing: true),
//               Positioned(
//                 top: 40,
//                 right: 20,
//                 child: IconButton(
//                   icon: const Icon(Icons.close, color: Colors.white, size: 28),
//                   onPressed: () {
//                     controller.pause();
//                     Get.back();
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
