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
import 'document_message_widget.dart';

class DisplayTextImageGIF extends StatelessWidget {
  final String message;
  final MessageType type;
  final bool? isReply;
  DisplayTextImageGIF({
    Key? key,
    required this.message,
    required this.type,
    this.isReply = false,
  }) : super(key: key);

  final SingleChatController singleChatController =
      Get.find<SingleChatController>();

  @override
  Widget build(BuildContext context) {
    bool isPlaying = false;
    // final AudioPlayer audioPlayer = AudioPlayer();
    var rootFolderPath = singleChatController.rootPath;
    // rootFolderPath = "${rootFolderPath}/${}"

    // print("FullFolderPath:--------->${rootFolderPath+message}");
    return type == MessageType.text || type == MessageType.deleted
        ? SelectableText(
        type ==   MessageType.text?  singleChatController.encryptionService.decryptText(message): message,
            maxLines: isReply == true ?2: null,
            style: TextStyle(
                fontSize: 16,
                fontStyle: type == MessageType.deleted
                    ? FontStyle.italic
                    : FontStyle.normal,
                color: type == MessageType.deleted ? greyMsgColor : blackColor),
          )
        : type == MessageType.audio
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
        : type == MessageType.document
            ? DocumentMessageWidget(
                localFilePath: '${rootFolderPath}Document/$message', // or extract from metadata
                url: message, // the full URL
                isReply: isReply ?? false,
              )
            // : type == MessageType.video
            //     ? VideoPlayerItem(
            //         videoUrl: message,
            //       )
            //     : type == MessageType.gif
            //         ? CachedNetworkImage(
            //             imageUrl: message,
            //           )
            : ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  File('${rootFolderPath}Image/$message'),
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.medium,
                  height: isReply == true ?20 :200,
                  width: isReply == true ?30:300,
                ));
    // CachedNetworkImage(
    //             imageUrl: message,
    //           );
  }
}
