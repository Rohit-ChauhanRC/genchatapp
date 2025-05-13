import 'package:flutter/material.dart';
import 'package:genchatapp/app/constants/colors.dart';
import 'package:genchatapp/app/constants/message_enum.dart';
// import 'package:genchat/app/modules/single_chat/controllers/single_chat_controller.dart';
import 'package:get/get.dart';
import 'package:swipe_to/swipe_to.dart';

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
    this.isHighlighted = false,
    this.onReplyTap,
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
  final bool? isHighlighted;
  final VoidCallback? onReplyTap;

  @override
  Widget build(BuildContext context) {
    final replyText1 = repliedText.value.trim();
    final hasReply1 = replyText1.isNotEmpty &&
        replyText1.toLowerCase() != "null" &&
        type != MessageType.deleted;
    return SwipeTo(
      onRightSwipe: onRightSwipe,
      child: Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          child: InkWell(
            onTap: hasReply1 ? onReplyTap : null,
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
              whiteColor,
              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: Stack(
                children: [
                  Padding(
                    padding: type == MessageType.text
                        ? const EdgeInsets.only(
                            left: 10,
                            right: 34,
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
                      children: [
                        type != MessageType.deleted &&
                                repliedText.value.isNotEmpty &&
                                repliedText.value != "null"
                            ? Obx(() => Column(children: [
                                  Text(
                                    repliedUserName ?? "username",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: blackColor),
                                  ),
                                  const SizedBox(height: 3),
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: replyColor.withOpacity(0.67),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(
                                          5,
                                        ),
                                      ),
                                    ),
                                    child: DisplayTextImageGIF(
                                      message: repliedText.value,
                                      type: repliedMessageType,
                                      isReply: true,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                ]))
                            : const SizedBox(),
                        DisplayTextImageGIF(
                          message: message,
                          type: type,
                        ),
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
