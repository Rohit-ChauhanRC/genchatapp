// import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:genchatapp/app/constants/colors.dart';
import 'package:genchatapp/app/constants/message_enum.dart';

class DisplayTextImageGIF extends StatelessWidget {
  final String message;
  final MessageEnum type;
  const DisplayTextImageGIF({
    Key? key,
    required this.message,
    required this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isPlaying = false;
    // final AudioPlayer audioPlayer = AudioPlayer();

    return type == MessageEnum.text || type == MessageEnum.deleted
        ? SelectableText(
            message,
            style:  TextStyle(
              fontSize: 16, fontStyle: type == MessageEnum.deleted?FontStyle.italic: FontStyle.normal,color: type == MessageEnum.deleted ? greyMsgColor:blackColor
            ),
          )
        : type == MessageEnum.audio
            ? StatefulBuilder(builder: (context, setState) {
                return IconButton(
                  constraints: const BoxConstraints(
                    minWidth: 100,
                  ),
                  onPressed: () async {
                    if (isPlaying) {
                      // await audioPlayer.pause();
                      // setState(() {
                      //   isPlaying = false;
                      // });
                    } else {
                      // await audioPlayer.play(UrlSource(message));
                      // setState(() {
                      //   isPlaying = true;
                      // });
                    }
                  },
                  icon: Icon(
                    isPlaying ? Icons.pause_circle : Icons.play_circle,
                  ),
                );
              })
            // : type == MessageEnum.video
            //     ? VideoPlayerItem(
            //         videoUrl: message,
            //       )
            //     : type == MessageEnum.gif
            //         ? CachedNetworkImage(
            //             imageUrl: message,
            //           )
            : CachedNetworkImage(
                imageUrl: message,
              );
  }
}
