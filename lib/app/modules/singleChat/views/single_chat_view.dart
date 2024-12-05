import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:genchatapp/app/utils/time_utils.dart';
import 'package:genchatapp/app/widgets/user_avatar.dart';

import 'package:get/get.dart';

import '../../../constants/colors.dart';
import '../../../constants/constants.dart';
import '../controllers/single_chat_controller.dart';

class SingleChatView extends GetView<SingleChatController> {
  const SingleChatView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: textBarColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: GetX<SingleChatController>(builder: (ctc) {
          return Row(
            children: [
              ctc.userDataModel.value.profilePic != null
                  ? CachedNetworkImage(
                      imageUrl: ctc.userDataModel.value.profilePic!,
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
                    ctc.userDataModel.value.name ?? "",
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      color: whiteColor,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    ctc.userDataModel.value.isOnline == true
                        ? "Online"
                        : "last seen ${lastSeenFormatted(ctc.userDataModel.value.lastSeen ?? "").toLowerCase()}",
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
              const PopupMenuItem(
                value: 'newGroup',
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
      body: const Center(
        child: Text(
          'SingleChatView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
