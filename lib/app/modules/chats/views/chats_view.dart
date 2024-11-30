import 'package:flutter/material.dart';
import 'package:genchatapp/app/constants/colors.dart';
import 'package:genchatapp/app/routes/app_pages.dart';
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
              onPressed: (){},
              icon: const Icon(Icons.camera_alt_outlined, color: whiteColor,)
          ),
          PopupMenuButton(
              icon: const Icon(Icons.more_vert, color: whiteColor,),
              offset: Offset(0, 40),
              color: whiteColor,
              onSelected: (value) {},
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: settings,
                    child: GestureDetector(
                      onTap: (){},
                      child: Text(newGroup, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: blackColor),),
                    )
                ),
                PopupMenuItem(
                    value: settings,
                    child: GestureDetector(
                      onTap: (){},
                      child: Text(settings, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: blackColor),),
                    )
                )
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
                    borderSide: BorderSide(color: textBarColor, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: textBarColor,
                      width: 1,
                    ), // Border for enabled state
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
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
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 10),
                  itemCount: 10,
                  itemBuilder: (context, chatIndex) {
                    return InkWell(
                      onTap: (){
                        Get.toNamed(Routes.SINGLE_CHAT);
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            // Profile Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(25),
                              child: Image.asset(
                                "assets/images/genChatSplash.png",
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 10),

                            // Chat Info
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Name",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: blackColor,
                                    ),
                                  ),
                                  Text(
                                    "you: Hi..",
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w300,
                                      color: blackColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Timestamp
                            const Text(
                              "22/01/2024",
                              style: TextStyle(
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

