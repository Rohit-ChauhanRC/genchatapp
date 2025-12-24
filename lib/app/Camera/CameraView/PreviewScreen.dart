import 'dart:io';

import 'package:flutter/material.dart';
import 'package:genchatapp/app/constants/colors.dart';
import 'package:genchatapp/app/data/models/new_models/response_model/status_model.dart';
import 'package:genchatapp/app/data/repositories/status/status_repository.dart';
import 'package:genchatapp/app/modules/updates/controllers/updates_controller.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import 'VIdeoPlayerScreen.dart';

class PreviewScreen extends StatelessWidget {
  final List<String>? imagePaths;
  final String? videoPath;
  final StatusRepository statusRepository;

  final UpdatesController updatesController = Get.find();
  final RxBool isUploading = false.obs;

  PreviewScreen({
    super.key,
    this.imagePaths,
    this.videoPath,
    required this.statusRepository,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: imagePaths != null && imagePaths!.isNotEmpty
                ? ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: imagePaths!.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.file(File(imagePaths![index])),
                );
              },
            )
                : (videoPath != null
                ? VideoPlayerScreen(
              videoPath: videoPath!,
              statusRepository: statusRepository,
            )
                : const SizedBox()),
          ),

          Positioned(
            bottom: 30,
            right: 30,
            child: Obx(() {
              return FloatingActionButton(
                backgroundColor: textBarColor,
                onPressed: isUploading.value
                    ? null
                    : () async {
                  isUploading.value = true;

                  try {
                    if (imagePaths != null && imagePaths!.isNotEmpty) {
                      // Upload all images
                      for (String path in imagePaths!) {
                        await statusRepository.uploadStatus(
                          imageFile: File(path),
                          isAssets: true,
                          onProgress: (_, __) {},
                          text: "",
                        );
                      }
                    } else if (videoPath != null) {
                      // Upload video
                      await statusRepository.uploadStatus(
                        imageFile: File(videoPath!),
                        isAssets: true,
                        onProgress: (_, __) {},
                        text: "",
                      );
                    }

                    await updatesController.getStatus();
                    Get.close(2);
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
                    : const Icon(Icons.send, color: Colors.white),
              );
            }),
          ),
        ],
      ),
    );
  }
}
