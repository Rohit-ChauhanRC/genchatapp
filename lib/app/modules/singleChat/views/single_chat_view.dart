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
                Get.back();
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
                  style: const TextStyle(
                    fontSize: 20,
                    color: whiteColor,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : InkWell(
                  onTap: () {
                    controller.openUserProfile();
                  },
                  child: Row(
                    children: [
                      ((user?.displayPictureUrl?.isNotEmpty ?? false) &&
                              !controller.blocked.value)
                          ? CachedNetworkImage(
                              imageUrl: user!.displayPictureUrl.toString(),
                              imageBuilder: (context, image) {
                                return CircleAvatar(
                                  backgroundColor: greyColor.withOpacity(0.4),
                                  radius: 20,
                                  backgroundImage: image,
                                );
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
                      const SizedBox(width: 10),
                      SizedBox(
                        width: Get.width * 0.32,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              controller.getDisplayName(),
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 18,
                                color: whiteColor,
                                fontWeight: FontWeight.w400,
                              ),
                            ),

                            // 👇 Wrap with Obx to reactively update UI
                            Obx(() {
                              if (!controller
                                      .connectivityService
                                      .isConnected
                                      .value ||
                                  controller.blocked.value == true) {
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
                  ),
                );
        }),
        actions: [
          Obx(
            () => controller.selectedMessages.isNotEmpty
                ? Row(
                    children: [
                      IconButton(
                        icon: const Icon(Symbols.delete, color: whiteColor),
                        onPressed: () => _showDeletePopup(context, controller),
                      ),
                      if (controller.canForward)
                        IconButton(
                          icon: Icon(
                            Symbols.forward,
                            color: AppColors.whiteColor,
                          ),
                          onPressed: () {
                            controller.prepareToForward();
                          },
                        ),
                    ],
                  )
                : Row(
                    children: [
                      InkWell(
                        onTap: () {
                          showComingSoon(context);
                        },
                        child: Icon(
                          Symbols.videocam_rounded,
                          color: AppColors.whiteColor,
                        ),
                      ),
                      const SizedBox(width: 10),
                      InkWell(
                        onTap: () {
                          showComingSoon(context);
                        },
                        child: Icon(
                          Symbols.call_rounded,
                          color: AppColors.whiteColor,
                        ),
                      ),
                    ],
                  ),
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert, color: whiteColor),
            offset: const Offset(0, 40),
            color: whiteColor,
            onSelected: (value) async {
              // Handle menu item selection

              if (value == clearText) {
                await controller.deleteTextMessage();
              } else if (value == block) {
                await controller.blockUser();
                // await controller.unblockUser();
              } else if (value == unBlock) {
                await controller.unblockUser();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value:
                    controller.blocked.value &&
                        (controller.blockedByMe.value == 1 ||
                            controller.blockedByMe.value == 3)
                    ? unBlock
                    : block,
                child: Text(
                  controller.blocked.value &&
                          (controller.blockedByMe.value == 1 ||
                              controller.blockedByMe.value == 3)
                      ? unBlock
                      : block,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: blackColor,
                  ),
                ),
              ),
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
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ChatList(
                singleChatController: controller,
                // firebaseController: controller.firebaseController,
              ),
            ),
            Obx(
              () =>
                  (controller.blocked.value &&
                      (controller.blockedByMe.value == 1 ||
                          controller.blockedByMe.value == 3))
                  ? Container(
                      color: textBarColor,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                            onPressed: () async {
                              await controller.deleteTextMessage();
                            },
                            child: const Text(
                              "Delete Chats",
                              style: TextStyle(color: Colors.red, fontSize: 16),
                            ),
                          ),

                          (TextButton(
                            onPressed: () async {
                              await controller.unblockUser();
                            },
                            child: const Text(
                              "Unblock User",
                              style: TextStyle(color: whiteColor, fontSize: 16),
                            ),
                          )),
                        ],
                      ),
                    )
                  : BottomChatField(
                      singleChatController: controller,
                      onTap: () {
                        controller.sendTextMessage();
                        controller.cancelReply();
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // void _showDeletePopup(BuildContext context, SingleChatController controller) {
  //   // final isOnlySenderMessages = controller.selectedMessages.every(
  //   //     (msg) => msg.senderId == controller.senderuserData!.userId);
  //
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (ctx) {
  //       return SafeArea(
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             ListTile(
  //               leading: const Icon(Icons.delete_outline, color: Colors.red),
  //               title: const Text("Delete for Me"),
  //               onTap: () {
  //                 Navigator.pop(context);
  //                 controller.deleteMessages(deleteForEveryone: false);
  //               },
  //             ),
  //             if (controller.canDeleteForEveryone &&
  //                 controller.blocked == false)
  //               ListTile(
  //                 leading: const Icon(Icons.delete_forever, color: Colors.red),
  //                 title: const Text("Delete for Everyone"),
  //                 onTap: () {
  //                   Navigator.pop(context);
  //                   controller.deleteMessages(deleteForEveryone: true);
  //                 },
  //               ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }
  void _showDeletePopup(BuildContext context, SingleChatController controller) {
    // final isOnlySenderMessages = controller.selectedMessages.every(
    //     (msg) => msg.senderId == controller.senderuserData!.userId);

    showModalBottomSheet(
      context: context,
      builder: (ctx) {

        return

        SafeArea(child:
          Column(
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
        if (controller.canDeleteForEveryone &&
                        controller.blocked == false)
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text("Delete for Everyone"),
                onTap: () {
                  Navigator.pop(context);
                  controller.deleteMessages(deleteForEveryone: true);
                },
              ),
          ],
        ));
      },
    );
  }

  void showComingSoon(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          "Coming Soon",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text("This feature will be available soon."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}
