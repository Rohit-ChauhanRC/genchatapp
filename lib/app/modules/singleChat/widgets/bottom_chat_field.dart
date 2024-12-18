import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:genchatapp/app/constants/colors.dart';
import 'package:genchatapp/app/modules/singleChat/controllers/single_chat_controller.dart';
import 'package:get/get.dart';

import 'message_reply_preview.dart';

class BottomChatField extends StatelessWidget {
  const BottomChatField({
    super.key,
    required this.singleChatController,
    this.onTap,
  });

  final SingleChatController singleChatController;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    // final isShowMessageReply =
    //     singleChatController.messageReply.message != null;
    return Column(
      children: [
        Obx(() => singleChatController.messageReply.message != null &&
                singleChatController.messageReply.message != "null" &&
                singleChatController.messageReply.message.toString().isNotEmpty
            ? MessageReplyPreview()
            : const SizedBox.shrink()),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                maxLines: null,
                focusNode: singleChatController.focusNode,
                onChanged: (v) {
                  if (v.isNotEmpty) {
                    singleChatController.isShowSendButton = true;
                    singleChatController.messageController.text = v;
                  } else {
                    singleChatController.isShowSendButton = false;
                  }
                },
                controller: singleChatController.messageController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: whiteColor,
                  prefixIcon: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
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
                              singleChatController.selectGif();
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
                  suffixIcon: SizedBox(
                    width: 100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: () {
                            singleChatController.selectImage();
                          },
                          icon: const Icon(
                            Icons.camera_alt,
                            color: greyMsgColor,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            // singleChatController.selectVideo();
                            singleChatController.cancelReply();
                          },
                          icon: const Icon(
                            Icons.attach_file,
                            color: greyMsgColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  hintText: 'Type a message!',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide.none
                  ),
                  contentPadding: const EdgeInsets.all(10),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 2, right: 2, bottom: 2),
              child: CircleAvatar(
                backgroundColor: textBarColor,
                radius: 25,
                child: Obx(() => GestureDetector(
                      onTap: () async {
                        await singleChatController.sendTextMessage();
                        //
                      },
                      child: Icon(
                        singleChatController.isShowSendButton
                            ? Icons.send
                            : singleChatController.isRecording
                                ? Icons.close
                                : Icons.mic,
                      ),
                    )),
              ),
            ),
          ],
        ),
        Obx(() => singleChatController.isShowEmojiContainer
            ? SizedBox(
                height: 300,
                child: EmojiPicker(
                  onEmojiSelected: (category, emoji) {
                    singleChatController.messageController.text =
                        singleChatController.messageController.text +
                            emoji.emoji;

                    if (!singleChatController.isShowSendButton) {
                      singleChatController.isShowSendButton = true;
                    }
                  },
                ),
              )
            : const SizedBox.shrink()),
      ],
    );
  }
}
