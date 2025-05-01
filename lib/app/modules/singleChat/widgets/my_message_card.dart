import 'package:flutter/material.dart';
import 'package:genchatapp/app/constants/colors.dart';
import 'package:genchatapp/app/constants/message_enum.dart';
import 'package:genchatapp/app/modules/singleChat/widgets/display_text_image_gif.dart';
import 'package:get/get.dart';
import 'package:swipe_to/swipe_to.dart';

class MyMessageCard extends StatelessWidget {
  final String message;
  final String date;
  final MessageType type;
  final MessageState status;
  final void Function(DragUpdateDetails)? onLeftSwipe;
  final RxString repliedText;
  // final String username;
  final MessageType repliedMessageType;

  const MyMessageCard({
    super.key,
    required this.message,
    required this.date,
    required this.type,
    required this.status,
    required this.onLeftSwipe,
    required this.repliedText,
    // required this.username,
    required this.repliedMessageType,
  });

  @override
  Widget build(BuildContext context) {
    // final isReplying = repliedText.isNotEmpty;

    return SwipeTo(
        // swipeSensitivity: 20,
        onLeftSwipe: onLeftSwipe,
        // key: UniqueKey(),
        child: Align(
          alignment: Alignment.centerRight,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: 130,
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            child: Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.zero,
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8))),
              color: mySideBgColor,
              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: Stack(
                children: [
                  Padding(
                    // width: Get.width - 70,
                    padding: type == MessageType.text
                        ? const EdgeInsets.only(
                            left: 10,
                            right: 40,
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
                        // Reply Preview

                        type != MessageType.deleted && repliedText.value.isNotEmpty &&
                            repliedText.value != "null" ? Obx(() =>
                            Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                Text(
                                  "username", textAlign: TextAlign.start,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: blackColor),
                                ),
                                const SizedBox(height: 3),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration:  BoxDecoration(
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
                    bottom: 4,
                    right: 10,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 20,
                          ),
                          //time
                          child: Text(
                            date,
                            style: const TextStyle(
                              fontSize: 13,
                              color: greyMsgColor,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        type != MessageType.deleted
                            ?
                        Icon(
                          status == MessageState.unsent
                              ? Icons.watch_later
                              : status == MessageState.sent
                                  ? Icons.done
                                  : status == MessageState.delivered
                                      ? Icons.done_all
                                      : Icons.done_all,
                          size: 20,
                          color: status == MessageState.read
                              ? Colors.blue
                              : greyMsgColor,
                        )
                        : const SizedBox.shrink(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
