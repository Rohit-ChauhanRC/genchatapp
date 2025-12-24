import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../config/services/filePickerService.dart';
import '../../modules/singleChat/mediaPickerFiles/media_preview_screen.dart';
import '../../modules/updates/controllers/updates_controller.dart';
import '../Controllers/CameraUpdateController.dart';
import '../TextWriter.dart';
import 'PreviewScreen.dart';
import 'package:image_picker/image_picker.dart';
import 'VIdeoPlayerScreen.dart';

class CameraView extends GetView<CameraControllerX> {
  const CameraView({super.key});


  @override
  Widget build(BuildContext context) {
    final UpdatesController updatesController = Get.find();

    final ImagePicker picker = ImagePicker();
    Future<void> openGallery() async {
      final List<XFile> pickedImages = await picker.pickMultiImage();

      if (pickedImages.isEmpty) return;

      if (pickedImages.length > 5) {
        Get.snackbar(
          "Limit Exceeded",
          "You can select a maximum of 5 images at once.",
          snackPosition: SnackPosition.TOP,
          colorText: Colors.white,
          backgroundColor: Colors.red,
        );
        return;
      }

      List<String> finalPaths = [];

      // Crop each image
      for (final img in pickedImages) {
        final cropped = await ImageCropper().cropImage(
          sourcePath: img.path,
          compressQuality: 80,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: Colors.deepOrange,
              toolbarWidgetColor: Colors.white,
              statusBarColor: Colors.deepOrange,
              activeControlsWidgetColor: Colors.deepOrange,
              aspectRatioPresets: [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
              ],
            ),
            IOSUiSettings(title: 'Crop Image'),
          ],
        );

        if (cropped != null) {
          finalPaths.add(cropped.path);
        }
      }

      if (finalPaths.isEmpty) return;

      final List<File> files = finalPaths.map((e) => File(e)).toList();

      Get.to(
            () => MediaPreviewScreen(
          files: files,
          fileType: "image",
          onSend: (List<File> selectedFiles) async {
            for (var file in selectedFiles) {
              await controller.statusRepository.uploadStatus(
                imageFile: file,
                isAssets: true,
                onProgress: (sent, total) {},
                text: "",
              );
            }

             await updatesController.getStatus();
            Get.back(); // Close preview
          },
        ),
      );

    }

    Future<void> pickVideoFromGallery() async {
      final ImagePicker picker = ImagePicker();

      final XFile? video = await picker.pickVideo(source: ImageSource.gallery);

      if (video == null) return;

      final file = File(video.path);
      final sizeMB = file.lengthSync() / (1024 * 1024);

      if (sizeMB > 50) {
        Get.snackbar(
          "Video too large",
          "Maximum allowed size is 50 MB",
          snackPosition: SnackPosition.BOTTOM,
          colorText: Colors.white,
          backgroundColor: Colors.red,
        );
        return;
      }

      Get.to(
        () => VideoPlayerScreen(
          videoPath: video.path,
          statusRepository: controller.statusRepository,
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        if (!controller.isCameraReady.value) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.green),
          );
        }

        return SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: CameraPreview(controller.cameraController!),
              ),
              // Bottom bar
              Positioned(
                top: 50,
                right: 20,
                child: GestureDetector(
                  onTap: controller.switchCamera,
                  child: const Icon(
                    Icons.cameraswitch_rounded,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
              ),

              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Gallery
                    GestureDetector(
                      onTap: () => openGallery(),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.photo_library_outlined,
                            color: Colors.white,
                            size: 35,
                          ),
                          SizedBox(height: 5),
                          Text(
                              "Gallery",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: pickVideoFromGallery,
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.video_call_outlined,
                            color: Colors.white,
                            size: 40,
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Video",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Capture button
                    GestureDetector(
                      onTap: () async {
                        final path = await controller.capturePhoto();
                        if (path != null) {
                          Get.to(
                            () => PreviewScreen(
                              imagePaths: [path],
                              statusRepository: controller.statusRepository,
                            ),
                          );
                        }
                      },
                      // onLongPressStart: (_) async => await controller.startVideoRecording(),
                      // onLongPressEnd: (_) async {
                      //   final path = await controller.stopVideoRecording();
                      //   if (path != null) Get.to(() => VideoPlayerScreen(videoPath: path));
                      // },
                      child: Obx(
                        () => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: controller.isRecording.value ? 80 : 70,
                          height: controller.isRecording.value ? 80 : 70,
                          decoration: BoxDecoration(
                            color: controller.isRecording.value
                                ? Colors.red
                                : Colors.white,
                            shape: BoxShape.circle,

                            border: Border.all(
                              color: controller.isRecording.value
                                  ? Colors.redAccent
                                  : Colors.green,
                              width: 4,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Text Status
                    // Text option
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            final result = await Get.to(
                              () => TextStatusScreen(
                                statusRepository: controller.statusRepository,
                              ),
                            );
                            if (result != null) {
                              // You can handle the text & color here
                              print("Text: ${result['text']}");
                              print("Color: ${result['color']}");
                              // Navigate to a preview or post screen if you want
                            }
                          },
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 35,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          "Text",
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
