import 'dart:io';

import 'package:flutter/material.dart';
import 'package:genchatapp/app/constants/colors.dart';
import 'package:get/get.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioPlayerScreen extends StatefulWidget {
  final String audioPath;
  AudioPlayerScreen({super.key, required this.audioPath});

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  @override
  void initState() {
    super.initState();
    // await playerController.preparePlayer(path: widget.audioPath);
    preparePlayer();
  }

  void preparePlayer() async {
    var a = widget.audioPath.split("/")[widget.audioPath.split("/").length - 1];
    print(a);
    // await Future.delayed(const Duration(milliseconds: 500));

    await playerController.preparePlayer(path: widget.audioPath);
    // playerController.;
  }

  // final SingleChatController controller = Get.put(SingleChatController());

  RxBool isRecording = false.obs;
  RxBool isPreviewing = false.obs;
  RxString recordedPath = ''.obs;
  RxBool playAudio = false.obs;

  final PlayerController playerController = PlayerController();

  Future<void> playRecordingAudioWaveform() async {
    if (widget.audioPath.isNotEmpty) {
      playAudio.value = true;
      await Permission.audio.request();
      final req = await Permission.microphone.request();

      if (req.isGranted) {
        final file = File(widget.audioPath);
        if (!file.existsSync() || file.lengthSync() < 1000) {
          print("Audio file too short or corrupted");
          return;
        }

        try {
          playerController.setFinishMode(finishMode: FinishMode.stop);

          await playerController.startPlayer(forceRefresh: true);

          playerController.onCompletion.listen((_) async {
            playAudio.value = false;
            await playerController.stopPlayer(); // Explicit stop

            // 🔁 Prepare player again so it's ready to replay
            await playerController.preparePlayer(path: widget.audioPath);

            // Optional: move to beginning
            await playerController.seekTo(0);
          });
        } catch (e) {
          print("Playback error: $e");
        }
      }
    }
  }

  Future<void> stopPlayback() async {
    await playerController.stopPlayer();
    playAudio.value = true;
  }

  // pause playing audio
  Future<void> pausePlayback() async {
    await playerController.pausePlayer();

    playAudio.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.6,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: textBarColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Obx(
            () => IconButton(
              icon: !playAudio.value
                  ? const Icon(Icons.play_arrow, color: whiteColor, size: 30)
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
          Expanded(
            child: AudioFileWaveforms(
              size: const Size(double.infinity, 40),
              playerController: playerController,
              enableSeekGesture: true,
              waveformType: WaveformType.fitWidth,
              playerWaveStyle: const PlayerWaveStyle(
                fixedWaveColor: Colors.white60,
                liveWaveColor: Colors.white,
                spacing: 5,
                waveThickness: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
