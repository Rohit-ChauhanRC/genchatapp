import 'package:flutter/material.dart';
import 'package:genchatapp/app/modules/singleChat/controllers/single_chat_controller.dart';
import 'package:genchatapp/app/modules/singleChat/widgets/display_text_image_gif.dart';
import 'package:get/get.dart';

class MessageReplyPreview extends StatelessWidget {
  MessageReplyPreview({
    super.key,
  });

  final SingleChatController singleChatController = Get.find();

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width: 350,
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child:
                    Obx(() => singleChatController.messageReply.message != null
                        ? Text(
                            singleChatController.messageReply.isMe!
                                ? 'Me'
                                : 'Opposite',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : const SizedBox()),
              ),
              Obx(
                () => singleChatController.messageReply.message != null
                    ? GestureDetector(
                        child: const Icon(
                          Icons.close,
                          size: 16,
                        ),
                        onTap: () {
                          singleChatController.cancelReply();
                        },
                      )
                    : const SizedBox(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Obx(
            () => singleChatController.messageReply.message != null
                ? DisplayTextImageGIF(
                    message: singleChatController.messageReply.message!,
                    type: singleChatController.messageReply.messageEnum!,
                  )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }
}
