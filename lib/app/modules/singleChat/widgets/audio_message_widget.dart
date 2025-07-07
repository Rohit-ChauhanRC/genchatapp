import 'package:flutter/material.dart';
import 'package:genchatapp/app/modules/singleChat/widgets/message_audio_widget.dart';

class AudioMessageWidget extends StatelessWidget {
  const AudioMessageWidget({super.key, required this.localPath});

  final String localPath;

  @override
  Widget build(BuildContext context) {
    return MessageAudioWidget(
      audioUrl: localPath,
    );
  }
}
