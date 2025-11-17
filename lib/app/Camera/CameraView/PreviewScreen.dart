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
  final String? imagePath;
  final String? videoPath;
  final StatusRepository statusRepository;

  final UpdatesController updatesController = Get.find();

  PreviewScreen({
    super.key,
    this.imagePath,
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
            child: imagePath != null
                ? Image.file(File(imagePath!))
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
            child: FloatingActionButton(
              backgroundColor: textBarColor,
              onPressed: () async {
                final uploadResponse = await statusRepository.uploadStatus(
                  imageFile: imagePath != null
                      ? File(imagePath!)
                      : File(videoPath!),
                  isAssets: true,
                  onProgress: (int i, int j) {},
                  text: "",
                );
                print(uploadResponse);

                if (uploadResponse != null &&
                    uploadResponse.statusCode == 200) {
                  await updatesController.getStatus();
                } else {
                  return;
                }
                Get.close(2);
              },
              child: const Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
