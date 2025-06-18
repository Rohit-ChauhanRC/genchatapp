import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ImagePreviewScreen extends StatelessWidget {
  final String imagePath;

  const ImagePreviewScreen({Key? key, required this.imagePath})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Get.back(),
        child: Center(
          child: InteractiveViewer(
            child: Image.file(File(imagePath)),
          ),
        ),
      ),
    );
  }
}
