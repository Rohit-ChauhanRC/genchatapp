import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:genchatapp/app/config/theme/app_colors.dart';
import 'package:genchatapp/app/data/repositories/status/status_repository.dart';
import 'package:genchatapp/app/modules/updates/controllers/updates_controller.dart';
import 'package:video_player/video_player.dart';
import 'package:get/get.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoPath;

  VideoPlayerScreen({
    super.key,
    required this.videoPath,
    required this.statusRepository,
  });

  final StatusRepository statusRepository;

  final UpdatesController updatesController = Get.find();

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _videoController;
  bool isLoading = true;
  bool isPlaying = true;
  final RxBool isUploading = false.obs;

  @override
  void initState() {
    super.initState();
    _loadVideoWithCache();
  }

  Future<void> _loadVideoWithCache() async {
    try {
      File? file;
      if (widget.videoPath.startsWith("http")) {
        file = await DefaultCacheManager().getSingleFile(widget.videoPath);
      } else {
        file = File(widget.videoPath);
      }

      _videoController = VideoPlayerController.file(file)
        ..initialize().then((_) {
          setState(() => isLoading = false);
          _videoController?.play();
        });
    } catch (e) {
      // debugPrint("Video caching error: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_videoController == null) return;

    setState(() {
      if (_videoController!.value.isPlaying) {
        _videoController!.pause();
        isPlaying = false;
      } else {
        _videoController!.play();
        isPlaying = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.center,
        children: [
          isLoading ||
                  _videoController == null ||
                  !_videoController!.value.isInitialized
              ? const Center(child: CircularProgressIndicator())
              : SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _videoController!.value.size.width,
                      height: _videoController!.value.size.height,
                      child: VideoPlayer(_videoController!),
                    ),
                  ),
                ),

          GestureDetector(
            onTap: _togglePlayPause,
            child: Icon(
              isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
              size: 70,
              color: Colors.white.withOpacity(0.8),
            ),
          ),

          Positioned(
            bottom: 30,
            right: 30,
            child: Obx(() {
              return FloatingActionButton(
                heroTag: "sendBtnVideo",
                backgroundColor: AppColors.textBarColor,
                onPressed: isUploading.value
                    ? null
                    : () async {
                        isUploading.value = true;

                        try {
                          final uploadResponse = await widget.statusRepository
                              .uploadStatus(
                                imageFile: File(widget.videoPath!),
                                isAssets: true,
                                onProgress: (int sent, int total) {},
                                text: "",
                              );
                          if (uploadResponse != null &&
                              uploadResponse.statusCode == 200) {
                            await widget.updatesController.getStatus();
                            Get.close(2);
                          }
                        } catch (e) {
                          return;
                        } finally {
                          isUploading.value = false;
                        }
                      },
                child: isUploading.value
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send),
              );
            }),
          ),
        ],
      ),
    );
  }
}
