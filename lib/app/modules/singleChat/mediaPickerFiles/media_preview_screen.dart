import 'dart:io';
import 'package:flutter/material.dart';
import 'package:genchatapp/app/common/widgets/gradient_container.dart';
import 'package:genchatapp/app/config/theme/app_colors.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class MediaPreviewScreen extends StatefulWidget {
  final List<File> files;
  final String fileType;
  final void Function(List<File> selectedFiles) onSend;

  const MediaPreviewScreen({
    Key? key,
    required this.files,
    required this.fileType,
    required this.onSend,
  }) : super(key: key);

  @override
  State<MediaPreviewScreen> createState() => _MediaPreviewScreenState();
}

class _MediaPreviewScreenState extends State<MediaPreviewScreen> {
  late RxList<File> selectedFiles;
  File? previewFile;
  bool _isSent = false;

  bool isVideo(File file) {
    final ext = file.path.split('.').last.toLowerCase();
    return ['mp4', 'mov', 'mkv'].contains(ext);
  }

  @override
  void initState() {
    super.initState();
    selectedFiles = RxList<File>.of(widget.files);
    previewFile = selectedFiles.isNotEmpty ? selectedFiles.first : null;
  }

  @override
  void dispose() {
    if (!_isSent) {
      // Delete only files that were not selected for sending
      for (var file in widget.files) {
        if (!selectedFiles.contains(file) && file.existsSync()) {
          try {
            file.deleteSync();
          } catch (_) {}
        }
      }
    }
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blackColor,
      appBar: AppBar(
        backgroundColor: AppColors.textBarColor,
        title: Text("Preview", style: TextStyle(color: AppColors.whiteColor)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.whiteColor,),
          onPressed: () => Get.back(), // triggers dispose()
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              widget.onSend(selectedFiles.toList());
              Get.back();
            },
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: previewFile != null
                  ? isVideo(previewFile!)
                  ? VideoPreviewWidget(file: previewFile!)
                  : Image.file(previewFile!, fit: BoxFit.contain, width: Get.width,)
                  : const Text('No media selected',
                  style: TextStyle(color: Colors.white)),
            ),
          ),
          // const SizedBox(height: 10),
          Obx(() => SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: selectedFiles.length,
              itemBuilder: (context, index) {
                final file = selectedFiles[index];
                final isSelected = previewFile == file;

                return GestureDetector(
                  onTap: () {
                    if (isSelected) {
                      selectedFiles.remove(file);
                      if (previewFile == file) {
                        previewFile = selectedFiles.isNotEmpty ? selectedFiles.first : null;
                      }
                      setState(() {});
                    } else {
                      setState(() {
                        previewFile = file;
                      });
                    }
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? AppColors.whiteColor : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: isVideo(file)
                              ? FutureBuilder(
                            future: _getThumbnail(file),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.done &&
                                  snapshot.hasData) {
                                return Image.file(snapshot.data as File, fit: BoxFit.cover);
                              }
                              return const Center(child: CircularProgressIndicator());
                            },
                          )
                              : Image.file(file, fit: BoxFit.cover),
                        ),
                      ),

                      // Overlay with delete icon when selected
                      if (isSelected)
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(10), // match outer radius
                          ),
                          child: Center(
                            child: Icon(Icons.delete, size: 30, color: AppColors.whiteColor),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          )),
          // const SizedBox(height: 10),
        ],
      ),
    );
  }

  Future<File?> _getThumbnail(File videoFile) async {
    final tempDir = await getTemporaryDirectory();
    final thumb = await VideoThumbnail.thumbnailFile(
      video: videoFile.path,
      thumbnailPath: tempDir.path,
      imageFormat: ImageFormat.JPEG,
      maxHeight: 80,
      quality: 75,
    );
    return thumb != null ? File(thumb) : null;
  }
}



class VideoPreviewWidget extends StatefulWidget {
  final File file;

  const VideoPreviewWidget({Key? key, required this.file}) : super(key: key);

  @override
  State<VideoPreviewWidget> createState() => _VideoPreviewWidgetState();
}

class _VideoPreviewWidgetState extends State<VideoPreviewWidget> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.file)
      ..initialize().then((_) => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPlaying = false;
      } else {
        _controller.play();
        _isPlaying = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        _controller.value.isInitialized
            ? AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
        )
            : const CircularProgressIndicator(),
        GestureDetector(
          onTap: togglePlayPause,
          child: CircleAvatar(
            backgroundColor: Colors.black54,
            radius: 30,
            child: Icon(
              _isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
      ],
    );
  }
}

