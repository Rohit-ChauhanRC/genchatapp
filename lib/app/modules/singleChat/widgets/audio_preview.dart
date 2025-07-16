import 'package:flutter/material.dart';
import 'package:genchatapp/app/config/services/encryption_service.dart';
import 'package:genchatapp/app/modules/singleChat/widgets/audio_waveform_player_widget.dart';
import 'package:get/get.dart';

class AudioPreview extends StatelessWidget {
  AudioPreview({
    super.key,
    required this.audioPath,
    this.audioUrl,
    this.isReply,
    this.message,
  });

  final String audioPath;
  final String? audioUrl;
  final bool? isReply;
  final String? message;

  final EncryptionService encryptionService = Get.find();

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: const EdgeInsets.all(20),
      alignment: Alignment.center,

      child: InkWell(
        onTap: () {
          Get.to(
            () => AudioPlayerScreen(
              audioPath: audioPath,
              audioUrl: audioUrl,
              isReply: isReply,
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(5),
          child: Row(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 100,
                child: Text(
                  "${encryptionService.isEncryptedMessage(message.toString()) ? encryptionService.decryptText(message.toString()) : message}",
                  overflow: TextOverflow.visible,
                ),
              ),
              const SizedBox(width: 10),
              Image.asset(
                "assets/images/audio.png",
                height: 50,
                width: 150,
                fit: BoxFit.contain,
                color: Colors.blueGrey,
              ),
              // Icon(Icons.play_arrow_rounded, size: 30),

              // Icon(
              //   Icons.multitrack_audio_outlined,
              //   weight: Get.width,
              //   size: 30,
              // ),
              // Icon(
              //   Icons.multitrack_audio_outlined,
              //   weight: Get.width,
              //   size: 10,
              // ),
              // Icon(
              //   Icons.multitrack_audio_outlined,
              //   weight: Get.width,
              //   size: 15,
              // ),
              // Icon(
              //   Icons.multitrack_audio_outlined,
              //   weight: Get.width,
              //   size: 17,
              // ),

              // Icon(
              //   Icons.multitrack_audio_outlined,
              //   weight: Get.width,
              //   size: 20,
              // ),
              // Icon(
              //   Icons.multitrack_audio_outlined,
              //   weight: Get.width,
              //   size: 22,
              // ),
              // Icon(
              //   Icons.multitrack_audio_outlined,
              //   weight: Get.width,
              //   size: 30,
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
