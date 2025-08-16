import 'package:flutter/material.dart';
import 'package:genchatapp/app/constants/colors.dart';
import 'package:genchatapp/app/constants/message_enum.dart';
import 'package:genchatapp/app/modules/singleChat/widgets/display_text_image_gif.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:swipe_to/swipe_to.dart';

import '../../../config/theme/app_colors.dart';

class MyMessageCard extends StatelessWidget {
  const MyMessageCard({
    Key? key,
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
    this.repliedAssetServerName,
    this.repliedThumbnail,
    this.onReplyTap,
    this.isHighlighted = false,
    this.isForwarded = false,
    this.showForwarded = false,
    this.onRetryTap,
    this.isAsset = false,
    required this.isRetryUploadFile,
    this.url,
    this.assetThumbnail,
    this.audioMessage,
    required this.isProgess,
  }) : super(key: key);

  final String message;
  final String date;
  final MessageType type;
  final MessageState status;
  final SyncStatus syncStatus;
  final void Function(DragUpdateDetails)? onLeftSwipe;
  final RxString repliedText;
  final MessageType repliedMessageType;
  final int? repliedUserId;
  final String? repliedUserName;
  final String? repliedThumbnail;
  final String? repliedAssetServerName;
  final VoidCallback? onReplyTap;
  final bool? isHighlighted;
  final bool isForwarded;
  final bool showForwarded;
  final VoidCallback? onRetryTap;
  final bool isAsset;
  final RxBool isRetryUploadFile;
  final String? url;
  final String? assetThumbnail;
  final String? audioMessage;
  final RxDouble isProgess;

  @override
  Widget build(BuildContext context) {
    final hasReply =
        type != MessageType.deleted &&
        ((repliedMessageType != MessageType.text &&
                (repliedAssetServerName?.isNotEmpty ?? false)) ||
            (repliedMessageType == MessageType.text &&
                repliedText.value.trim().isNotEmpty &&
                repliedText.value.trim().toLowerCase() != "null"));

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
            onTap: hasReply ? onReplyTap : null,
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
              color: mySideBgColor,
              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: Stack(
                children: [
                  // percent.value
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
                            children: [
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
                            ],
                          ),

                        // ✅ Fixed reply condition
                        if (hasReply)
                          Column(
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
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: replyColor.withOpacity(0.67),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: DisplayTextImageGIF(
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
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),

                        // Main message
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            DisplayTextImageGIF(
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

                  // Bottom timestamp + ticks
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
