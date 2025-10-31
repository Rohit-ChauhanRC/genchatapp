import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genchatapp/app/constants/colors.dart';
import 'package:genchatapp/app/constants/constants.dart';
import 'package:genchatapp/app/data/models/status_model.dart';
import 'package:genchatapp/app/modules/updates/controllers/updates_controller.dart';
import 'package:get/get.dart';

class StatusView extends StatelessWidget {
  const StatusView({super.key, required this.controller, required this.status});

  final UpdatesController controller;
  final StatusModel status;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: controller.skip,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: textBarColor,
          title: Column(
            children: [
              Obx(
                () => LinearProgressIndicator(
                  value: controller.progress.value,
                  color: Colors.white,
                  backgroundColor: Colors.white24,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const SizedBox(width: 10),
                  CircleAvatar(backgroundImage: NetworkImage(status.imageUrl)),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        status.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        status.time,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          actions: [
            PopupMenuButton(
              icon: const Icon(Icons.more_vert, color: whiteColor),
              offset: const Offset(0, 40),
              color: textBarColor,
              onSelected: (value) async {
                // Handle menu item selection

                // if (value == clearText) {
                //   await controller.deleteTextMessage();
                // } else if (value == block) {
                //   await controller.blockUser();
                // } else if (value == unBlock) {
                //   await controller.unblockUser();
                // }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: messageText,
                  child: Text(
                    messageText,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: whiteColor,
                    ),
                  ),
                ),
                const PopupMenuItem(
                  value: voiceCall,
                  child: Text(
                    voiceCall,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: whiteColor,
                    ),
                  ),
                ),
                const PopupMenuItem(
                  value: videoCall,
                  child: Text(
                    videoCall,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: whiteColor,
                    ),
                  ),
                ),
                const PopupMenuItem(
                  value: viewContact,
                  child: Text(
                    viewContact,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: whiteColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Column(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // story image
            Container(
              color: Colors.white,
              height: 200,
              width: Get.width,
              margin: const EdgeInsets.only(top: 120),
              // alignment: Alignment.center,
              child: Image.network(
                status.imageUrl.toString(),
                height: Get.height,
                width: Get.width,
                fit: BoxFit.fill,

                // imageBuilder: (context, imageProvider) =>
                //     CircleAvatar(backgroundImage: imageProvider),
              ),
            ),
            // const SizedBox(height: 20),
            const Spacer(),
            // const Spacer(),
            // const Spacer(),

            // const Spacer(),
            Row(
              children: [
                const SizedBox(width: 10),
                SizedBox(
                  width: Get.width * .8,
                  child: TextFormField(
                    // maxLines: null,
                    style: const TextStyle(color: whiteColor),
                    // autofocus: true,
                    keyboardType: TextInputType.text,
                    onChanged: (v) {},

                    inputFormatters: [LengthLimitingTextInputFormatter(200)],
                    // maxLength: 800,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: textBarColor,

                      hintText: 'Reply',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(10),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 2, right: 2, bottom: 2),
                  child: CircleAvatar(
                    backgroundColor: textBarColor,
                    radius: 25,
                    child: Icon(Icons.send),
                  ),
                ),
              ],
            ),
            // progress bar
            const SizedBox(height: 10),
            // user info
          ],
        ),
      ),
    );
  }
}
