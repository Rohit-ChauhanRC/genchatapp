// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:genchatapp/app/constants/colors.dart';
import 'package:genchatapp/app/constants/constants.dart';
import 'package:genchatapp/app/constants/message_enum.dart';
import 'package:genchatapp/app/modules/group_chats/widgets/group_chat_list.dart';
import 'package:genchatapp/app/modules/singleChat/widgets/audio_waveform_player_widget.dart';
import 'package:genchatapp/app/modules/singleChat/widgets/display_gif_image.dart';
import 'package:genchatapp/app/modules/singleChat/widgets/document_message_widget.dart';
import 'package:genchatapp/app/modules/singleChat/widgets/image_widget.dart';
import 'package:genchatapp/app/modules/singleChat/widgets/video_player_item.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/message_info_controller.dart';

class MessageInfoView extends GetView<MessageInfoController> {
  const MessageInfoView({super.key});
  @override
  Widget build(BuildContext context) {
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
          Obx(() {
            if (controller.selectedMessages.value.messageType ==
                MessageType.image)
              return _imageWidget(controller.path.value);
            else if (controller.selectedMessages.value.messageType ==
                MessageType.video)
              return _videoWidget(
                controller.path.value,
                controller.thumbnailPath.value,
              );
            else if (controller.selectedMessages.value.messageType ==
                MessageType.text)
              return _textWidget(
                controller.groupChatsController.encryptionService.decryptText(
                  controller.selectedMessages.value.message.toString(),
                ),
              );
            else if (controller.selectedMessages.value.messageType ==
                MessageType.document)
              return _docWidget(
                controller.path.value,
                controller.selectedMessages.value.assetUrl,
              );

            if (controller.selectedMessages.value.messageType ==
                MessageType.gif)
              return _gifWidget(controller.gifPath.value);
            else if (controller.selectedMessages.value.messageType ==
                MessageType.audio)
              return _audioWidget(
                controller.audioPath.value,
                controller.selectedMessages.value.assetServerName!,
              );
            else {
              return const SizedBox();
            }
          }),

          _sectionTitle("Read by"),
          Obx(
            () => controller.messageInfoList.isNotEmpty
                ? SizedBox(
                    height: 200,
                    child: ListView.builder(
                      itemCount: controller.messageInfoList.length,
                      itemBuilder: (ctx, i) {
                        final userInfo = controller.messageInfoList[i];
                        // final userInfo = controller.messageInfoList[i];
                        final userId = userInfo.eventRecipientId;

                        final userName = controller.usersList
                            .where((e) => e.userInfo!.userId == userId)
                            .first
                            .userInfo!
                            .name;
                        final userPhoneNumber = controller.usersList
                            .where((e) => e.userInfo!.userId == userId)
                            .first
                            .userInfo!
                            .phoneNumber;
                        final pictureUrl = controller.usersList
                            .where((e) => e.userInfo!.userId == userId)
                            .first
                            .userInfo!
                            .displayPictureUrl;
                        return userInfo.eventName == "seen" &&
                                userInfo.eventEmitted
                            ? _userTitle(
                                (userName ?? userPhoneNumber).toString(),
                                userInfo.sentAt,
                                pictureUrl!,
                              )
                            : const SizedBox.shrink();
                      },
                    ),
                  )
                : const SizedBox(),
          ),

          // ...controller.readList.map(_memberTile),
          const Divider(),

          _sectionTitle("Delivered to"),
          Obx(
            () => controller.messageInfoList.isNotEmpty
                ? SizedBox(
                    height: 200,
                    child: ListView.builder(
                      itemCount: controller.messageInfoList.length,
                      itemBuilder: (ctx, i) {
                        final userInfo = controller.messageInfoList[i];
                        final userId = userInfo.eventRecipientId;

                        final userName = controller.usersList
                            .where((e) => e.userInfo!.userId == userId)
                            .first
                            .userInfo!
                            .name;
                        final userPhoneNumber = controller.usersList
                            .where((e) => e.userInfo!.userId == userId)
                            .first
                            .userInfo!
                            .phoneNumber;
                        final pictureUrl = controller.usersList
                            .where((e) => e.userInfo!.userId == userId)
                            .first
                            .userInfo!
                            .displayPictureUrl;

                        return userInfo.eventName == "sent" &&
                                userInfo.eventEmitted
                            ? _userTitle(
                                (userName ?? userPhoneNumber).toString(),
                                userInfo.sentAt,
                                pictureUrl!,
                              )
                            : const SizedBox.shrink();
                      },
                    ),
                  )
                : const SizedBox(),
          ),
          // ...controller.deliveredList.map(_memberTile),
        ],
      ),
    );
  }

  // Widget _memberTile(MemberStatus member) {

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

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

  Widget _userTitle(String title, String subTitle, String pictureUrl) {
    return ListTile(
      leading: CachedNetworkImage(
        imageUrl: pictureUrl,
        imageBuilder: (_, image) =>
            CircleAvatar(backgroundImage: image, radius: 24),
        placeholder: (_, __) =>
            const CircularProgressIndicator(strokeWidth: 1.5),
      ),
      title: SizedBox(
        child: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      subtitle: Text(
        (DateFormat(
          'dd-MMMM-yyyy : hh:mm aaa',
        ).format(DateTime.parse(subTitle))),
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}
