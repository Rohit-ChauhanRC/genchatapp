// import 'package:audioplayers/audioplayers.dart';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:genchatapp/app/config/services/folder_creation.dart';
import 'package:genchatapp/app/constants/colors.dart';
import 'package:genchatapp/app/constants/message_enum.dart';
import 'package:genchatapp/app/modules/singleChat/controllers/single_chat_controller.dart';
import 'package:genchatapp/app/modules/singleChat/widgets/image_preview.dart';
import 'package:genchatapp/app/modules/singleChat/widgets/image_widget.dart';
import 'package:genchatapp/app/modules/singleChat/widgets/video_player_item.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:path_provider/path_provider.dart';

import '../../../constants/constants.dart';
import 'document_message_widget.dart';

class DisplayTextImageGIF extends StatelessWidget {
  final String message;
  final MessageType type;
  final bool? isReply;
  final String? url;
  DisplayTextImageGIF({
    Key? key,
    required this.message,
    required this.type,
    this.url,
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
            type == MessageType.text
                ? singleChatController.encryptionService.decryptText(message)
                : message,
            maxLines: isReply == true ? 2 : null,
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
                    localFilePath:
                        '${rootFolderPath}Document/$message', // or extract from metadata
                    url: url.toString(), // the full URL
                    isReply: isReply ?? false,
                  )
                : type == MessageType.video
                    ? VideoPlayerItem(
                        videoUrl: '${rootFolderPath}Video/$message',
                        isReply: isReply ?? false,
                        localFilePath:
                            '${rootFolderPath}Video/$message', // or extract from metadata
                        url: url.toString(),
                      )
                    //     : type == MessageType.gif
                    //         ? CachedNetworkImage(
                    //             imageUrl: message,
                    //           )

                    // '${rootFolderPath}Image/$message'
                    : ImageWidget(
                        rootFolderPath: '${rootFolderPath}Image/$message',
                        url: url.toString(),
                        isReply: isReply,
                      );
    // CachedNetworkImage(
    //             imageUrl: message,
    //           );
  }
}

void showImagePreview(String imagePath) {
  Get.dialog(
    Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(10),
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {}, // disable outside tap to prevent accidental close
            child: Center(
              child: InteractiveViewer(
                child: Image.file(File(imagePath)),
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
              onPressed: () => Get.back(),
            ),
          ),
        ],
      ),
    ),
    barrierDismissible: false,
  );
}
