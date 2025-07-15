import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:genchatapp/app/modules/singleChat/controllers/single_chat_controller.dart';
import 'package:get/get.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioRecordController extends GetxController {
  //
  final SingleChatController singleChatController = Get.find();
  final recorderController = RecorderController();
  final playerControllers = <String, PlayerController>{}.obs;

  final isRecording = false.obs;
  final isPaused = false.obs;
  // final recordedPath = ''.obs;
  final recordingComplete = false.obs;
  final isPlayingPath = ''.obs;

  // late Directory appDirectory;

  @override
  void onInit() {
    super.onInit();
    initDirectory();
  }

  Future<void> initDirectory() async {
    // appDirectory = await getApplicationDocumentsDirectory();
    recorderController
      ..androidEncoder = AndroidEncoder.aac
      ..androidOutputFormat = AndroidOutputFormat.mpeg4
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
      ..sampleRate = 44100;
  }

  Future<void> startRecording() async {
    final hasPermission = await Permission.microphone.request();
    if (!hasPermission.isGranted) return;

    final fileName = "genchat_audio_${DateTime.now().millisecondsSinceEpoch}";

    final Directory thumDir;
    if (Platform.isAndroid) {
      thumDir = Directory("/storage/emulated/0");
    } else {
      thumDir = await getApplicationDocumentsDirectory();
    }

    final String rootFolderPath = '${thumDir.path}/GenChat/Audio';

    final Directory dirThum = Directory(rootFolderPath);
    if (!await dirThum.exists()) {
      await dirThum.create(recursive: true);
    } else {
      if (kDebugMode) {
        print(dirThum.path);
      }
    }
    final thumbnailPath = dirThum.path;

    singleChatController.recordedPath.value = '$thumbnailPath/$fileName.m4a';

    // final path =
    //     "${appDirectory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a";
    // recordedPath.value = path;

    await recorderController.record(
      path: singleChatController.recordedPath.value,
    );
    isRecording.value = true;
    recordingComplete.value = false;
  }

  Future<void> pauseRecording() async {
    if (isPaused.value) {
      await recorderController.record(
        path: singleChatController.recordedPath.value,
      );
    } else {
      await recorderController.pause();
    }
    isPaused.toggle();
  }

  Future<void> stopRecording() async {
    await recorderController.stop();
    isRecording.value = false;
    isPaused.value = false;
    recordingComplete.value = true;
  }

  Future<void> cancelRecording() async {
    try {
      await recorderController.stop();
      File(singleChatController.recordedPath.value).deleteSync();
      isRecording.value = false;
      isPaused.value = false;
      recordingComplete.value = false;
      singleChatController.recordedPath.value = '';
    } catch (e) {
      print('Cancel error: $e');
    }
  }

  Future<void> togglePlayback(String path) async {
    if (!playerControllers.containsKey(path)) {
      playerControllers[path] = PlayerController();
    }
    final controller = playerControllers[path]!;

    if (isPlayingPath.value == path) {
      await controller.pausePlayer();
      isPlayingPath.value = '';
    } else {
      // stop others
      for (var entry in playerControllers.entries) {
        await entry.value.stopPlayer();
      }
      await controller.preparePlayer(path: path);
      await controller.startPlayer();
      isPlayingPath.value = path;

      controller.onCompletion.listen((_) {
        isPlayingPath.value = '';
      });
    }
  }

  PlayerController getPlayer(String path) {
    return playerControllers[path] ??= PlayerController();
  }

  @override
  void onClose() {
    recorderController.dispose();
    for (final p in playerControllers.values) {
      p.dispose();
    }
    super.onClose();
  }
}
