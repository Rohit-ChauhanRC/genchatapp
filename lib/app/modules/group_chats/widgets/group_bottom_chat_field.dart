import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genchatapp/app/constants/colors.dart';
import 'package:genchatapp/app/constants/message_enum.dart';
import 'package:genchatapp/app/modules/group_chats/controllers/group_chats_controller.dart';
import 'package:genchatapp/app/modules/singleChat/controllers/single_chat_controller.dart';
import 'package:genchatapp/app/modules/singleChat/widgets/AttachmentPopupDemo.dart';
import 'package:get/get.dart';

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
    return Column(
      children: [
        Obx(() => groupChatsController.messageReply.message != null &&
                groupChatsController.messageReply.message != "null" &&
                groupChatsController.messageReply.message.toString().isNotEmpty
            ? GroupMessageReplyPreview()
            : const SizedBox.shrink()),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: TextFormField(
                    scrollController: groupChatsController.textScrollController,
                    maxLines: null,
                    // autofocus: true,

                    keyboardType: TextInputType.multiline,
                    focusNode: groupChatsController.focusNode,
                    onChanged: (v) {
                      // if (v.isNotEmpty) {
                      //   groupChatsController.isShowSendButton = true;
                      //   groupChatsController.messageController.text = v;
                      // } else {
                      //   groupChatsController.isShowSendButton = false;
                      // }
                      print(v.length);
                      groupChatsController.onTextChanged(v);
                      if (v.length >= 800) {
                        // You could show a SnackBar, error, or shake animation here
                        showAlertMessage(
                            "This message is too long, Please shorter the message.");
                        print("Max character limit reached");
                      }
                    },
                    controller: groupChatsController.messageController,
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
                              //   onPressed: groupChatsController
                              //       .toggleEmojiKeyboardContainer,
                              //   // onPressed: () {},
                              //   icon: Obx(
                              //       () => groupChatsController.isShowEmojiContainer
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
                      suffixIcon: Obx(() => SizedBox(
                            width: !groupChatsController.isShowSendButton
                                ? 100
                                : 50,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                !groupChatsController.isShowSendButton
                                    ? IconButton(
                                        onPressed: () {
                                          groupChatsController.selectFile(
                                              MessageEnum.image.type);
                                        },
                                        icon: const Icon(
                                          Icons.camera_alt,
                                          color: greyMsgColor,
                                        ),
                                      )
                                    : SizedBox.shrink(),
                                IconButton(
                                  onPressed: () {
                                    // groupChatsController.selectVideo();
                                    groupChatsController.cancelReply();
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
                  await groupChatsController.sendTextMessage();
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 2, right: 2, bottom: 2),
                  child: CircleAvatar(
                    backgroundColor: textBarColor,
                    radius: 25,
                    child: Obx(() => Icon(
                          groupChatsController.isShowSendButton
                              ? Icons.send
                              : groupChatsController.isRecording
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
        Obx(() => groupChatsController.isShowEmojiContainer
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
            : const SizedBox.shrink()),
      ],
    );
  }
}
