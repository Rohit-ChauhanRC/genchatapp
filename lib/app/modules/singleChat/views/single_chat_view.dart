import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:genchatapp/app/modules/singleChat/widgets/bottom_chat_field.dart';
import 'package:genchatapp/app/modules/singleChat/widgets/chat_list.dart';
import 'package:genchatapp/app/utils/time_utils.dart';

import 'package:get/get.dart';

import '../../../constants/colors.dart';
import '../../../constants/constants.dart';
import '../controllers/single_chat_controller.dart';

class SingleChatView extends GetView<SingleChatController> {
  const SingleChatView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: textBarColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Obx(() {
          final user = controller.receiverUserData;
          return Row(
            children: [
              user?.displayPictureUrl != null
                  ? CachedNetworkImage(
                      imageUrl: user?.displayPictureUrl ?? "",
                      imageBuilder: (context, image) {
                        return CircleAvatar(
                            backgroundColor: greyColor.withOpacity(0.4),
                            radius: 20,
                            backgroundImage: image);
                      },
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    )
                  : const SizedBox(),
              const SizedBox(
                width: 10,
              ),
              SizedBox(
                width: Get.width * 0.32,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${user?.localName}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        color: whiteColor,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      user?.isOnline == true
                          ? "Online"
                          : "last seen ${lastSeenFormatted(user?.lastSeenTime ?? "").toLowerCase()}", maxLines: 2,
                      style: const TextStyle(
                        fontWeight: FontWeight.w200,
                        color: whiteColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
        actions: [
          Obx(() => controller.selectedMessages.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.delete, color: whiteColor),
                  onPressed: () => _showDeletePopup(context, controller),
                )
              : Row(
                  children: [
                    InkWell(
                      onTap: () {},
                      child: const Icon(Icons.video_call_outlined,
                          color: whiteColor),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    InkWell(
                      onTap: () {},
                      child: const Icon(Icons.call, color: whiteColor),
                    ),
                  ],
                )),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert, color: whiteColor),
            offset: const Offset(0, 40),
            color: whiteColor,
            onSelected: (value) {
              // Handle menu item selection
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'newGroup',
                onTap: () {},
                child: Text(
                  newGroup,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: blackColor,
                  ),
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Text(
                  settings,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: blackColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ChatList(
              singleChatController: controller,
              // firebaseController: controller.firebaseController,
            ),
          ),
          BottomChatField(
            singleChatController: controller,
            onTap: () {
              controller.sendTextMessage();
              controller.cancelReply();
            },
          ),
        ],
      ),
    );
  }

  void _showDeletePopup(BuildContext context, SingleChatController controller) {
    final isOnlySenderMessages = controller.selectedMessages.every(
        (msg) => msg.senderId == controller.senderuserData!.userId.toString());

    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text("Delete for Me"),
              onTap: () {
                Navigator.pop(context);
                // controller.deleteMessages(deleteForEveryone: false);
              },
            ),
            if (isOnlySenderMessages)
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text("Delete for Everyone"),
                onTap: () {
                  Navigator.pop(context);
                  // controller.deleteMessages(deleteForEveryone: true);
                },
              ),
          ],
        );
      },
    );
  }
}
