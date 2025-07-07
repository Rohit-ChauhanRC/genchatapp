import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:genchatapp/app/constants/colors.dart';
import 'package:just_audio/just_audio.dart';
// import 'package:whatsapp_clone_app/features/app/theme/style.dart';

class MessageAudioWidget extends StatefulWidget {
  final String? audioUrl;
  const MessageAudioWidget({super.key, this.audioUrl});

  @override
  State<MessageAudioWidget> createState() => _MessageAudioWidgetState();
}

class _MessageAudioWidgetState extends State<MessageAudioWidget> {
  bool isPlaying = false;
  final AudioPlayer audioPlayer = AudioPlayer();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          constraints: const BoxConstraints(minWidth: 50),
          onPressed: () async {
            if (isPlaying) {
              await audioPlayer.pause();
              setState(() {
                isPlaying = false;
              });
            } else {
              await audioPlayer
                  .setFilePath(widget.audioUrl!,
                      initialPosition: Duration.zero, preload: true)
                  .then((value) async {
                setState(() {
                  isPlaying = true;
                });
                await audioPlayer.play();
                setState(() {
                  isPlaying = false;
                });
                await audioPlayer.stop();
              });
              // });
            }
          },
          icon: Icon(
            isPlaying ? Icons.pause_circle : Icons.play_circle,
            size: 30,
            color: textBarColor,
          ),
        ),
        const SizedBox(
          width: 15,
        ),
        isPlaying
            ? StreamBuilder<Duration>(
                stream: audioPlayer.positionStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Container(
                      margin: const EdgeInsets.only(top: 20),
                      width: 190,
                      height: 2,
                      child: Column(
                        children: [
                          Text("${snapshot.data!}"),
                          LinearProgressIndicator(
                            value: snapshot.data!.inMilliseconds.toDouble() /
                                audioPlayer.duration!.inMilliseconds.toDouble(),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white),
                            backgroundColor: greyColor,
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Container(
                      margin: const EdgeInsets.only(top: 20),
                      width: 190,
                      height: 2,
                      child: const LinearProgressIndicator(
                        value: 0,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        backgroundColor: greyColor,
                      ),
                    );
                  }
                })
            : Container(
                margin: const EdgeInsets.only(top: 20),
                width: 190,
                height: 2,
                child: const LinearProgressIndicator(
                  value: 0,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  backgroundColor: greyColor,
                ),
              ),
      ],
    );
  }
}
