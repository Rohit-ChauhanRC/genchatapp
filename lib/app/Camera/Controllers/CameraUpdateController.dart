import 'dart:async';

import 'package:camera/camera.dart';
import 'package:get/get.dart';

class CameraControllerX extends GetxController {
  CameraController? cameraController;
  RxBool isCameraReady = false.obs;
  RxBool isRecording = false.obs;
  RxBool isCapturing = false.obs;
  RxInt recordingDuration=0.obs;
 Timer? _timer;
  @override
  void onInit() {
    super.onInit();
    initCamera();
  }

  Future<void> initCamera() async {
    try {
      final cameras = await availableCameras();
      final backCamera = cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.back,
      );


      cameraController = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: true,
      );

      await cameraController!.initialize();
      isCameraReady.value = true;
    } catch (e) {
      Get.snackbar("Camera Error", e.toString());
    }
  }

  Future<String?> capturePhoto() async {
    if (cameraController == null || !cameraController!.value.isInitialized) return null;
    if (isCapturing.value) return null;

    isCapturing.value = true;
    try {
      final picture = await cameraController!.takePicture();
      return picture.path;
    } catch (e) {
      Get.snackbar("Error", "Failed to capture photo: $e");
      return null;
    } finally {
      isCapturing.value = false;
    }
  }

  // Future<void> startVideoRecording() async {
  //   if (cameraController == null || !cameraController!.value.isInitialized || isRecording.value) return;
  //
  //   try {
  //     await cameraController!.startVideoRecording();
  //
  //     isRecording.value = true;
  //
  //     recordingDuration.value = 0;
  //
  //   } catch (e) {
  //     Get.snackbar("Error", "Failed to start video: $e");
  //   }
  // }
  //
  // Future<String?> stopVideoRecording() async {
  //   if (cameraController == null || !cameraController!.value.isRecordingVideo) return null;
  //
  //   try {
  //     final file = await cameraController!.stopVideoRecording();
  //     isRecording.value = false;
  //     _timer?.cancel();
  //     _timer = null;
  //     return file.path;
  //   } catch (e) {
  //     Get.snackbar("Error", "Failed to stop video: $e");
  //     return null;
  //
  //   }
  // }

  @override
  void onClose() {
    cameraController?.dispose();
    super.onClose();
  }
}
