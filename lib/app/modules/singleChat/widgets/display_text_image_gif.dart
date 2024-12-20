// import 'package:audioplayers/audioplayers.dart';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:genchatapp/app/config/services/folder_creation.dart';
import 'package:genchatapp/app/constants/colors.dart';
import 'package:genchatapp/app/constants/message_enum.dart';
import 'package:genchatapp/app/modules/singleChat/controllers/single_chat_controller.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:path_provider/path_provider.dart';

import '../../../constants/constants.dart';

class DisplayTextImageGIF extends StatelessWidget {
  final String message;
  final MessageEnum type;
   DisplayTextImageGIF({
    Key? key,
    required this.message,
    required this.type,
  }) : super(key: key);


  final SingleChatController singleChatController = Get.find<SingleChatController>();

  @override
  Widget build(BuildContext context) {
    bool isPlaying = false;
    // final AudioPlayer audioPlayer = AudioPlayer();
    var rootFolderPath = singleChatController.rootPath;

    print("FullFolderPath:--------->${rootFolderPath+message}");
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
            : ClipRRect(
      borderRadius: BorderRadius.circular(10),
        child: Image.file(File('$rootFolderPath$message'), fit: BoxFit.cover, filterQuality: FilterQuality.medium,height: 200, width: 300,));
    // CachedNetworkImage(
    //             imageUrl: message,
    //           );
  }
}
