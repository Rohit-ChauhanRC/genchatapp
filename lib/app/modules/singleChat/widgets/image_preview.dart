import 'dart:io';

import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:genchatapp/app/constants/colors.dart';
import 'package:genchatapp/app/constants/colors.dart' as AppColors;
import 'package:get/get.dart';

class ImagePreviewScreen extends StatelessWidget {
  final String imagePath;
  final bool networkImage;

  const ImagePreviewScreen({
    super.key,
    required this.imagePath,
    required this.networkImage,
  });

  @override
  Widget build(BuildContext context) {
    final imageProvider = FileImage(File(imagePath));

    final imageNetworkProvider = Image.network(
      imagePath,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.broken_image, size: 50, color: Colors.grey);
      },
    ).image;

    Future.delayed(Durations.medium4);

    return Scaffold(
      backgroundColor: AppColors.blackColor,
      appBar: AppBar(
        backgroundColor: textBarColor,
        iconTheme: const IconThemeData(color: Colors.white),
        // automaticallyImplyLeading: false,
        centerTitle: false,
        title: const Text(
          "Image Preview",
          style: TextStyle(
            fontSize: 20,
            color: whiteColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        // margin: const EdgeInsets.all(20),
        alignment: Alignment.center,
        // width: Get.width * 0.7,
        height: Get.height,
        child: EasyImageView(
          imageProvider: networkImage
              ? Image.file(File(imagePath)).image
              : imageProvider,
        ),

        // SizedBox.expand(
        //   child: InteractiveViewer(
        //     transformationController: _transformationController,
        //     // boundaryMargin: const EdgeInsets.all(20.0),
        //     // minScale: 0.1,
        //     maxScale: 10,
        //     // panAxis: PanAxis.aligned,
        //     clipBehavior: Clip.antiAliasWithSaveLayer,
        //     // maxScale: 3,
        //     alignment: Alignment.center,
        //     // constrained: true,
        //     child: GestureDetector(
        //       onTap: (){},
        //       child: Image.file(File(imagePath))),
        //   ),
        // ),
      ),
    );
  }
}
