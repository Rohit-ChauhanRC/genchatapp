import 'package:flutter/material.dart';
import 'package:genchatapp/app/constants/colors.dart';
import 'package:genchatapp/app/constants/constants.dart';
import 'package:genchatapp/app/constants/message_enum.dart';
import 'package:genchatapp/app/data/models/new_models/response_model/new_message_model.dart';
import 'package:genchatapp/app/modules/group_chats/controllers/group_chats_controller.dart';
import 'package:genchatapp/app/modules/singleChat/widgets/audio_waveform_player_widget.dart';
import 'package:genchatapp/app/modules/singleChat/widgets/display_gif_image.dart';
import 'package:genchatapp/app/modules/singleChat/widgets/document_message_widget.dart';
import 'package:genchatapp/app/modules/singleChat/widgets/image_widget.dart';
import 'package:genchatapp/app/modules/singleChat/widgets/video_player_item.dart';
import 'package:get/get.dart';

class MessageInfo extends StatelessWidget {
  MessageInfo({
    super.key,
    required this.selectedMessages,
    required this.groupChatsController,
  });

  NewMessageModel selectedMessages;

  final GroupChatsController groupChatsController;
  String path = '';

  @override
  Widget build(BuildContext context) {
    if (selectedMessages.messageType == MessageType.image ||
        selectedMessages.messageType == MessageType.video ||
        selectedMessages.messageType == MessageType.gif ||
        selectedMessages.messageType == MessageType.audio ||
        selectedMessages.messageType == MessageType.document) {
      path = groupChatsController.getFilePath(
        selectedMessages.messageType!,
        selectedMessages.assetServerName!,
      );
    }
    final thumbnailPath =
        "${groupChatsController.rootPath}Thumbnail/${selectedMessages.assetThumbnail}";

    final gifPath =
        "${groupChatsController.rootPath}GIFs/${selectedMessages.assetThumbnail}";
    final audioPath =
        "${groupChatsController.rootPath}Audio/${selectedMessages.assetThumbnail}";

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          messageInfo,
          style: TextStyle(
            fontSize: 20,
            color: whiteColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        // automaticallyImplyLeading: false,
        centerTitle: false,
        backgroundColor: textBarColor,
      ),
      body: ListView(
        children: [
          if (selectedMessages.messageType == MessageType.image)
            _imageWidget(path),
          if (selectedMessages.messageType == MessageType.video)
            _videoWidget(path, thumbnailPath),

          if (selectedMessages.messageType == MessageType.text)
            _textWidget(
              groupChatsController.encryptionService.decryptText(
                selectedMessages.message.toString(),
              ),
            ),

          if (selectedMessages.messageType == MessageType.document)
            _docWidget(path, selectedMessages.assetUrl),

          if (selectedMessages.messageType == MessageType.gif)
            _gifWidget(gifPath),

          if (selectedMessages.messageType == MessageType.audio)
            _audioWidget(audioPath, selectedMessages.assetServerName!),

          _sectionTitle("Read by"),

          // ...controller.readList.map(_memberTile),
          Divider(),

          _sectionTitle("Delivered to"),
          // ...controller.deliveredList.map(_memberTile),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Widget _memberTile(MemberStatus member) {
  //   return ListTile(
  //     leading: CircleAvatar(child: Text(member.userName[0])),
  //     title: Text(member.userName),
  //     subtitle: Text(
  //       "at ${member.time.hour}:${member.time.minute.toString().padLeft(2, '0')}",
  //     ),
  //   );
  // }

  Widget _imageWidget(String imagePath) {
    return ImageWidget(rootFolderPath: imagePath, url: '', isReply: false);
  }

  Widget _videoWidget(String imagePath, String thumbnailPath) {
    return VideoPlayerItem(
      videoUrl: imagePath,
      url: '',
      isReply: false,
      localFilePath: thumbnailPath,
    );
  }

  Widget _textWidget(String title) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _docWidget(String path, String? url) {
    return DocumentMessageWidget(
      localFilePath: path,
      url: url ?? '',
      isReply: false,
    );
  }

  Widget _gifWidget(String gifPath) {
    return DisplayGifImage(filePath: gifPath, isReply: false);
  }

  Widget _audioWidget(String audioPath, String url) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: AudioPlayerScreen(
        audioPath: audioPath,
        audioUrl: url,
        isReply: false,
        // message: audioMessage,
      ),
    );
  }

  /** 
   * 
   * 
   * 
   *  switch (type) {
            case MessageType.document:
              return DocumentMessageWidget(
                localFilePath: path,
                url: url ?? '',
                isReply: isReply ?? false,
              );
            case MessageType.video:
              return VideoPlayerItem(
                videoUrl: path,
                localFilePath: thumbnailPath,
                url: url ?? '',
                isReply: isReply ?? false,
              );
            case MessageType.image:
              return ImageWidget(
                rootFolderPath: path,
                url: url ?? '',
                isReply: isReply,
              );
            case MessageType.audio:
              return AudioPlayerScreen(
                audioPath: audioPath,
                audioUrl: url,
                isReply: isReply,
                // message: audioMessage,
              ); // if using
            case MessageType.gif:
              return DisplayGifImage(
                filePath: gifPath,
                isReply: isReply ?? false,
              ); // if using
            default:
              return const SizedBox();
          }
   * */
}
