
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import 'VIdeoPlayerScreen.dart';
class PreviewScreen extends StatelessWidget {
  final String? imagePath;
  final String? videoPath;

  const PreviewScreen({super.key, this.imagePath, this.videoPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: imagePath != null
                ? Image.file(File(imagePath!))
                : (videoPath != null
                ? VideoPlayerScreen(videoPath: videoPath!)
                : const SizedBox()),
          ),
          Positioned(
            bottom: 30,
            right: 30,
            child: FloatingActionButton(
              backgroundColor: Colors.green,
              onPressed: () => Get.back(),
              child: const Icon(Icons.send),
            ),
          ),
        ],
      ),
    );
  }
}
