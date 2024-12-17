import 'dart:io';

import 'package:flutter/material.dart';
import 'package:genchatapp/app/config/services/firebase_controller.dart';
import 'package:genchatapp/app/constants/colors.dart';
import 'package:genchatapp/app/data/models/chat_conntact_model.dart';
import 'package:genchatapp/app/routes/app_pages.dart';
import 'package:genchatapp/app/utils/time_utils.dart';
import 'package:genchatapp/app/widgets/gradientContainer.dart';

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
              onSelected: (value) {},
              itemBuilder: (context) => [
                    PopupMenuItem(
                        value: settings,
                        child: GestureDetector(
                          onTap: () {},
                          child: const Text(
                            newGroup,
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: blackColor),
                          ),
                        )),
                    PopupMenuItem(
                        value: settings,
                        child: GestureDetector(
                          onTap: () {
                            Get.back();
                            Get.toNamed(Routes.SETTINGS);
                          },
                          child: const Text(
                            settings,
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: blackColor),
                          ),
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
                  fillColor: whiteColor,
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
                                    Get.toNamed(Routes.SINGLE_CHAT, arguments: [
                                      chatConntactModel.uid,
                                      chatConntactModel.name
                                    ]);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Row(
                                      children: [
                                        // Profile Image
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                          child: chatConntactModel
                                                  .profilePic.isEmpty
                                              ? Image.asset(
                                                  "assets/images/genChatSplash.png",
                                                  width: 50,
                                                  height: 50,
                                                  fit: BoxFit.cover,
                                                )
                                              : CircleAvatar(
                                                  backgroundImage: Image.file(
                                                    File(chatConntactModel
                                                        .profilePic),
                                                    fit: BoxFit.cover,
                                                  ).image,
                                                  radius: 30,
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
                                                chatConntactModel.name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: blackColor,
                                                ),
                                              ),
                                              Text(
                                                chatConntactModel.lastMessage,
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
                                        Text(
                                          lastSeenFormatted(chatConntactModel
                                              .timeSent.microsecondsSinceEpoch
                                              .toString()),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w300,
                                            color: blackColor,
                                            fontSize: 10,
                                          ),
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
