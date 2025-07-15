import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:genchatapp/app/modules/audio_record/controllers/audio_record_controller.dart';
import 'package:get/get.dart';

class WaveBubble extends StatelessWidget {
  final String path;
  final audioCtrl = Get.find<AudioRecordController>();

  WaveBubble({super.key, required this.path});

  @override
  Widget build(BuildContext context) {
    final isSender = true;
    final bubbleColor = isSender ? Colors.blueAccent : Colors.grey.shade800;

    return Obx(() {
      final isPlaying = audioCtrl.isPlayingPath.value == path;

      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.7,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
                onPressed: () => audioCtrl.togglePlayback(path),
              ),
              Expanded(
                child: AudioFileWaveforms(
                  size: const Size(double.infinity, 40),
                  playerController: audioCtrl.getPlayer(path),
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
        ),
      );
    });
  }
}
