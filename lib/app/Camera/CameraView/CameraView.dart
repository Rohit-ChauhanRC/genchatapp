import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controllers/CameraUpdateController.dart';
import '../TextWriter.dart';
import 'PreviewScreen.dart';
import 'package:image_picker/image_picker.dart';
import 'VIdeoPlayerScreen.dart';
class CameraView extends GetView<CameraControllerX> {
  const CameraView({super.key});

  @override
  Widget build(BuildContext context) {
    final ImagePicker picker = ImagePicker();

    Future<void> openGallery() async {
      final XFile? media = await picker.pickMedia();

      if (media != null) {
        final file = File(media.path);
        final int fileSizeInBytes = file.lengthSync();
        final double fileSizeInMB = fileSizeInBytes / (1024 * 1024); // convert to MB

        if (media.path.toLowerCase().endsWith(".mp4") ||
            media.path.toLowerCase().endsWith(".mov")) {

          if (fileSizeInMB > 50) {
            Get.snackbar(
              "Video too large",
              "Maximum allowed size is 50 MB",
              snackPosition: SnackPosition.BOTTOM,
              colorText: Colors.white,
              backgroundColor: Colors.red,
            );
            return;
          }

          Get.to(() => VideoPlayerScreen(videoPath: media.path));
        } else {
          Get.to(() => PreviewScreen(imagePath: media.path));
        }
      }
    }


    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        if (!controller.isCameraReady.value) {
          return const Center(child: CircularProgressIndicator(color: Colors.green));
        }

        return Stack(
          children: [
            Positioned.fill(child: CameraPreview(controller.cameraController!)),
            // Bottom bar
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Gallery
                  GestureDetector(
                    onTap: openGallery,
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.photo_library_outlined,
                            color: Colors.white, size: 35),
                        SizedBox(height: 5),
                        Text("Gallery",
                            style: TextStyle(color: Colors.white70, fontSize: 12))
                      ],
                    ),
                  ),

                  // Capture button
                  GestureDetector(
                    onTap: () async {
                      final path = await controller.capturePhoto();
                      if (path != null) Get.to(() => PreviewScreen(imagePath: path));
                    },
                    // onLongPressStart: (_) async => await controller.startVideoRecording(),
                    // onLongPressEnd: (_) async {
                    //   final path = await controller.stopVideoRecording();
                    //   if (path != null) Get.to(() => VideoPlayerScreen(videoPath: path));
                    // },
                    child: Obx(() => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: controller.isRecording.value ? 80 : 70,
                      height: controller.isRecording.value ? 80 : 70,
                      decoration: BoxDecoration(
                        color: controller.isRecording.value ? Colors.red : Colors.white,
                        shape: BoxShape.circle,

                        border: Border.all(
                          color: controller.isRecording.value
                              ? Colors.redAccent
                              : Colors.green,
                          width: 4,
                        ),
                      ),
                    )
                      ),
                  ),

                  // Text Status
                  // Text option
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final result = await Get.to(() => const TextStatusScreen());
                          if (result != null) {
                            // You can handle the text & color here
                            print("Text: ${result['text']}");
                            print("Color: ${result['color']}");
                            // Navigate to a preview or post screen if you want
                          }
                        },

                        child: const Icon(Icons.edit, color: Colors.white, size: 35),
                      ),
                      const SizedBox(height: 5),
                      const Text("Text", style: TextStyle(color: Colors.white70, fontSize: 12))
                    ],
                  ),

                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}


