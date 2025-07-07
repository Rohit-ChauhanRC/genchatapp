import 'package:flutter/material.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:genchatapp/app/constants/colors.dart';
import 'package:genchatapp/app/modules/singleChat/controllers/single_chat_controller.dart';
import 'package:get/get.dart';

class AudioSoundPlayerWidget extends StatelessWidget {
  AudioSoundPlayerWidget({super.key});

  final SingleChatController singleChatController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Container(
        // padding: const EdgeInsets.all(8.0),
        // height: 70,
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            border: Border.all(), borderRadius: BorderRadius.circular(30)),
        child: Obx(() => singleChatController.isPause
            ? IconButton(
                icon: singleChatController.playAudio.value
                    ? const Icon(
                        Icons.pause,
                        color: textBarColor,
                      )
                    : const Icon(
                        Icons.play_arrow,
                        color: textBarColor,
                      ),
                onPressed: () {
                  if (!singleChatController.playAudio.value) {
                    singleChatController.playRecording();
                  } else {
                    singleChatController.pausePlayback();
                  }
                },
              )
            : StreamBuilder<RecordingDisposition>(
                stream: singleChatController.soundRecorder.value.onProgress,
                builder: (context, snapshot) {
                  final duration = snapshot.data?.duration ?? Duration.zero;
                  final minutes = duration.inMinutes
                      .remainder(60)
                      .toString()
                      .padLeft(2, '0');
                  final seconds = duration.inSeconds
                      .remainder(60)
                      .toString()
                      .padLeft(2, '0');
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      "$minutes:$seconds",
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  );
                },
              )));
  }
}
