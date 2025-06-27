import 'dart:io';

import 'package:flutter/material.dart';
import 'package:genchatapp/app/modules/singleChat/controllers/single_chat_controller.dart';
import 'package:get/get.dart';
import 'package:gif/gif.dart';

class DisplayGifImage extends StatelessWidget {
  DisplayGifImage({super.key, required this.filePath});

  final String filePath;

  final SingleChatController singleChatController =
      Get.find<SingleChatController>();

  @override
  Widget build(BuildContext context) {
    return Gif(
      // controller: singleChatController.gifController,
      image: Image.file(File(filePath)).image,
      autostart: Autostart.loop,
      width: 250,
      fit: BoxFit.fill,
      height: 250,
    );
  }
}
