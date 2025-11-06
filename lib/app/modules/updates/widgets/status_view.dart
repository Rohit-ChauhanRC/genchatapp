import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:genchatapp/app/constants/colors.dart';
import 'package:genchatapp/app/data/models/status_model.dart';
import 'package:genchatapp/app/modules/updates/controllers/updates_controller.dart';

import 'package:video_player/video_player.dart';
class StatusView extends StatefulWidget {
  final UpdatesController controller;
  final StatusModel status;
  const StatusView({super.key, required this.controller, required this.status});

  @override
  State<StatusView> createState() => _StatusViewState();
}

class _StatusViewState extends State<StatusView> {
  late UpdatesController controller;
  late StatusModel status;

  int index = 0; // media index within status.media
  VideoPlayerController? _videoController;
  bool isVideo = false;
  StreamSubscription? _videoListener;

  @override
  void initState() {
    super.initState();
    controller = widget.controller;
    status = widget.status;
    _loadMedia(); // load first media
  }

  Future<void> _loadMedia() async {
    // Clean up any previous video controller
    _videoListener?.cancel();
    _videoController?.removeListener(_onVideoTick);
    _videoController?.pause();
    await _videoController?.dispose();
    _videoController = null;
    controller.stopProgress();

    final media = status.media[index];
    final type = media['type'];
    // final media = status.media[index];
    isVideo = media['type'] == 'video';

    if (type=='video') {
      // Initialize video player
      _videoController = VideoPlayerController.network(media['url']!)
        ..initialize().then((_) {
          setState(() {}); // video initialized
          // start playing
          _videoController?.play();
          _videoController?.setLooping(false);

          // drive progress by video duration
          final duration = _videoController!.value.duration.inMilliseconds;
          _videoListener = Stream.periodic(const Duration(milliseconds: 100))
              .listen((_) => _onVideoTick());
        }).catchError((e) {
          // fallback: skip if video fails
          _next();
        });
    } else if(type=='media') {
      controller.startProgress(durationSeconds: 5, onFinish: _next);
      setState(() {});
    }
  }

  void _onVideoTick() {
    if (_videoController == null || !_videoController!.value.isInitialized) return;
    final pos = _videoController!.value.position;
    final dur = _videoController!.value.duration;
    if (dur.inMilliseconds == 0) return;
    final p = pos.inMilliseconds / dur.inMilliseconds;
    controller.setProgress(p);
    if (p >= 1.0) {
      _next();
    }
  }

  @override
  void dispose() {
    _videoListener?.cancel();
    _videoController?.removeListener(_onVideoTick);
    _videoController?.dispose();
    controller.stopProgress();
    super.dispose();
  }

  void _next() {
    if (index < status.media.length - 1) {
      setState(() => index++);
      _loadMedia();
    } else {
      Get.back();
    }
  }

  void _previous() {
    if (index > 0) {
      setState(() => index--);
      _loadMedia();
    } else {
      // maybe go to previous user's status
      Get.back();
    }
  }

  void _onTapDown(TapDownDetails details, BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final dx = details.globalPosition.dx;
    if (dx < width / 3) {
      _previous();
    } else {
      _next();
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = status.media[index];
    return GestureDetector(
      onTapDown: (details) => _onTapDown(details, context),
      onLongPress: () {
        // pause both
        controller.stopProgress();
        _videoController?.pause();
      },
      onLongPressUp: () {
        // resume
        if (isVideo) {
          _videoController?.play();
        } else {
          // restart timer for remaining duration (simple approach: restart full 5s).
          controller.startProgress(durationSeconds: 5, onFinish: _next);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Positioned.fill(
              child: Builder(
                builder: (_) {
                  final media = status.media[index];
                  final type = media['type'];

                  if (type == 'video') {
                    return (_videoController != null && _videoController!.value.isInitialized)
                        ? FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _videoController!.value.size.width,
                        height: _videoController!.value.size.height,
                        child: VideoPlayer(_videoController!),
                      ),
                    )
                        : const Center(child: CircularProgressIndicator(color: Colors.white));
                  } else if (type == 'image') {
                    return Image.network(
                      media['url']!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const Center(child: CircularProgressIndicator(color: Colors.white));
                      },
                    );
                  } else if (type == 'text') {
                    final bgColor = media['bgColor'] ?? '#000000';
                    return Container(
                      color: Color(int.parse(bgColor.replaceFirst('#', '0xff'))),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Text(
                            media['text'] ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),



            // progress bars
            Positioned(
              top: 40,
              left: 10,
              right: 10,
              child: Obx(() {
                return Row(
                  children: List.generate(status.media.length, (i) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: i < index ? 1 : i == index ? controller.progress.value : 0,
                            color: Colors.white,
                            backgroundColor: Colors.white24,
                            minHeight: 3,
                          ),
                        ),
                      ),
                    );
                  }),
                );
              }),
            ),

            // top-left user info & back button (merge with your UI)
            Positioned(
              top: 55,
              left: 15,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),

                      child: Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    ),
                      const SizedBox(width: 10),
                  CircleAvatar(radius: 20, backgroundImage: NetworkImage(status.ProfilePic)),
                  const SizedBox(width: 10),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(status.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Text(status.time, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
