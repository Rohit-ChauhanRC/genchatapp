import 'package:flutter/material.dart';
import 'package:genchatapp/app/config/theme/app_colors.dart';
import 'package:genchatapp/app/constants/colors.dart';
import 'package:genchatapp/app/modules/singleChat/controllers/single_chat_controller.dart';
import 'package:get/get.dart';
import 'package:gif/gif.dart';
import 'dart:io';

class GifPreviewWidget extends StatelessWidget {
  GifPreviewWidget({super.key, required this.filePath});

  final String filePath;

  final SingleChatController singleChatController =
      Get.find<SingleChatController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blackColor,
      appBar: AppBar(
        backgroundColor: textBarColor,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: false,
        title: const Text(
          "GIFss Preview",
          style: TextStyle(
            fontSize: 20,
            color: whiteColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Gif(
          // controller: singleChatController.gifController,
          image: Image.file(File(filePath)).image,
          autostart: Autostart.loop,
          width: Get.width,
          fit: BoxFit.contain,
          height: Get.height,
        ),
      ),
    );
  }
}
