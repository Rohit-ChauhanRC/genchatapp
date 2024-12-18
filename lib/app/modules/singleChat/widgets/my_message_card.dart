import 'package:flutter/material.dart';
import 'package:genchatapp/app/constants/colors.dart';
import 'package:genchatapp/app/constants/message_enum.dart';
import 'package:genchatapp/app/modules/singleChat/widgets/display_text_image_gif.dart';
import 'package:get/get.dart';
import 'package:swipe_to/swipe_to.dart';

class MyMessageCard extends StatelessWidget {
  final String message;
  final String date;
  final MessageEnum type;
  final MessageStatus status;
  final void Function(DragUpdateDetails)? onLeftSwipe;
  final RxString repliedText;
  final String username;
  final MessageEnum repliedMessageType;

  const MyMessageCard({
    super.key,
    required this.message,
    required this.date,
    required this.type,
    required this.status,
    required this.onLeftSwipe,
    required this.repliedText,
    required this.username,
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
                      topLeft:Radius.circular(8),
                      topRight:  Radius.zero,
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8))),
              color: mySideBgColor,
              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: Stack(
                children: [
                  Padding(
                    // width: Get.width - 70,
                    padding: type == MessageEnum.text
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
                        Obx(() => repliedText.value.isNotEmpty &&
                                repliedText.value != "null"
                            ? Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                                Text(
                                  username, textAlign: TextAlign.start,
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
                              ])
                            : const SizedBox()),
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
                        // Status Icon
                        // Obx(
                          // () => isSeen.value
                          //     ? const Icon(
                          //         Icons.done_all,
                          //         size: 20,
                          //         color: Colors.blue,
                          //       )
                          //     : 
                          //     const Icon(
                          //         Icons.done,
                          //         size: 20,
                          //         color: Colors.white60,
                          //       // ),
                        // ),
                        type != MessageEnum.deleted ?Icon(
                            status == MessageStatus.uploading
                                ? Icons.watch_later
                                : status == MessageStatus.sent
                                ? Icons.done
                                : status == MessageStatus.delivered
                                ? Icons.done_all
                                :Icons.done_all,
                            size: 20,
                            color: status == MessageStatus.seen
                                ? Colors.blue
                                : greyMsgColor,
                          ):const SizedBox.shrink(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
    //   )
    // : SwipeTo(
    //     key: UniqueKey(),
    //     onLeftSwipe: onLeftSwipe,
    //     child: Align(
    //       alignment: Alignment.centerRight,
    //       child: ConstrainedBox(
    //         constraints: BoxConstraints(
    //           maxWidth: MediaQuery.of(context).size.width - 45,
    //         ),
    //         child: Card(
    //           elevation: 1,
    //           shape: RoundedRectangleBorder(
    //               borderRadius: BorderRadius.circular(8)),
    //           color: messageColor,
    //           margin:
    //               const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
    //           child: Stack(
    //             children: [
    //               Container(
    //                 // width: Get.width - 70,
    //                 padding: type == MessageEnum.text
    //                     ? const EdgeInsets.only(
    //                         left: 10,
    //                         right: 50,
    //                         top: 5,
    //                         bottom: 20,
    //                       )
    //                     : const EdgeInsets.only(
    //                         left: 5,
    //                         top: 5,
    //                         right: 5,
    //                         bottom: 25,
    //                       ),
    //                 child: Column(
    //                   children: [
    //                     Obx(() => repliedText.value.isNotEmpty &&
    //                             repliedText.value != "null"
    //                         ? Column(children: [
    //                             Text(
    //                               username,
    //                               style: TextStyle(
    //                                   fontWeight: FontWeight.bold,
    //                                   color: greenColor),
    //                             ),
    //                             const SizedBox(height: 3),
    //                             Container(
    //                               padding: const EdgeInsets.all(10),
    //                               decoration: BoxDecoration(
    //                                 color: backgroundColor.withOpacity(0.5),
    //                                 borderRadius: const BorderRadius.all(
    //                                   Radius.circular(
    //                                     5,
    //                                   ),
    //                                 ),
    //                               ),
    //                               child: DisplayTextImageGIF(
    //                                 message: repliedText.value,
    //                                 type: repliedMessageType,
    //                               ),
    //                             ),
    //                             const SizedBox(height: 8),
    //                           ])
    //                         : const SizedBox()),
    //                     DisplayTextImageGIF(
    //                       message: message,
    //                       type: type,
    //                     ),
    //                   ],
    //                 ),
    //               ),
    //               Positioned(
    //                 bottom: 4,
    //                 right: 10,
    //                 child: Row(
    //                   children: [
    //                     Padding(
    //                       padding: const EdgeInsets.only(
    //                         left: 20,
    //                       ),
    //                       child: Text(
    //                         date,
    //                         style: const TextStyle(
    //                           fontSize: 13,
    //                           color: Colors.white60,
    //                         ),
    //                       ),
    //                     ),
    //                     const SizedBox(
    //                       width: 5,
    //                     ),
    //                     Obx(
    //                       () => isSeen.value
    //                           ? Icon(
    //                               Icons.done_all,
    //                               size: 20,
    //                               color: Colors.blue,
    //                             )
    //                           : Icon(
    //                               Icons.done,
    //                               size: 20,
    //                               color: Colors.white60,
    //                             ),
    //                     ),
    //                   ],
    //                 ),
    //               ),
    //             ],
    //           ),
    //         ),
    //       ),
    //     ),
    //   ));
  }
}
