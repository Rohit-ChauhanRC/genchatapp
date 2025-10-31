import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:genchatapp/app/common/widgets/gradient_container.dart';
import 'package:genchatapp/app/data/models/chat_conntact_model.dart';
import 'package:genchatapp/app/modules/chats/controllers/chats_controller.dart';
import 'package:genchatapp/app/modules/updates/widgets/status_title.dart';
import 'package:genchatapp/app/modules/updates/widgets/status_view.dart';
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
        actions: [],
      ),
      body: GradientContainer(
        child: Obx(() {
          return ListView(
            children: [
              // My Status
              ListTile(
                leading: Stack(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      child: CachedNetworkImage(
                        imageUrl: controller.senderuserData!.displayPictureUrl
                            .toString(),
                        imageBuilder: (context, imageProvider) => CircleAvatar(
                          backgroundImage: imageProvider,
                          radius: 25,
                        ),
                        placeholder: (context, url) => const CircleAvatar(
                          radius: 25,
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) =>
                            const CircleAvatar(
                              radius: 25,
                              child: Icon(Icons.error),
                            ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(2),
                        child: const Icon(
                          Icons.add,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                title: const Text("My Status"),
                subtitle: const Text("Tap to add status update"),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  "Recent updates",
                  style: TextStyle(color: Colors.grey),
                ),
              ),

              ...controller.statusList.map(
                (status) => StatusTile(
                  status: status,
                  onTap: () {
                    // controller.markAsViewed(status);
                    Get.to(StatusView(controller: controller, status: status));
                  },
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
