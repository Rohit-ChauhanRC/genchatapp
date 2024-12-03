import 'dart:io';
// import 'package:enough_giphy_flutter/enough_giphy_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:tenor_flutter/tenor_flutter.dart';

import '../constants/colors.dart';

void showSnackBar({required BuildContext context, required String content}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(content),
    ),
  );
}

Future<File?> pickImageFromGallery(BuildContext context) async {
  File? image;
  try {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      image = File(pickedImage.path);
    }
  } catch (e) {
    showSnackBar(context: context, content: e.toString());
  }
  return image;
}

Future<File?> pickImageFromCamera(BuildContext context) async {
  File? image;
  try {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedImage != null) {
      image = File(pickedImage.path);
    }
  } catch (e) {
    showSnackBar(context: context, content: e.toString());
  }
  return image;
}

Future<File?> pickVideoFromGallery(BuildContext context) async {
  File? video;
  try {
    final pickedVideo =
        await ImagePicker().pickVideo(source: ImageSource.gallery);

    if (pickedVideo != null) {
      video = File(pickedVideo.path);
    }
  } catch (e) {
    showSnackBar(context: context, content: e.toString());
  }
  return video;
}

// AIzaSyA4b8wMGOK6MvrdF36k9d6RrYH5nnE5ExE ---> Tenor api key
//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 --> secret client key

Future<TenorResult?> pickGIF(BuildContext context) async {
  TenorResult? gif;

  var tenor = const Tenor(
    apiKey: "AIzaSyA4b8wMGOK6MvrdF36k9d6RrYH5nnE5ExE",
    clientKey: "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",
    locale: 'en_US',
    country: 'IN',
  );
  try {
    gif = await tenor.showAsBottomSheet(context: context);
  } catch (e) {
    showSnackBar(context: context, content: e.toString());
  }
  return gif;
}

Future<void> showImagePicker({
  required Function(File? image) onGetImage,
}) {
  return showModalBottomSheet<void>(
    context: Get.context!,
    builder: (_) {
      return Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: InkWell(
                onTap: () async {
                  onGetImage(await pickImageFromGallery(Get.context!));
                  Get.back();
                },
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.image,
                      size: 60,
                      color: messageColor,
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Gallery",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: greyColor,
                        fontSize: 16,
                      ),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () async {
                  onGetImage(await pickImageFromCamera(Get.context!));
                  Get.back();
                },
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.camera,
                      size: 60,
                      color: messageColor,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Camera",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: greyColor,
                        fontSize: 16,
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      );
    },
  );
}

void closeKeyboard() {
  final currentFocus = Get.focusScope;
  // if (!currentFocus.hasPrimaryFocus) {
  currentFocus!.unfocus();
  // }
}

void loadingDialog() {
  closeDialog();

  Get.dialog(
    const Center(
      child: CircularProgressIndicator(),
    ),
  );
}

void closeDialog() {
  if (Get.isDialogOpen!) {
    Get.back();
  }
}

void closeSnackbar() {
  if (Get.isSnackbarOpen) {
    Get.back();
  }
}

bool isEmail(String value) {
  return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
      .hasMatch(value);
}
