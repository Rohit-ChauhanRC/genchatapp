import 'dart:io';
import 'package:dio/dio.dart';

import 'package:flutter/material.dart';
import 'package:genchatapp/app/constants/colors.dart';
import 'package:genchatapp/app/constants/colors.dart' as AppColors;
import 'package:genchatapp/app/utils/alert_popup_utils.dart';
import 'package:get/get.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioPlayerScreen extends StatefulWidget {
  final String audioPath;
  final String? audioUrl;
  final bool? isReply;

  AudioPlayerScreen({
    super.key,
    required this.audioPath,
    this.audioUrl,
    this.isReply,
  });

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  @override
  void initState() {
    super.initState();
    preparePlayer();
  }

  @override
  void dispose() {
    playerController.dispose();
    super.dispose();
  }

  Future<void> downloadAndOpenFile(BuildContext context) async {
    final file = File(widget.audioPath);
    if (file.existsSync()) {
      return;
    }
    try {
      final dio = Dio();
      await dio.download(widget.audioUrl.toString(), widget.audioPath);

      return;
    } catch (e) {
      showAlertMessage("Failed to download file: $e");
    }
  }

  // void preparePlayer() async {
  //   var a = widget.audioPath.split("/")[widget.audioPath.split("/").length - 1];
  //   print(a);
  //   await Future.delayed(const Duration(milliseconds: 500));

  //   await playerController.preparePlayer(path: widget.audioPath);
  //   // playerController.;
  // }

  Future<void> preparePlayer() async {
    try {
      if (playerController.playerState == PlayerState.playing) {
        await playerController.stopPlayer();
      }
      await playerController.preparePlayer(path: widget.audioPath);
    } catch (e) {
      print("preparePlayer error: $e");
    }
  }

  // final SingleChatController controller = Get.put(SingleChatController());
  RxBool isRecording = false.obs;

  RxBool isPreviewing = false.obs;

  RxString recordedPath = ''.obs;

  RxBool playAudio = false.obs;

  final PlayerController playerController = PlayerController();

  // Future<void> playRecordingAudioWaveform() async {
  Future<void> playRecordingAudioWaveform() async {
    if (widget.audioPath.isEmpty) return;

    // Toggle to playing
    playAudio.value = true;

    await Permission.audio.request();
    final req = await Permission.microphone.request();

    if (!req.isGranted) return;

    final file = File(widget.audioPath);
    if (!file.existsSync() || file.lengthSync() < 1000) {
      print("Audio file too short or corrupted");
      return;
    }

    try {
      await playerController.stopPlayer(); // Ensure it's stopped before playing
      await playerController.preparePlayer(path: widget.audioPath);
      playerController.setFinishMode(finishMode: FinishMode.stop);

      await playerController.startPlayer(forceRefresh: true);

      playerController.onCompletion.listen((_) async {
        // Reset state
        playAudio.value = false;

        // Reset player again so it can replay
        await playerController.stopPlayer();
        await playerController.preparePlayer(path: widget.audioPath);
        await playerController.seekTo(0);
      });
    } catch (e) {
      print("Playback error: $e");
    }
  }

  // Future<void> stopPlayback() async {
  Future<void> pausePlayback() async {
    if (playerController.playerState == PlayerState.playing) {
      await playerController.pausePlayer();
      playAudio.value = false;
    }
  }

  Future<void> stopPlayback() async {
    if (playerController.playerState != PlayerState.stopped) {
      await playerController.stopPlayer();
      playAudio.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blackColor,
      appBar: AppBar(
        backgroundColor: textBarColor,
        iconTheme: const IconThemeData(color: Colors.white),
        // automaticallyImplyLeading: false,
        centerTitle: false,
        title: const Text(
          "Audio Preview",
          style: TextStyle(
            fontSize: 20,
            color: whiteColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Center(
        child: GestureDetector(
          onTap: () {
            widget.isReply == true ? null : downloadAndOpenFile(context);
          },
          child: Container(
            // width: MediaQuery.of(context).size.width * 0.6,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: textBarColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                StreamBuilder<int>(
                  stream: playerController.onCurrentDurationChanged,
                  builder: (context, snapshot) {
                    final currentMs = snapshot.data ?? 0;
                    final totalMs = playerController.maxDuration;

                    // Prevent crash when totalMs is invalid (0 or less)
                    if (totalMs <= 0) {
                      return const SizedBox.shrink();
                    }

                    // Clamp and convert to int safely
                    final remainingMs = (totalMs - currentMs)
                        .clamp(0, totalMs)
                        .toInt();
                    final remaining = Duration(milliseconds: remainingMs);
                    final hours = remaining.inHours.toString().padLeft(2, '0');

                    final minutes = remaining.inMinutes
                        .remainder(60)
                        .toString()
                        .padLeft(2, '0');
                    final seconds = remaining.inSeconds
                        .remainder(60)
                        .toString()
                        .padLeft(2, '0');

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        "$hours:$minutes:$seconds",
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  },
                ),

                Obx(
                  () => IconButton(
                    icon: !playAudio.value
                        ? const Icon(
                            Icons.play_arrow,
                            color: whiteColor,
                            size: 30,
                          )
                        : const Icon(Icons.pause, color: whiteColor, size: 30),
                    onPressed: () {
                      if (!playAudio.value) {
                        playRecordingAudioWaveform();
                      } else {
                        pausePlayback();
                      }
                    },
                  ),
                ),
                AudioFileWaveforms(
                  size: const Size(150, 40),
                  playerController: playerController,
                  animationCurve: Curves.elasticInOut,
                  waveformType: WaveformType.fitWidth,
                  playerWaveStyle: const PlayerWaveStyle(
                    fixedWaveColor: Colors.white,
                    liveWaveColor: Colors.red,
                    spacing: 2,
                    waveThickness: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
