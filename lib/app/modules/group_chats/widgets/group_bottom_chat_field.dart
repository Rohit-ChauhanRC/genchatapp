import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genchatapp/app/constants/colors.dart';
import 'package:genchatapp/app/constants/message_enum.dart';
import 'package:genchatapp/app/modules/group_chats/controllers/group_chats_controller.dart';
import 'package:genchatapp/app/modules/singleChat/widgets/AttachmentPopupDemo.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../utils/alert_popup_utils.dart';
import 'group_message_reply_preview.dart';

class GroupBottomChatField extends StatelessWidget {
  const GroupBottomChatField({
    super.key,
    required this.groupChatsController,
    this.onTap,
  });

  final GroupChatsController groupChatsController;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    // final isShowMessageReply =
    //     groupChatsController.messageReply.message != null;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),

        child: Column(
          children: [
            Obx(
              () =>
                  groupChatsController.messageReply.message != null &&
                      groupChatsController.messageReply.message != "null" &&
                      groupChatsController.messageReply.message
                          .toString()
                          .isNotEmpty
                  ? GroupMessageReplyPreview()
                  : const SizedBox.shrink(),
            ),
            Obx(
              () => groupChatsController.isRecording.value
                  ? Container(
                      // padding: const EdgeInsets.all(8.0),
                      // height: 70,
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: textBarColor,
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          StreamBuilder<Duration>(
                            stream: groupChatsController
                                .recorderController
                                .onCurrentDuration,
                            builder: (context, snapshot) {
                              final duration = snapshot.data ?? Duration.zero;
                              final minutes = duration.inMinutes
                                  .remainder(60)
                                  .toString()
                                  .padLeft(2, '0');
                              final seconds = duration.inSeconds
                                  .remainder(60)
                                  .toString()
                                  .padLeft(2, '0');

                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Text(
                                  "$minutes:$seconds",
                                  style: const TextStyle(color: Colors.white),
                                ),
                              );
                            },
                          ),

                          // AudioRecordView(),
                          AudioWaveforms(
                            size: Size(
                              MediaQuery.of(context).size.width * 0.7,
                              50,
                            ),
                            // enableGesture: true,
                            recorderController:
                                groupChatsController.recorderController,
                            waveStyle: const WaveStyle(
                              durationLinesHeight: 2,
                              showHourInDuration: true,
                              showMiddleLine: false,
                              waveColor: Colors.white,
                              extendWaveform: true,
                              durationLinesColor: Colors.white,
                              waveCap: StrokeCap.butt,
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  // Expanded(
                  //   child: Container(
                  //     constraints: const BoxConstraints(maxHeight: 200),
                  //     child: TextFormField(
                  //       scrollController:
                  //           groupChatsController.textScrollController,
                  //       maxLines: null,

                  //       // autofocus: true,
                  //       keyboardType: TextInputType.multiline,
                  //       focusNode: groupChatsController.focusNode,
                  //       onChanged: (v) {
                  //         // if (v.isNotEmpty) {
                  //         //   groupChatsController.isShowSendButton = true;
                  //         //   groupChatsController.messageController.text = v;
                  //         // } else {
                  //         //   groupChatsController.isShowSendButton = false;
                  //         // }
                  //         print(v.length);
                  //         groupChatsController.onTextChanged(v);

                  //         if (v.length >= 800) {
                  //           // You could show a SnackBar, error, or shake animation here
                  //           showAlertMessage(
                  //             "This message is too long, Please shorter the message.",
                  //           );
                  //           print("Max character limit reached");
                  //         }
                  //       },
                  //       controller: groupChatsController.messageController,
                  //       inputFormatters: [
                  //         LengthLimitingTextInputFormatter(800),
                  //         TextInputFormatter.withFunction((oldValue, newValue) {
                  //           return newValue.copyWith(
                  //             text: newValue.text,
                  //             selection:
                  //                 newValue.selection, // keeps cursor in place
                  //           );
                  //         }),
                  //       ],
                  //       // maxLength: 800,
                  //       decoration: InputDecoration(
                  //         filled: true,
                  //         fillColor: whiteColor,
                  //         prefixIcon: Padding(
                  //           padding: const EdgeInsets.only(left: 20),
                  //           child: SizedBox(
                  //             width: 20,
                  //             child: Row(
                  //               children: [
                  //                 // IconButton(
                  //                 //   onPressed: groupChatsController
                  //                 //       .toggleEmojiKeyboardContainer,
                  //                 //   // onPressed: () {},
                  //                 //   icon: Obx(
                  //                 //       () => groupChatsController.isShowEmojiContainer
                  //                 //           ? const Icon(
                  //                 //               Icons.emoji_emotions,
                  //                 //               color: Colors.black,
                  //                 //             )
                  //                 //           : const Icon(
                  //                 //               Icons.keyboard,
                  //                 //               color: Colors.black,
                  //                 //             )),
                  //                 // ),
                  //                 InkWell(
                  //                   onTap: () {
                  //                     groupChatsController.selectGif();
                  //                   },
                  //                   child: const Icon(
                  //                     Icons.gif,
                  //                     color: greyMsgColor,
                  //                     size: 20,
                  //                   ),
                  //                 ),
                  //               ],
                  //             ),
                  //           ),
                  //         ),
                  //         suffixIcon: Obx(
                  //           () => SizedBox(
                  //             width: !groupChatsController.isShowSendButton
                  //                 ? 100
                  //                 : 50,
                  //             child: Row(
                  //               mainAxisAlignment: MainAxisAlignment.end,
                  //               children: [
                  //                 !groupChatsController.isShowSendButton
                  //                     ? IconButton(
                  //                         onPressed: () {
                  //                           groupChatsController.selectFile(
                  //                             MessageType.image.value,
                  //                           );
                  //                         },
                  //                         icon: const Icon(
                  //                           Icons.camera_alt,
                  //                           color: greyMsgColor,
                  //                         ),
                  //                       )
                  //                     : SizedBox.shrink(),
                  //                 IconButton(
                  //                   onPressed: () {
                  //                     groupChatsController.cancelReply();
                  //                     groupChatsController.selectFile(
                  //                       MessageType.document.value,
                  //                     );
                  //                   },
                  //                   icon: const Icon(
                  //                     Icons.attach_file,
                  //                     color: greyMsgColor,
                  //                   ),
                  //                 ),
                  //               ],
                  //             ),
                  //           ),
                  //         ),
                  //         hintText: 'Type a message!',
                  //         border: OutlineInputBorder(
                  //           borderRadius: BorderRadius.circular(20.0),
                  //           borderSide: BorderSide.none,
                  //         ),
                  //         contentPadding: const EdgeInsets.all(10),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  Obx(
                    () => !groupChatsController.isRecording.value
                        ? Expanded(
                            child: Container(
                              constraints: const BoxConstraints(maxHeight: 200),
                              child: TextFormField(
                                scrollController:
                                    groupChatsController.textScrollController,
                                maxLines: null,

                                // autofocus: true,
                                keyboardType: TextInputType.multiline,
                                focusNode: groupChatsController.focusNode,
                                onChanged: (v) {
                                  // if (v.isNotEmpty) {
                                  //   singleChatController.isShowSendButton = true;
                                  //   singleChatController.messageController.text = v;
                                  // } else {
                                  //   singleChatController.isShowSendButton = false;
                                  // }
                                  print(v.length);
                                  groupChatsController.onTextChanged(v);
                                  if (v.length >= 800) {
                                    // You could show a SnackBar, error, or shake animation here
                                    showAlertMessage(
                                      "This message is too long, Please shorter the message.",
                                    );
                                    print("Max character limit reached");
                                  }
                                },
                                controller:
                                    groupChatsController.messageController,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(800),
                                ],
                                // maxLength: 800,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: whiteColor,
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.only(left: 20),
                                    child: SizedBox(
                                      width: 20,
                                      child: Row(
                                        children: [
                                          // IconButton(
                                          //   onPressed: singleChatController
                                          //       .toggleEmojiKeyboardContainer,
                                          //   // onPressed: () {},
                                          //   icon: Obx(
                                          //       () => singleChatController.isShowEmojiContainer
                                          //           ? const Icon(
                                          //               Icons.emoji_emotions,
                                          //               color: Colors.black,
                                          //             )
                                          //           : const Icon(
                                          //               Icons.keyboard,
                                          //               color: Colors.black,
                                          //             )),
                                          // ),
                                          InkWell(
                                            onTap: () {
                                              groupChatsController.selectGif();
                                            },
                                            child: const Icon(
                                              Icons.gif,
                                              color: greyMsgColor,
                                              size: 20,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  suffixIcon: Obx(
                                    () => SizedBox(
                                      width:
                                          !groupChatsController.isShowSendButton
                                          ? 100
                                          : 50,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          !groupChatsController.isShowSendButton
                                              ? IconButton(
                                                  onPressed: () {
                                                    groupChatsController
                                                        .selectFile(
                                                          MessageType
                                                              .image
                                                              .value,
                                                        );
                                                  },
                                                  icon: const Icon(
                                                    Symbols.camera_alt_rounded,
                                                    size: 20,
                                                    color: greyMsgColor,
                                                  ),
                                                )
                                              : const SizedBox.shrink(),
                                          IconButton(
                                            onPressed: () {
                                              // singleChatController.selectVideo();
                                              groupChatsController
                                                  .cancelReply();
                                              // Get.to(() => AttachmentPopupDemo());
                                              groupChatsController.selectFile(
                                                MessageType.document.value,
                                              );
                                            },
                                            icon: const Icon(
                                              Icons.attach_file,
                                              color: greyMsgColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  hintText: 'Type a message!',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.all(10),
                                ),
                              ),
                            ),
                          )
                        : Expanded(
                            child: Container(
                              constraints: const BoxConstraints(maxHeight: 200),
                              // decoration: BoxDecoration(color: Colors.black),
                              child: Row(
                                // mainAxisAlignment: MainAxisAlignment.m,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                      size: 30,
                                    ),
                                    onPressed: groupChatsController
                                        .cancelRecordingAudioWaveform,
                                  ),
                                  IconButton(
                                    icon: groupChatsController.isPause
                                        ? const Icon(
                                            Icons.refresh,
                                            color: textBarColor,
                                            size: 30,
                                          )
                                        : const Icon(
                                            Icons.stop,
                                            color: textBarColor,
                                            size: 30,
                                          ),
                                    onPressed: () {
                                      if (groupChatsController.isPause) {
                                        groupChatsController
                                            .pauseRecordingAudioWaveform();
                                      } else {
                                        groupChatsController
                                            .restartRecordingAudioWaveform();
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ),

                  InkWell(
                    onTap: () async {
                      // await groupChatsController.sendTextMessage();
                      if (groupChatsController.isShowSendButton &&
                          !groupChatsController.isPreviewing.value) {
                        await groupChatsController.sendTextMessage();
                      } else if (!groupChatsController.isPreviewing.value &&
                          !groupChatsController.isShowSendButton) {
                        await groupChatsController
                            .startRecordingAudioWaveform();
                      } else if (!groupChatsController.isShowSendButton &&
                          groupChatsController.isPreviewing.value) {
                        print("send audio");
                        groupChatsController.sendAudioMessage();
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 2,
                        right: 2,
                        bottom: 2,
                      ),
                      child: CircleAvatar(
                        backgroundColor: textBarColor,
                        radius: 25,
                        child: Obx(
                          () => Icon(
                            groupChatsController.isShowSendButton
                                ? Icons.send
                                : groupChatsController.isRecording.value
                                ? Icons.close
                                : Icons.mic,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // const SizedBox(
            //   height: 10,
            // ),
            Obx(
              () => groupChatsController.isShowEmojiContainer
                  ? SizedBox(
                      height: 300,
                      child: EmojiPicker(
                        onEmojiSelected: (category, emoji) {
                          groupChatsController.messageController.text =
                              groupChatsController.messageController.text +
                              emoji.emoji;

                          if (!groupChatsController.isShowSendButton) {
                            groupChatsController.isShowSendButton = true;
                          }
                        },
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
