import 'package:flutter/material.dart';
import 'package:genchatapp/app/config/theme/app_colors.dart';
import 'package:genchatapp/app/modules/group_chats/controllers/group_chats_controller.dart';
import 'package:genchatapp/app/modules/singleChat/controllers/single_chat_controller.dart';
import 'package:genchatapp/app/modules/singleChat/widgets/display_text_image_gif.dart';
import 'package:get/get.dart';

class GroupMessageReplyPreview extends StatelessWidget {
  GroupMessageReplyPreview({
    super.key,
  });

  final GroupChatsController groupChatsController = Get.find();

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
            color: AppColors.blackColor,
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
                    Obx(() => groupChatsController.messageReply.message != null
                        ? Text(
                            groupChatsController.messageReply.isMe!
                                ? 'you'
                                : '${groupChatsController.receiverUserData?.group?.name}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : const SizedBox()),
              ),
              Obx(
                () => groupChatsController.messageReply.message != null
                    ? InkWell(
                        child: const Icon(
                          Icons.close,
                          size: 20,
                        ),
                        onTap: () {
                          groupChatsController.cancelReply();
                        },
                      )
                    : const SizedBox(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Obx(
            () => groupChatsController.messageReply.message != null
                ? DisplayTextImageGIF(
                    message:
                        groupChatsController.messageReply.message.toString(),
                    type: groupChatsController.messageReply.messageType!,
                    isReply: true,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
