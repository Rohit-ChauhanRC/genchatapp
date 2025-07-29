import 'dart:io';

import 'package:flutter/material.dart';
import 'package:genchatapp/app/modules/singleChat/widgets/gif_preview_widget.dart';
import 'package:get/get.dart';
import 'package:gif/gif.dart';

class GroupDisplayGifImage extends StatelessWidget {
  GroupDisplayGifImage({
    super.key,
    required this.filePath,
    required this.isReply,
  });

  final String filePath;
  final bool isReply;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(() => GifPreviewWidget(filePath: filePath));
      },
      child: Gif(
        // controller: singleChatController.gifController,
        image: Image.file(File(filePath)).image,
        autostart: Autostart.loop,
        width: isReply ? 80 : 250,
        fit: BoxFit.fill,
        height: isReply ? 80 : 250,
      ),
    );
  }
}
