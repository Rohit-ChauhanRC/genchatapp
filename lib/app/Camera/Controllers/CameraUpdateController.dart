import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:genchatapp/app/data/repositories/status/status_repository.dart';
import 'package:get/get.dart';

import 'dart:async';
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:genchatapp/app/data/repositories/status/status_repository.dart';
import 'package:image_cropper/image_cropper.dart';

class CameraControllerX extends GetxController {
  CameraController? cameraController;
  RxBool isCameraReady = false.obs;
  RxBool isRecording = false.obs;
  RxBool isCapturing = false.obs;
  RxInt recordingDuration = 0.obs;

  late List<CameraDescription> deviceCameras; // FIXED NAME

  int selectedCameraIndex = 0;

  final StatusRepository statusRepository = Get.find();

  @override
  void onInit() {
    super.onInit();
    initCamera();
  }

  Future<void> initCamera() async {
    try {
      /// CALL THE REAL FUNCTION FROM CAMERA PACKAGE
      deviceCameras = await availableCameras();

      // Choose back camera
      selectedCameraIndex = deviceCameras.indexWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
      );

      if (selectedCameraIndex == -1) selectedCameraIndex = 0;

      cameraController = CameraController(
        deviceCameras[selectedCameraIndex],
        ResolutionPreset.high,
        enableAudio: true,
      );

      await cameraController!.initialize();
      isCameraReady.value = true;
    } catch (e) {
      Get.snackbar("Camera Error", e.toString());
    }
  }

  Future<void> switchCamera() async {
    if (deviceCameras.length < 2) {
      Get.snackbar("No Camera", "Only one camera on this device");
      return;
    }

    isCameraReady.value = false;

    selectedCameraIndex = selectedCameraIndex == 0 ? 1 : 0;

    await cameraController?.dispose();

    cameraController = CameraController(
      deviceCameras[selectedCameraIndex],
      ResolutionPreset.high,
      enableAudio: true,
    );

    await cameraController!.initialize();
    isCameraReady.value = true;
  }

  Future<String?> capturePhoto() async {
    if (cameraController == null ||
        !cameraController!.value.isInitialized ||
        isCapturing.value)
      return null;

    isCapturing.value = true;

    try {
      // Capture image
      final pic = await cameraController!.takePicture();
      final String originalPath = pic.path;
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: originalPath,
        compressQuality: 80,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            statusBarColor: Colors.deepOrange,
            activeControlsWidgetColor: Colors.deepOrange,
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
            ],
          ),
          IOSUiSettings(title: 'Crop Image'),
        ],
      );

      // If user cropped → return cropped path
      if (croppedFile != null) {
        return croppedFile.path;
      }

      // If user cancels cropper → return original
      return originalPath;
    } catch (e) {
      Get.snackbar("Error", "Failed to capture photo: $e");
      return null;
    } finally {
      isCapturing.value = false;
    }
  }

  @override
  void onClose() {
    cameraController?.dispose();
    super.onClose();
  }
}
