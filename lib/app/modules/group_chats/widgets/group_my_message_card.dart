import 'package:flutter/material.dart';
import 'package:genchatapp/app/constants/colors.dart';
import 'package:genchatapp/app/constants/message_enum.dart';
import 'package:genchatapp/app/modules/group_chats/widgets/group_display_text_image_gif.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:swipe_to/swipe_to.dart';

import '../../../config/theme/app_colors.dart';

class GroupMyMessageCard extends StatelessWidget {
  final String message;
  final String date;
  final MessageType type;
  final MessageState status;
  final void Function(DragUpdateDetails)? onLeftSwipe;
  final RxString repliedText;
  final int? repliedUserId;
  final MessageType repliedMessageType;
  final String? repliedUserName;
  final VoidCallback? onReplyTap;
  final bool? isHighlighted;
  final bool isForwarded;
  final bool showForwarded;
  final RxBool isRetryUploadFile;
  final String? url;
  final String? assetThumbnail;
  final String? audioMessage;
  final bool isAsset;
  final String? repliedThumbnail;
  final SyncStatus syncStatus;
  final VoidCallback? onRetryTap;
  final String? repliedAssetServerName;

  const GroupMyMessageCard({
    super.key, // 👈 Ensure this is passed properly in ChatList
    required this.message,
    required this.date,
    required this.type,
    required this.status,
    required this.syncStatus,

    required this.onLeftSwipe,
    required this.repliedText,
    required this.repliedMessageType,
    this.repliedUserId,
    this.repliedUserName,
    this.onReplyTap,
    this.isHighlighted = false,
    this.isForwarded = false,
    this.showForwarded = false,
    this.url,
    this.assetThumbnail,
    this.audioMessage,
    required this.isRetryUploadFile,
    this.onRetryTap,

    this.isAsset = false,
    this.repliedThumbnail,
    this.repliedAssetServerName,
  }); // 👈 Needed for scroll-to-original to work

  @override
  Widget build(BuildContext context) {
    final replyText1 = repliedText.value.trim();
    final hasReply1 =
        replyText1.isNotEmpty &&
        replyText1.toLowerCase() != "null" &&
        type != MessageType.deleted;

    return SwipeTo(
      onLeftSwipe: onLeftSwipe,
      child: Align(
        alignment: Alignment.centerRight,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: 130,
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          child: InkWell(
            onTap: hasReply1 ? onReplyTap : null,
            child: Card(
              elevation: 1,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.zero,
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              color:
                  // isHighlighted! ? AppColors.mySideBgColor.withOpacity(0.3) :
                  mySideBgColor,
              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: Stack(
                children: [
                  Padding(
                    padding: type == MessageType.text
                        ? const EdgeInsets.only(
                            left: 10,
                            right: 20,
                            top: 5,
                            bottom: 20,
                          )
                        : const EdgeInsets.only(
                            left: 5,
                            top: 5,
                            right: 5,
                            bottom: 25,
                          ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (type != MessageType.deleted &&
                            isForwarded &&
                            showForwarded)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: showForwarded
                                ? [
                                    Icon(
                                      Symbols.forward_sharp,
                                      color: AppColors.greyMsgColor,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      "Forwarded",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontStyle: FontStyle.italic,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.greyMsgColor,
                                      ),
                                    ),
                                  ]
                                : [],
                          ),
                        Obx(() {
                          final replyText = repliedText.value.trim();
                          final hasReply =
                              replyText.isNotEmpty &&
                              replyText.toLowerCase() != "null" &&
                              type != MessageType.deleted;

                          if (!hasReply) return const SizedBox();

                          return Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: replyColor.withOpacity(0.67),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  repliedUserName ?? "",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: blackColor,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                GroupDisplayTextImageGIF(
                                  audioMessage: audioMessage,
                                  message:
                                      repliedMessageType != MessageType.text
                                      ? repliedAssetServerName ?? ""
                                      : repliedText.value,
                                  type: repliedMessageType,
                                  isReply: true,
                                  url: url,
                                  assetThumbnail: repliedThumbnail,
                                ),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 8),
                        Stack(
                          alignment: Alignment.center,

                          children: [
                            GroupDisplayTextImageGIF(
                              audioMessage: audioMessage,
                              message: message,
                              type: type,
                              url: url,
                              assetThumbnail: assetThumbnail,
                            ),
                            if (isAsset &&
                                (type == MessageType.image ||
                                    type == MessageType.video ||
                                    type == MessageType.document ||
                                    type == MessageType.audio)) ...[
                              Obx(() {
                                if (isRetryUploadFile.value) {
                                  return Container(
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.black45,
                                    ),
                                    padding: const EdgeInsets.all(12),
                                    child: const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    ),
                                  );
                                } else if (syncStatus == SyncStatus.pending) {
                                  return InkWell(
                                    onTap: () {
                                      if (!isRetryUploadFile.value) {
                                        onRetryTap?.call();
                                      }
                                    },
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.black45,
                                      ),
                                      padding: const EdgeInsets.all(8),
                                      child: const Icon(
                                        Icons.refresh,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                    ),
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
                              }),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 4,
                    right: 10,
                    child: Row(
                      children: [
                        Text(
                          date,
                          style: const TextStyle(
                            fontSize: 13,
                            color: greyMsgColor,
                          ),
                        ),
                        const SizedBox(width: 5),
                        if (type != MessageType.deleted)
                          Icon(
                            status == MessageState.unsent
                                ? Icons.watch_later
                                : status == MessageState.sent
                                ? Icons.done
                                : Icons.done_all,
                            size: 20,
                            color: status == MessageState.read
                                ? Colors.blue
                                : greyMsgColor,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
