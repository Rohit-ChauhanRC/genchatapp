import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:genchatapp/app/modules/singleChat/controllers/single_chat_controller.dart';
// import 'package:genchatapp/app/modules/singleChat/widgets/message_audio_widget.dart';
import 'package:get/get.dart';

class AudioMessageWidget extends StatelessWidget {
  AudioMessageWidget({super.key, required this.localPath});

  final String localPath;

  final SingleChatController controller = Get.put(SingleChatController());

  @override
  Widget build(BuildContext context) {
    return AudioWaveforms(
      enableGesture: true,
      size: Size(MediaQuery.of(context).size.width / 2, 50),
      recorderController: controller.recorderController,
      waveStyle: const WaveStyle(
        waveColor: Colors.white,
        extendWaveform: true,
        showMiddleLine: false,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        // color: const Color(0xFF1E1B26),
      ),
      padding: const EdgeInsets.only(left: 18),
      margin: const EdgeInsets.symmetric(horizontal: 15),
    );
  }
}
