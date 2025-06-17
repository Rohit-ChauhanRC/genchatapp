import 'dart:async';
import 'dart:io';
// import 'package:enough_giphy_flutter/enough_giphy_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:tenor_flutter/tenor_flutter.dart';

import '../config/services/filePickerService.dart';
import '../constants/colors.dart';
import '../constants/message_enum.dart';
import '../modules/singleChat/mediaPickerFiles/media_preview_screen.dart';
import 'alert_popup_utils.dart';

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
                      color: textBarColor,
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
                      color: textBarColor,
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

Widget loadingWidget({required String text}){
  return Center(
    child: Container(
        padding: EdgeInsets.only(left: 10, right: 10, top: 20, bottom: 20),
        height: 150,
        width: 150,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: mySideBgColor,
            borderRadius: BorderRadius.circular(20)
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircularProgressIndicator(color: textBarColor ),
            Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: blackColor),),
          ],
        )),
  );
}

/// Function to get the correct content type for images dynamically
String getImageMimeType(File file) {
  String extension = file.path.split('.').last.toLowerCase();

  switch (extension) {
    case 'png':
      return 'image/png';
    case 'jpg':
    case 'jpeg':
      return 'image/jpeg';
    case 'gif':
      return 'image/gif';
    case 'bmp':
      return 'image/bmp';
    case 'webp':
      return 'image/webp';
    default:
      return 'application/octet-stream'; // Default if unknown
  }
}

String getFileMimeType(File file) {
  final extension = file.path.split('.').last.toLowerCase();

  switch (extension) {
  // Images
    case 'png':
      return 'image/png';
    case 'jpg':
    case 'jpeg':
      return 'image/jpeg';
    case 'gif':
      return 'image/gif';
    case 'bmp':
      return 'image/bmp';
    case 'webp':
      return 'image/webp';

  // Videos
    case 'mp4':
      return 'video/mp4';
    case 'mov':
      return 'video/quicktime';
    case 'avi':
      return 'video/x-msvideo';
    case 'mkv':
      return 'video/x-matroska';

  // Documents
    case 'pdf':
      return 'application/pdf';
    case 'doc':
      return 'application/msword';
    case 'docx':
      return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
    case 'xls':
      return 'application/vnd.ms-excel';
    case 'xlsx':
      return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
    case 'ppt':
      return 'application/vnd.ms-powerpoint';
    case 'pptx':
      return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
    case 'txt':
      return 'text/plain';
    case 'csv':
      return 'text/csv';
    case 'rtf':
      return 'application/rtf';

    default:
      return 'application/octet-stream'; // fallback for unknown types
  }
}


extension StringCasingExtension on String {
  String get toCapitalized => length > 0 ?'${this[0].toUpperCase()}${substring(1).toLowerCase()}':'';
  String get toTitleCase => replaceAll(RegExp(' +'), ' ').split(' ').map((str) => str.toCapitalized).join(' ');
}


// open from chat input or wherever you want
Future<void> showMediaPickerBottomSheet({
  required Function(List<File> files, String type) onSendFiles,
}) {
  return showModalBottomSheet(
    context: Get.context!,
    builder: (_) {
      return SafeArea(
        minimum: const EdgeInsets.all(10),
        child: Wrap(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      Get.back();
                      final files = await FilePickerService().pickFromGallery();
                      if (files.isNotEmpty) {
                        Get.to(() => MediaPreviewScreen(
                          files: files,
                          fileType: getMessageType(files.first).value,
                          onSend: (selectedFiles) {
                            onSendFiles(selectedFiles, getMessageType(files.first).value);
                          },
                        ));
                      }
                    },
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.image,
                          size: 60,
                          color: textBarColor,
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
                      Get.back();
                      final files = await FilePickerService().pickFromCamera();
                      if (files.isNotEmpty) {
                        Get.to(() => MediaPreviewScreen(
                          files: files,
                          fileType: getMessageType(files.first).value,
                          onSend: (selectedFiles) {
                            onSendFiles(selectedFiles, getMessageType(files.first).value);
                          },
                        ));
                      }
                    },
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.camera,
                          size: 60,
                          color: textBarColor,
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
          ],
        ),
      );
    },
  );
}

Future<void> pickAndSendDocuments(Function(List<File>) onConfirmedSend) async {
  List<File> files = await FilePickerService().pickDocuments();
  if (files.isEmpty) return;

  // Create a completer to wait for the result manually
  final completer = Completer<bool>();

  // Show the dialog (even if it returns void)
  showAlertMessageWithAction(
    message: "Do you want to send ${files.length} document(s)?",
    confirmText: "Send",
    cancelText: "Cancel",
    onCancel: () {
      Get.back(); // close dialog
      completer.complete(false); // complete with false
    },
    onConfirm: () {
      Get.back(); // close dialog
      completer.complete(true); // complete with true
    },
    showCancel: true,
    title: 'Genchat',
    context: Get.context!,
  );

  // Wait for the user's decision
  bool shouldSend = await completer.future;

  if (shouldSend) {
    onConfirmedSend(files);
  }
}




MessageType getMessageType(File file) {
  final ext = file.path.toLowerCase();

  if (ext.endsWith('.jpg') || ext.endsWith('.jpeg') || ext.endsWith('.png') || ext.endsWith('.webp')) {
    return MessageType.image;
  } else if (ext.endsWith('.mp4') || ext.endsWith('.mov') || ext.endsWith('.avi') || ext.endsWith('.mkv')) {
    return MessageType.video;
  } else if (ext.endsWith('.gif')){
    return MessageType.gif;
  }

  return MessageType.document; // Fallback
}


