import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:genchatapp/app/config/services/firebase_controller.dart';
import 'package:genchatapp/app/constants/colors.dart';
import 'package:genchatapp/app/data/models/chat_conntact_model.dart';
import 'package:genchatapp/app/data/models/new_models/response_model/contact_response_model.dart';
import 'package:genchatapp/app/routes/app_pages.dart';
import 'package:genchatapp/app/utils/time_utils.dart';
import 'package:genchatapp/app/common/widgets/gradient_container.dart';

import 'package:get/get.dart';

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
        title: const Text(
          'Genchatapp',
          style: TextStyle(
            fontSize: 20,
            color: whiteColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.camera_alt_outlined,
                color: whiteColor,
              )),
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
                  Get.toNamed(Routes.SELECT_CONTACTS);
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
                        )),
                    const PopupMenuItem(
                        value: settings,
                        child: Text(
                          settings,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: blackColor),
                        )),
                    // PopupMenuItem(
                    //     value: logout,
                    //     onTap: () async {
                    //       await controller.sharedPreferenceService
                    //           .clear()
                    //           .then((onValue) {
                    //         Get.offAllNamed(Routes.LANDING);
                    //       });
                    //     },
                    //     child: Text(
                    //       logout,
                    //       style: TextStyle(
                    //           fontSize: 14,
                    //           fontWeight: FontWeight.w400,
                    //           color: blackColor),
                    //     ))
                  ])
        ],
      ),
      body: GradientContainer(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Column(
            children: [
              // Search Input
              TextFormField(
                onChanged: (v) {},
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

              const SizedBox(height: 10),

              // Chat List
              GetX<ChatsController>(
                  init: Get.find<ChatsController>(),
                  builder: (ctc) {
                    return ctc.contactsList.isNotEmpty
                        ? Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.only(top: 10),
                              itemCount: ctc.contactsList.length,
                              itemBuilder: (context, i) {
                                ChatConntactModel chatConntactModel =
                                    ctc.contactsList[i];
                                return InkWell(
                                  onTap: () {
                                    Get.toNamed(Routes.SINGLE_CHAT,
                                        arguments: UserList(
                                          userId:
                                              int.parse(chatConntactModel.uid!),
                                          name: chatConntactModel.name,
                                          displayPictureUrl:
                                              chatConntactModel.profilePic,
                                          localName: chatConntactModel.name,
                                        ));
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Row(
                                      children: [
                                        // Profile Image
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                          child: chatConntactModel.profilePic ==
                                                  null
                                              ? const Icon(Icons.person)
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
                                                chatConntactModel.lastMessage ??
                                                    "",
                                                softWrap: true,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w300,
                                                  color: blackColor,
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
                                );
                              },
                            ),
                          )
                        : const SizedBox.shrink();
                  }),
            ],
          ),
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
