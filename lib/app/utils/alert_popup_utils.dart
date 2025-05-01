import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:genchatapp/main.dart';
import 'package:get/get.dart';
import '../config/theme/app_colors.dart';

void showAlertMessage(String message) {
  final context = navigatorKey.currentContext;

  if (context == null) {
    // print('Context is not available:-------------------------------> Getting error for showing popup');
    return;
  }
  showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
            title: const Text("GENCHAT"),
            content: Text(
              message,
              style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: AppColors.blackColor),
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                onPressed: () {
                  Get.back();
                },
                isDefaultAction: true,
                child: GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: Text("OK",
                        style: TextStyle(color: AppColors.textBarColor))),
              )
            ],
          ));
}


void showAlertMessageWithAction({
  required String title,
  required String message,
  String confirmText = 'OK',
  String cancelText = 'Cancel',
  required VoidCallback onConfirm,
  VoidCallback? onCancel,
  bool showCancel = true,
  required BuildContext context,
}) {
  showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.blackColor),),
        content: Text(
          message,
          style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: AppColors.blackColor),
        ),
        actions: <Widget>[
          if (showCancel)
            CupertinoDialogAction(
              onPressed: () {
                Get.back(); // Close dialog
                if (onCancel != null) onCancel();
              },
              child: Text(
                cancelText,
                style: TextStyle(color: AppColors.blackColor),
              ),
            ),
          CupertinoDialogAction(
            onPressed: () {
              Get.back(); // Close dialog
              onConfirm();
            },
            isDefaultAction: true,
            child: Text(
              confirmText,
              style: TextStyle(color: AppColors.textBarColor),
            ),
          ),
        ],
      ));
}
