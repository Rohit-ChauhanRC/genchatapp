import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:genchatapp/app/modules/audio_record/widgets/wave_bubble.dart';
import 'dart:io';

import 'package:get/get.dart';

import '../controllers/audio_record_controller.dart';

class AudioRecordView extends StatelessWidget {
  AudioRecordView({super.key});
  final audioCtrl = Get.put(AudioRecordController());

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),

        Obx(() {
          if (audioCtrl.isRecording.value) {
            return AudioWaveforms(
              enableGesture: false,
              size: Size(MediaQuery.of(context).size.width * 0.7, 50),
              recorderController: audioCtrl.recorderController,
              waveStyle: const WaveStyle(
                waveColor: Colors.white,
                extendWaveform: true,
                showMiddleLine: false,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                color: const Color(0xFF1E1B26),
              ),
            );
          }
          return const SizedBox();
        }),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.cancel, color: Colors.red),
              onPressed: audioCtrl.cancelRecording,
            ),
            Obx(
              () => IconButton(
                icon: Icon(
                  audioCtrl.isPaused.value ? Icons.mic : Icons.pause,
                  color: Colors.white,
                ),
                onPressed: audioCtrl.pauseRecording,
              ),
            ),
            Obx(
              () => IconButton(
                icon: Icon(
                  audioCtrl.isRecording.value ? Icons.stop : Icons.play_arrow,
                  color: Colors.white,
                ),
                onPressed: audioCtrl.isRecording.value
                    ? audioCtrl.stopRecording
                    : audioCtrl.startRecording,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
