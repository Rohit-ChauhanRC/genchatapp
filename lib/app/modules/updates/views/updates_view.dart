import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:genchatapp/app/common/widgets/gradient_container.dart';
import 'package:genchatapp/app/data/models/chat_conntact_model.dart';
import 'package:genchatapp/app/modules/chats/controllers/chats_controller.dart';
import 'package:genchatapp/app/utils/profile_image_dialog.dart';

import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import '../../../constants/colors.dart';
import '../controllers/updates_controller.dart';

class UpdatesView extends GetView<UpdatesController> {
  const UpdatesView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: textBarColor,
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: const Text(
          'Updates',
          style: TextStyle(
            fontSize: 20,
            color: whiteColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, color: whiteColor),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert, color: whiteColor),
          ),
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
                            // final isTyping = controller.socketService
                            //         .typingStatusMap[chatConntactModel.uid] ==
                            //     true && chatConntactModel.isGroup == 0;

                            return Container(
                              decoration: const BoxDecoration(
                                color: Colors.transparent,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 10,
                                ),
                                child: Row(
                                  children: [
                                    // Profile Image
                                    InkWell(
                                      onTap: () async {
                                        final Directory thumDir;
                                        // if (Platform.isAndroid) {
                                        //   thumDir = Directory(
                                        //     "/storage/emulated/0/Android/media",
                                        //   );
                                        // } else {
                                        thumDir =
                                            await getApplicationDocumentsDirectory();
                                        // }
                                        final fileName =
                                            chatConntactModel.profilePic!.split(
                                              "/",
                                            )[chatConntactModel.profilePic!
                                                    .split("/")
                                                    .length -
                                                1];
                                        final pngFileName = fileName.replaceAll(
                                          RegExp(r'\.jpg$'),
                                          '.png',
                                        ); // ensure .png
                                        final filePath =
                                            '${thumDir.path}/$pngFileName';

                                        print(filePath);
                                        showDialog(
                                          context: context,
                                          builder: (_) => ProfileImageDialog(
                                            imagePath: filePath,
                                            imageUrl:
                                                chatConntactModel.profilePic!,
                                            userName: chatConntactModel.name,
                                            isGroup:
                                                chatConntactModel.isGroup == 1,
                                          ),
                                        );
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(25),
                                        child:
                                            (chatConntactModel.profilePic ==
                                                    null ||
                                                chatConntactModel
                                                    .profilePic!
                                                    .isEmpty ||
                                                chatConntactModel.isBlocked ==
                                                    1)
                                            ? Container(
                                                color: textBarColor,
                                                child: CircleAvatar(
                                                  radius: 25,
                                                  child: Icon(
                                                    chatConntactModel.isGroup ==
                                                            1
                                                        ? Icons.group_rounded
                                                        : Icons.person,
                                                    color: whiteColor,
                                                    // size: 25,
                                                  ),
                                                ),
                                              )
                                            : CachedNetworkImage(
                                                imageUrl: chatConntactModel
                                                    .profilePic
                                                    .toString(),
                                                imageBuilder:
                                                    (context, imageProvider) =>
                                                        CircleAvatar(
                                                          backgroundImage:
                                                              imageProvider,
                                                          radius: 25,
                                                        ),
                                                placeholder: (context, url) =>
                                                    const CircleAvatar(
                                                      radius: 25,
                                                      child:
                                                          CircularProgressIndicator(),
                                                    ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        const CircleAvatar(
                                                          radius: 25,
                                                          child: Icon(
                                                            Icons.error,
                                                          ),
                                                        ),
                                              ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),

                                    // Chat Info
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          controller.hideKeyboard();

                                          // if (chatConntactModel.isGroup !=
                                          //     1) {
                                          //   Get.toNamed(
                                          //     Routes.SINGLE_CHAT,
                                          //     arguments: UserList(
                                          //       userId: int.parse(
                                          //         chatConntactModel.uid!,
                                          //       ),
                                          //       name: chatConntactModel.name,
                                          //       displayPictureUrl:
                                          //           chatConntactModel
                                          //               .profilePic,
                                          //       localName:
                                          //           chatConntactModel.name,
                                          //     ),
                                          //   );
                                          // } else if (chatConntactModel
                                          //         .isGroup ==
                                          //     1) {
                                          // Get.toNamed(
                                          //   Routes.GROUP_CHATS,
                                          //   arguments: GroupData(
                                          //     group: Group(
                                          //       id: int.parse(
                                          //         chatConntactModel.uid
                                          //             .toString(),
                                          //       ),
                                          //       name:
                                          //           chatConntactModel.name,
                                          //       displayPictureUrl:
                                          //           chatConntactModel
                                          //               .profilePic,
                                          //     ),
                                          //   ),
                                          // );
                                          // }
                                        },

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
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : Padding(
                        padding: EdgeInsets.only(top: Get.height / 3),
                        child: const Text(
                          "No status yet!\nStart status with your GenChat contacts.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      );
                ;
              },
            ),
          ],
        ),
      ),
    );
  }
}
