import 'package:flutter/material.dart';

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
        iconTheme: IconThemeData(
          color: Colors.white
        ),
        title: Row(
          children: [
            CircleAvatar(
              // borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                "assets/images/genChatSplash.png",
                width: 30,
                height: 30,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10,),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Name', overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18,
                    color: whiteColor,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text("Online", style: TextStyle(fontWeight: FontWeight.w200, color: whiteColor, fontSize: 12),)
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.video_call_outlined, color: whiteColor),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.call, color: whiteColor),
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
                child: Text(
                  newGroup,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: blackColor,
                  ),
                ),
              ),
              PopupMenuItem(
                value: 'settings',
                child: Text(
                  settings,
                  style: const TextStyle(
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
