import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:genchatapp/app/constants/colors.dart';
import 'package:genchatapp/app/constants/colors.dart' as AppColors;
import 'package:genchatapp/app/constants/constants.dart';
import 'package:genchatapp/app/modules/group_chats/widgets/group_bottom_chat_field.dart';
import 'package:genchatapp/app/modules/group_chats/widgets/group_chat_list.dart';
import 'package:genchatapp/app/modules/group_chats/widgets/message_info.dart';
import 'package:genchatapp/app/modules/message_info/views/message_info_view.dart';
import 'package:genchatapp/app/routes/app_pages.dart';
import 'package:genchatapp/app/utils/time_utils.dart';

import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../controllers/group_chats_controller.dart';

class GroupChatsView extends GetView<GroupChatsController> {
  const GroupChatsView({super.key});
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
              icon: const Icon(Symbols.arrow_back_ios, color: whiteColor),
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
                  style: const TextStyle(
                    fontSize: 20,
                    color: whiteColor,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : InkWell(
                  onTap: controller.isCurrentUserRemoved
                      ? null
                      : () => Get.toNamed(
                          Routes.GROUP_PROFILE,
                          arguments: controller.groupId,
                        ),
                  child: Row(
                    children: [
                      (user?.group?.displayPictureUrl?.isNotEmpty ?? false)
                          ? CachedNetworkImage(
                              imageUrl: user?.group?.displayPictureUrl ?? "",
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
                              child: Icon(Icons.group, color: Colors.white),
                            ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: Get.width * 0.32,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${user?.group?.name}',
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
                                  .value) {
                                return const SizedBox.shrink();
                              }

                              if (controller.typingDisplayText.isNotEmpty) {
                                return Text(
                                  controller.typingDisplayText,
                                  maxLines: 2,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w200,
                                    color: whiteColor,
                                    fontSize: 12,
                                  ),
                                );
                              }

                              return Text(
                                controller.groupMemberNames,
                                // user?.group?.isActive == true
                                //     ? "Online"
                                //     : "last seen ${lastSeenFormatted(user?.group?.updatedAt ?? "").toLowerCase()}",
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
                          icon: const Icon(
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
                        child: const Icon(
                          Symbols.videocam_rounded,
                          color: AppColors.whiteColor,
                        ),
                      ),
                      const SizedBox(width: 10),
                      InkWell(
                        onTap: () {
                          showComingSoon(context);
                        },
                        child: const Icon(
                          Symbols.call_rounded,
                          color: AppColors.whiteColor,
                        ),
                      ),
                    ],
                  ),
          ),

          Obx(
            () =>
                controller.selectedMessages.isNotEmpty &&
                    controller.selectedMessages.length == 1 &&
                    controller.selectedMessages.first.senderId ==
                        controller.senderuserData!.userId
                ? PopupMenuButton(
                    icon: const Icon(Icons.more_vert, color: whiteColor),
                    offset: const Offset(0, 40),
                    color: whiteColor,
                    onSelected: (value) async {
                      // Handle menu item selection
                      switch (value) {
                        case messageInfo:
                          // debugPrint("clear text in group:$messageInfo");
                          // await controller.deleteTextMessage();
                          // Get.to(
                          //   MessageInfo(
                          //     selectedMessages:
                          //         controller.selectedMessages.first,
                          //     groupChatsController: controller,
                          //   ),
                          // );
                          Get.toNamed(
                            Routes.MESSAGE_INFO,
                            arguments: [
                              controller.selectedMessages.first,
                              controller.groupData.value!.users,
                            ],
                          );
                          break;
                        default:
                      }
                    },

                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: messageInfo,
                        child: Text(
                          messageInfo,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: blackColor,
                          ),
                        ),
                      ),
                    ],
                  )
                : controller.selectedMessages.isEmpty
                ? PopupMenuButton(
                    icon: const Icon(Icons.more_vert, color: whiteColor),
                    offset: const Offset(0, 40),
                    color: whiteColor,
                    onSelected: (value) async {
                      // Handle menu item selection
                      switch (value) {
                        case clearText:
                          // debugPrint("clear text in group:$clearText");
                          await controller.deleteTextMessage();
                          break;
                        default:
                      }
                    },

                    itemBuilder: (context) => [
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
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GroupChatList(
              groupChatsController: controller,
              // firebaseController: controller.firebaseController,
            ),
          ),
          // Obx(() {
          //   if (controller.isCurrentUserRemoved) {
          //     return SafeArea(
          //       child: Container(
          //         padding: const EdgeInsets.all(10),
          //         decoration: const BoxDecoration(
          //           color: AppColors.textBarColor,
          //         ),
          //         child: const Text(
          //           "You can't send messages to this group because you're no longer a member.",
          //           textAlign: TextAlign.center,
          //           style: TextStyle(
          //             color: AppColors.whiteColor,
          //             fontSize: 16,
          //             fontWeight: FontWeight.w600,
          //           ),
          //         ),
          //       ),
          //     );
          //   }
          //   else if (controller.groupData.value!.group!.isReadOnly != null &&
          //       controller.groupData.value!.group!.isReadOnly == true && controller.isSuperAdmin==true) {
          //     return SafeArea(
          //       child: Container(
          //         padding: const EdgeInsets.all(10),
          //         decoration: const BoxDecoration(
          //           color: AppColors.textBarColor,
          //         ),
          //         child: const Text(
          //           "Only Super Admin can send messages",
          //           textAlign: TextAlign.center,
          //           style: TextStyle(
          //             color: AppColors.whiteColor,
          //             fontSize: 16,
          //             fontWeight: FontWeight.w600,
          //           ),
          //         ),
          //       ),
          //     );
          //   } else {
          //     return GroupBottomChatField(
          //       groupChatsController: controller,
          //       onTap: () {
          //         controller.sendTextMessage();
          //         controller.cancelReply();
          //       },
          //     );
          //   }
          // }),
          Obx(() {
            final isReadOnly =
                controller.groupData.value?.group?.isReadOnly == true;
            final isSuperAdmin =
                controller.groupData.value?.group?.creatorId ==
                controller.senderuserData?.userId;

            if (controller.isCurrentUserRemoved) {
              return SafeArea(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  color: AppColors.textBarColor,
                  child: const Text(
                    "You can't send messages to this group because you're no longer a member.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.whiteColor, fontSize: 16),
                  ),
                ),
              );
            }

            ///  Read-only ON → only SuperAdmin can send
            if (isReadOnly && !isSuperAdmin) {
              return SafeArea(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  color: AppColors.textBarColor,
                  child: const Text(
                    "Only super admin can send messages",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.whiteColor, fontSize: 16),
                  ),
                ),
              );
            }

            /// Otherwise → normal message input box
            return GroupBottomChatField(
              groupChatsController: controller,
              onTap: () {
                controller.sendTextMessage();
                controller.cancelReply();
              },
            );
          }),
        ],
      ),
    );
  }

  void _showDeletePopup(BuildContext context, GroupChatsController controller) {
    // final isOnlySenderMessages = controller.selectedMessages.every(
    //     (msg) => msg.senderId == controller.senderuserData!.userId);

    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
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
                  !controller.isCurrentUserRemoved)
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text("Delete for Everyone"),
                  onTap: () {
                    Navigator.pop(context);
                    controller.deleteMessages(deleteForEveryone: true);
                  },
                ),
            ],
          ),
        );
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
