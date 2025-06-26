import 'package:flutter/material.dart';
import 'package:genchatapp/app/constants/colors.dart';
import 'package:genchatapp/app/constants/message_enum.dart';
// import 'package:genchat/app/modules/single_chat/controllers/single_chat_controller.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:swipe_to/swipe_to.dart';

import '../../../config/theme/app_colors.dart';
import 'display_text_image_gif.dart';

class SenderMessageCard extends StatelessWidget {
  const SenderMessageCard({
    super.key,
    required this.message,
    required this.date,
    required this.type,
    this.onRightSwipe,
    required this.repliedText,
    // required this.username,
    required this.repliedMessageType,
    this.repliedUserId,
    this.repliedUserName,
    this.repliedAssetServerName,
    this.repliedThumbnail,
    this.isHighlighted = false,
    this.onReplyTap,
    this.isForwarded = false,
    this.showForwarded = false,
    this.url,
    this.assetThumbnail,
  });
  final String message;
  final String date;
  final MessageType type;
  final void Function(DragUpdateDetails)? onRightSwipe;
  final RxString repliedText;
  // final String username;
  final MessageType repliedMessageType;
  final int? repliedUserId;
  final String? repliedUserName;
  final String? repliedThumbnail;
  final String? repliedAssetServerName;
  final bool? isHighlighted;
  final VoidCallback? onReplyTap;
  final bool isForwarded;
  final bool showForwarded;
  final String? url;
  final String? assetThumbnail;

  @override
  Widget build(BuildContext context) {
    // Check if message has reply
    final hasReply = type != MessageType.deleted &&
        ((repliedMessageType != MessageType.text &&
            (repliedAssetServerName?.isNotEmpty ?? false)) ||
            (repliedMessageType == MessageType.text &&
                repliedText.value.trim().isNotEmpty &&
                repliedText.value.trim().toLowerCase() != "null"));
    return SwipeTo(
      onRightSwipe: onRightSwipe,
      child: Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          child: InkWell(
            onTap: hasReply ? onReplyTap : null,
            child: Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.zero,
                      topRight: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8))),
              color:
                  // isHighlighted! ? Colors.pinkAccent.shade100 :
                  AppColors.bgColor.withOpacity(0.80),
              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: Stack(
                children: [
                  Padding(
                    padding: type == MessageType.text
                        ? const EdgeInsets.only(
                            left: 10,
                            right: 50,
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
                        // Forwarded
                        if (type != MessageType.deleted && isForwarded && showForwarded)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Symbols.forward_sharp,
                                  color: AppColors.greyMsgColor, size: 18),
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

                        // Reply UI
                        if (hasReply) ...[
                          Text(
                            repliedUserName ?? "username",
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
                              message: repliedMessageType != MessageType.text
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
                        DisplayTextImageGIF(
                            message: message,
                            type: type,
                            url: url,
                            assetThumbnail: assetThumbnail),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 2,
                    right: 10,
                    child: Text(
                      date,
                      style: TextStyle(
                        fontSize: 13,
                        color: greyMsgColor,
                      ),
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
