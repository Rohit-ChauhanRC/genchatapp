import 'dart:io';

import 'package:flutter/material.dart';
import 'package:genchatapp/app/constants/colors.dart';
import 'package:get/get.dart';

class ImagePreviewScreen extends StatelessWidget {
  final String imagePath;

  const ImagePreviewScreen({Key? key, required this.imagePath})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
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
          )),
      body: Container(
        margin: const EdgeInsets.all(20),
        alignment: Alignment.center,
        // width: Get.width * 0.7,
        height: Get.height * 0.7,
        child: Center(
          child: InteractiveViewer(
            // boundaryMargin: const EdgeInsets.all(20.0),
            // minScale: 0.1,
            // maxScale: 3,
            // panAxis: PanAxis.aligned,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            // maxScale: 3,
            alignment: Alignment.center,
            // constrained: true,
            child: Image.file(File(imagePath)),
          ),
        ),
      ),
    );
  }
}
