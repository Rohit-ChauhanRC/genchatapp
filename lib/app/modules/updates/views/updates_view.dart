import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:genchatapp/app/common/widgets/gradient_container.dart';
import 'package:genchatapp/app/data/models/new_models/response_model/contact_response_model.dart';
import 'package:genchatapp/app/data/models/new_models/response_model/status_model.dart';

import 'package:genchatapp/app/modules/updates/widgets/status_title.dart';
import 'package:genchatapp/app/modules/updates/widgets/status_view.dart';
import 'package:genchatapp/app/utils/profile_image_dialog.dart';

import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import '../../../constants/colors.dart';
import '../../../routes/app_pages.dart';
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
      ),
      body: GradientContainer(
        child: Obx(() {
          final grouped = controller.groupedStatusMap;
          // if (grouped.isEmpty) return const SizedBox.shrink();

          return Column(
            children: [
              ListTile(
                onTap: () {
                  Get.toNamed(Routes.CAMERA);
                },
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
                      child: GestureDetector(
                        onTap: () {
                          Get.toNamed(Routes.CAMERA);
                        },
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
              grouped.isEmpty
                  ? const SizedBox.shrink()
                  : Container(
                      height: Get.height * 0.5,
                      child: ListView(
                        children: grouped.entries.map((entry) {
                          final userId = entry.key;
                          final statuses = entry.value;
                          // Statusmodel data = controller.groupedStatusMap[index];

                          UserList user = controller.contacts.firstWhereOrNull(
                            (contact) => contact.userId.toString() == userId,
                          )!;
                          return StatusTile(
                            name: user.localName!.isNotEmpty
                                ? user.localName!
                                : user.phoneNumber!,
                            statusTime: statuses.last.createdAt!,
                            userPic: user.displayPictureUrl!,
                            onTap: () {
                              // Get.to(
                              //   () => StatusView(
                              //     controller: controller,
                              //     statusList: statuses,
                              //     // status: status,
                              //     // startIndex: i,
                              //   ),
                              // );
                            },
                          );
                        }).toList(),
                      ),
                    ),
            ],
          );
        }),
      ),
    );
  }
}
