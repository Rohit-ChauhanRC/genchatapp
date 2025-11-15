import 'package:flutter/material.dart';
import 'package:genchatapp/app/config/theme/app_colors.dart';
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
      width: Get.width,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.bgColor,
        // borderRadius: const BorderRadius.only(
        //   topLeft: Radius.circular(12),
        //   topRight: Radius.circular(12),
        // ),
        boxShadow: [
          BoxShadow(
            color:AppColors.blackColor,
            spreadRadius: -26,
            blurRadius: 20,
            offset: const Offset(0, -10), // changes position of shadow
          ),
        ],
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
                                ? 'you'
                                : '${singleChatController.receiverUserData?.localName}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : const SizedBox()),
              ),
              Obx(
                () => singleChatController.messageReply.message != null
                    ? InkWell(
                        child: const Icon(
                          Icons.close,
                          size: 20,
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
                    message: 
                        singleChatController.messageReply.message.toString(),
                    type: singleChatController.messageReply.messageType!,
                    isReply: true,
                    assetThumbnail: singleChatController.messageReply.assetsThumbnail,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
