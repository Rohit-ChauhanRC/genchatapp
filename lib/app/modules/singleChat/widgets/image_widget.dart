import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:genchatapp/app/config/theme/app_colors.dart';
import 'package:genchatapp/app/constants/colors.dart';
import 'package:genchatapp/app/modules/singleChat/widgets/image_preview.dart';
import 'package:genchatapp/app/utils/alert_popup_utils.dart';
import 'package:get/get.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';

class ImageWidget extends StatelessWidget {
  const ImageWidget({
    super.key,
    required this.rootFolderPath,
    this.isReply,
    this.url,
  });
  final String rootFolderPath;
  final bool? isReply;
  final String? url;

  Future<void> _downloadAndOpenFile(BuildContext context) async {
    final file = File(rootFolderPath);
    if (file.existsSync()) {
      Get.to(() => ImagePreviewScreen(imagePath: rootFolderPath));
      // final imageProvider = FileImage(File(rootFolderPath));

      // showImageViewer(
      //   context,
      //   imageProvider,
      //   swipeDismissible: true,
      //   doubleTapZoomable: true,
      //   backgroundColor: AppColors.blackColor,
      //   closeButtonColor: Colors.red,
      //   useSafeArea: true,
      // );
      return;
    }

    try {
      final dio = Dio();
      await dio.download(url.toString(), rootFolderPath);
      // await OpenFile.open(widget.localFilePath);
      Get.to(() => ImagePreviewScreen(imagePath: rootFolderPath));

      return;
    } catch (e) {
      // Replace this with your own error handler if needed
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Failed to download file: $e')),
      // );
      showAlertMessage("Failed to download file: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // final file = File(rootFolderPath);
    // final fileName = rootFolderPath.split('/').last;
    // final fileExtension =
    //     fileName.contains('.') ? fileName.split('.').last : '';

    return GestureDetector(
      onTap: () {
        isReply == true ? null : _downloadAndOpenFile(context);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(
          File(rootFolderPath),
          fit: BoxFit.cover,
          // filterQuality: FilterQuality.medium,
          height: isReply == true ? 80 : 200,
          width: isReply == true ? 80 : 300,
        ),
      ),
    );
  }
}
