import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genchatapp/app/constants/colors.dart';
import 'package:genchatapp/app/constants/message_enum.dart';
import 'package:genchatapp/app/modules/singleChat/controllers/single_chat_controller.dart';
import 'package:genchatapp/app/modules/singleChat/widgets/AttachmentPopupDemo.dart';
import 'package:get/get.dart';

import '../../../utils/alert_popup_utils.dart';
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
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: TextFormField(
                    scrollController: singleChatController.textScrollController,
                    maxLines: null,
                    // autofocus: true,

                    keyboardType: TextInputType.multiline,
                    focusNode: singleChatController.focusNode,
                    onChanged: (v) {
                      // if (v.isNotEmpty) {
                      //   singleChatController.isShowSendButton = true;
                      //   singleChatController.messageController.text = v;
                      // } else {
                      //   singleChatController.isShowSendButton = false;
                      // }
                      print(v.length);
                      singleChatController.onTextChanged(v);
                      if (v.length >= 800) {
                        // You could show a SnackBar, error, or shake animation here
                        showAlertMessage("This message is too long, Please shorter the message.");
                        print("Max character limit reached");
                      }
                    },
                    controller: singleChatController.messageController,
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
                      suffixIcon: Obx(() =>SizedBox(
                        width: !singleChatController.isShowSendButton ?100: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            !singleChatController.isShowSendButton ?IconButton(
                              onPressed: () {
                                singleChatController
                                    .selectFile(MessageEnum.image.type);
                              },
                              icon: const Icon(
                                Icons.camera_alt,
                                color: greyMsgColor,
                              ),
                            )
                                :SizedBox.shrink(),
                            IconButton(
                              onPressed: () {
                                // singleChatController.selectVideo();
                                singleChatController.cancelReply();
                                Get.to(() => AttachmentPopupDemo());
                              },
                              icon: const Icon(
                                Icons.attach_file,
                                color: greyMsgColor,
                              ),
                            ),
                          ],
                        ),
                      )),
                      hintText: 'Type a message!',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.all(10),
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () async {
                  await singleChatController.sendTextMessage();
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 2, right: 2, bottom: 2),
                  child: CircleAvatar(
                    backgroundColor: textBarColor,
                    radius: 25,
                    child: Obx(() => Icon(
                          singleChatController.isShowSendButton
                              ? Icons.send
                              : singleChatController.isRecording
                                  ? Icons.close
                                  : Icons.mic,
                        )),
                  ),
                ),
              ),
            ],
          ),
        ),
        // const SizedBox(
        //   height: 10,
        // ),
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
