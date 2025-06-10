import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:genchatapp/app/config/theme/app_colors.dart';
import 'package:genchatapp/app/constants/colors.dart';
import 'package:genchatapp/app/data/models/chat_conntact_model.dart';
import 'package:genchatapp/app/data/models/new_models/response_model/contact_response_model.dart';
import 'package:genchatapp/app/routes/app_pages.dart';
import 'package:genchatapp/app/utils/alert_popup_utils.dart';
import 'package:genchatapp/app/utils/time_utils.dart';
import 'package:genchatapp/app/common/widgets/gradient_container.dart';

import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../constants/constants.dart';
import '../controllers/chats_controller.dart';

class ChatsView extends GetView<ChatsController> {
  const ChatsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: textBarColor,
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Obx(() {
          final selectedCount = controller.selectedChatUids.length;
          return Row(
            children: [
              if (selectedCount > 0)
                IconButton(
                  onPressed: controller.clearChatSelection,
                  icon: Icon(Symbols.close, color: AppColors.whiteColor),
                ),
              Text(
                selectedCount > 0 ? "$selectedCount selected" : 'GENCHAT',
                style: TextStyle(
                  fontSize: 20,
                  color: whiteColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          );
        }),
        actions: [
          Obx(() {
            final hasSelection = controller.selectedChatUids.isNotEmpty;

            return Row(
              children: [
                if (hasSelection)
                  IconButton(
                    icon: const Icon(Symbols.delete, color: whiteColor),
                    onPressed: () {
                      // _showDeleteConfirmationDialog(context);
                      showAlertMessageWithAction(
                          title: "Delete Chat?",
                          message:
                              "All messages and media will be deleted. Are you sure you want to continue?",
                          confirmText: "Delete",
                          cancelText: "Cancel",
                          onConfirm: () =>
                              controller.deleteSelectedChatsForMeOnly(),
                          context: context);
                    },
                  ),

                // Only show camera icon when no selection
                if (!hasSelection)
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.camera_alt_outlined,
                      color: whiteColor,
                    ),
                  ),

                // Always show the popup menu
                PopupMenuButton(
                  icon: const Icon(
                    Icons.more_vert,
                    color: whiteColor,
                  ),
                  offset: const Offset(0, 40),
                  color: whiteColor,
                  onSelected: (value) {
                    if (value == settings) {
                      Get.back();
                      Get.toNamed(Routes.SETTINGS);
                    } else if (value == newGroup) {
                      Get.toNamed(Routes.CREATE_GROUP);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: newGroup,
                      child: Text(
                        newGroup,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: blackColor),
                      ),
                    ),
                    const PopupMenuItem(
                      value: settings,
                      child: Text(
                        settings,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: blackColor),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
        ],
      ),
      body: GradientContainer(
        child: Column(
          children: [
            // Search Input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: TextFormField(
                onChanged: (value) =>
                    controller.searchText = value.trim().toLowerCase(),
                decoration: InputDecoration(
                  isDense: true,
                  filled: true,
                  // fillColor: whiteColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: textBarColor, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(
                      color: textBarColor,
                      width: 1,
                    ), // Border for enabled state
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(
                      color: textBarColor,
                      width: 2,
                    ), // Border for focused state
                  ),
                  hintText: 'Search',
                  hintStyle: const TextStyle(
                    color: greyColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w200,
                  ),
                ),
                keyboardType: TextInputType.text,
              ),
            ),

            const SizedBox(height: 10),

            // Chat List
            GetX<ChatsController>(
                init: Get.find<ChatsController>(),
                builder: (ctc) {
                  final contactsToDisplay = ctc.filteredContacts;
                  return contactsToDisplay.isNotEmpty
                      ? Expanded(
                          child: ListView.builder(
                            // padding: const EdgeInsets.only(top: 10),
                            itemCount: contactsToDisplay.length,
                            itemBuilder: (context, i) {
                              ChatConntactModel chatConntactModel =
                                  contactsToDisplay[i];
                              final isTyping = controller.socketService
                                      .typingStatusMap[chatConntactModel.uid] ==
                                  true;
                              final isSelected = controller.selectedChatUids
                                  .contains(chatConntactModel.uid);
                              return Container(
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.mySideBgColor.withOpacity(0.3)
                                      : Colors.transparent,
                                ),
                                child: InkWell(
                                  onTap: () {
                                    controller.hideKeyboard();
                                    if (controller
                                        .selectedChatUids.isNotEmpty) {
                                      controller.toggleChatSelection(
                                          chatConntactModel.uid!);
                                    } else {
                                      if (chatConntactModel.isGroup != 1) {
                                        Get.toNamed(Routes.SINGLE_CHAT,
                                            arguments: UserList(
                                              userId: int.parse(
                                                  chatConntactModel.uid!),
                                              name: chatConntactModel.name,
                                              displayPictureUrl:
                                                  chatConntactModel.profilePic,
                                              localName: chatConntactModel.name,
                                            ));
                                      } else if (chatConntactModel.isGroup ==
                                          1) {
                                        Get.toNamed(Routes.GROUP_CHATS,
                                            arguments: UserList(
                                              userId: int.parse(
                                                  chatConntactModel.uid!),
                                              name: chatConntactModel.name,
                                              displayPictureUrl:
                                                  chatConntactModel.profilePic,
                                              localName: chatConntactModel.name,
                                            ));
                                      }
                                    }
                                  },
                                  onLongPress: () {
                                    controller.toggleChatSelection(
                                        chatConntactModel.uid!);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 18, vertical: 10),
                                    child: Row(
                                      children: [
                                        // Profile Image
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                          child: chatConntactModel.profilePic ==
                                                      null ||
                                                  chatConntactModel
                                                      .profilePic!.isEmpty
                                              ? Container(
                                                  color: textBarColor,
                                                  child: CircleAvatar(
                                                    radius: 25,
                                                    child: Icon(
                                                      chatConntactModel
                                                                  .isGroup ==
                                                              1
                                                          ? Icons.group_rounded
                                                          : Icons.person,
                                                      color: whiteColor,
                                                      // size: 25,
                                                    ),
                                                  ))
                                              : CachedNetworkImage(
                                                  imageUrl: chatConntactModel
                                                      .profilePic
                                                      .toString(),
                                                  imageBuilder: (context,
                                                          imageProvider) =>
                                                      CircleAvatar(
                                                    backgroundImage:
                                                        imageProvider,
                                                    radius: 30,
                                                  ),
                                                  placeholder: (context, url) =>
                                                      const CircleAvatar(
                                                    radius: 30,
                                                    child:
                                                        CircularProgressIndicator(),
                                                  ),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          const CircleAvatar(
                                                    radius: 30,
                                                    child: Icon(Icons.error),
                                                  ),
                                                ),
                                        ),
                                        const SizedBox(width: 10),

                                        // Chat Info
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                chatConntactModel.name ?? "",
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: blackColor,
                                                ),
                                              ),
                                              Text(
                                                isTyping
                                                    ? "Typing..."
                                                    : (chatConntactModel
                                                            .lastMessage!
                                                            .isNotEmpty
                                                        ? controller
                                                            .encryptionService
                                                            .decryptText(
                                                                chatConntactModel
                                                                    .lastMessage
                                                                    .toString())
                                                        : ""),
                                                softWrap: true,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: isTyping
                                                      ? FontWeight.bold
                                                      : FontWeight.w300,
                                                  color: isTyping
                                                      ? AppColors.textBarColor
                                                      : AppColors.blackColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Timestamp
                                        Column(
                                          children: [
                                            Text(
                                              formatLastMessageTime(
                                                  chatConntactModel.timeSent
                                                      .toString()),
                                              style: TextStyle(
                                                fontWeight: chatConntactModel
                                                            .unreadCount! >
                                                        0
                                                    ? FontWeight.bold
                                                    : FontWeight.w300,
                                                color: chatConntactModel
                                                            .unreadCount! >
                                                        0
                                                    ? textBarColor
                                                    : blackColor,
                                                fontSize: 10,
                                              ),
                                            ),
                                            chatConntactModel.unreadCount! > 0
                                                ? Container(
                                                    decoration: BoxDecoration(
                                                      color: textBarColor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              Get.height / 2),
                                                    ),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10,
                                                        vertical: 5),
                                                    child: Text(
                                                      chatConntactModel
                                                          .unreadCount
                                                          .toString(),
                                                      softWrap: true,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w300,
                                                        color: whiteColor,
                                                      ),
                                                    ),
                                                  )
                                                : const SizedBox.shrink(),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      : Padding(
                          padding: EdgeInsets.only(top: Get.height / 3),
                          child: Text(
                            "No chats yet!\nStart chatting with your GenChat contacts.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ));
                  ;
                }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed(Routes.SELECT_CONTACTS);
        },
        backgroundColor: textBarColor,
        child: const Icon(
          Icons.add_comment,
          color: whiteColor,
          size: 30,
        ),
      ),
    );
  }
}
