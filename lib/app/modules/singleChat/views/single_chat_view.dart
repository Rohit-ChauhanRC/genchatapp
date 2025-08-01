import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:genchatapp/app/config/theme/app_colors.dart';
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
      resizeToAvoidBottomInset: true,
      backgroundColor: bgColor,

      appBar: AppBar(
        backgroundColor: textBarColor,
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: false,
        centerTitle: false,
        leading: Obx(() {
          final selectedCount = controller.selectedMessages.length;
          if (selectedCount > 0) {
            return IconButton(
              onPressed: controller.clearSelectedMessages,
              icon: const Icon(Symbols.close, color: whiteColor),
            );
          } else {
            return IconButton(
              icon: const Icon(Symbols.arrow_back, color: whiteColor),
              onPressed: () {
                Get.back(); // Or Navigator.pop(context)
              },
            );
          }
        }),
        title: Obx(() {
          final user = controller.receiverUserData;
          final selectedCount = controller.selectedMessages.length;
          return selectedCount > 0
              ? Text(
            "$selectedCount selected",
            style: TextStyle(
              fontSize: 20,
              color: whiteColor,
              fontWeight: FontWeight.bold,
            ),
          )
              : Row(
            children: [
              (user?.displayPictureUrl?.isNotEmpty ?? false)
                  ? CachedNetworkImage(
                      imageUrl: user!.displayPictureUrl.toString(),
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
                  : const CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
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
                      '${user?.localName == "" ||  user?.localName == null? user?.phoneNumber: user?.localName}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        color: whiteColor,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    // 👇 Wrap with Obx to reactively update UI
                    Obx(() {
                      if (!controller.connectivityService.isConnected.value) {
                        return const SizedBox.shrink();
                      }

                      if (controller.isReceiverTyping) {
                        return const Text(
                          "Typing...",
                          style: TextStyle(
                            fontWeight: FontWeight.w200,
                            color: whiteColor,
                            fontSize: 12,
                          ),
                        );
                      }

                      return Text(
                        user?.isOnline == true
                            ? "Online"
                            : "last seen ${lastSeenFormatted(user?.lastSeenTime ?? "").toLowerCase()}",
                        maxLines: 2,
                        style: const TextStyle(
                          fontWeight: FontWeight.w200,
                          color: whiteColor,
                          fontSize: 12,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          );
        }),
        actions: [
          Obx(() => controller.selectedMessages.isNotEmpty
              ? Row(
                children: [
                  IconButton(
                      icon: const Icon(Symbols.delete, color: whiteColor),
                      onPressed: () => _showDeletePopup(context, controller),
                    ),
                  if (controller.canForward)
                    IconButton(
                      icon: Icon(Symbols.forward, color: AppColors.whiteColor,),
                      onPressed: () {
                        controller.prepareToForward();
                      },
                    ),
                ],
              )
              : Row(
                  children: [
                    InkWell(
                      onTap: () {},
                      child: Icon(Symbols.videocam_rounded, color: AppColors.whiteColor),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    InkWell(
                      onTap: () {},
                      child: Icon(Symbols.call_rounded, color: AppColors.whiteColor),
                    ),
                  ],
                )),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert, color: whiteColor),
            offset: const Offset(0, 40),
            color: whiteColor,
            onSelected: (value) async {
              // Handle menu item selection
              switch (value) {
                case clearText:
                  print(clearText);
                  await controller.deleteTextMessage();
                  break;
                default:
              }
            },
            itemBuilder: (context) => [
              // PopupMenuItem(
              //   value: newGroup,
              //   onTap: () {},
              //   // ignore: prefer_const_constructors
              //   child: Text(
              //     newGroup,
              //     style: const TextStyle(
              //       fontSize: 14,
              //       fontWeight: FontWeight.w400,
              //       color: blackColor,
              //     ),
              //   ),
              // ),
              // const PopupMenuItem(
              //   value: settings,
              //   child: Text(
              //     settings,
              //     style: TextStyle(
              //       fontSize: 14,
              //       fontWeight: FontWeight.w400,
              //       color: blackColor,
              //     ),
              //   ),
              // ),
              const PopupMenuItem(
                value: clearText,
                child: Text(
                  clearText,
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
    // final isOnlySenderMessages = controller.selectedMessages.every(
    //     (msg) => msg.senderId == controller.senderuserData!.userId);

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
                controller.deleteMessages(deleteForEveryone: false);
              },
            ),
            if (controller.canDeleteForEveryone)
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text("Delete for Everyone"),
                onTap: () {
                  Navigator.pop(context);
                  controller.deleteMessages(deleteForEveryone: true);
                },
              ),
          ],
        );
      },
    );
  }
}
