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
        title: GetX<SingleChatController>(builder: (ctc) {
          return Row(
            children: [
              ctc.receiveruserDataModel.value.profilePic != null
                  ? CachedNetworkImage(
                      imageUrl: ctc.receiveruserDataModel.value.profilePic!,
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    ctc.fullname,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      color: whiteColor,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    ctc.receiveruserDataModel.value.isOnline == true
                        ? "Online"
                        : "last seen ${lastSeenFormatted(ctc.receiveruserDataModel.value.lastSeen ?? "").toLowerCase()}",
                    style: const TextStyle(
                      fontWeight: FontWeight.w200,
                      color: whiteColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
        actions: [
          InkWell(
            onTap: () {},
            child: const Icon(Icons.video_call_outlined, color: whiteColor),
          ),
          InkWell(
            onTap: () {},
            child: const Icon(Icons.call, color: whiteColor),
          ),
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
              firebaseController: controller.firebaseController,
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
}
