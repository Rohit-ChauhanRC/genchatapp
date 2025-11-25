import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:genchatapp/app/common/widgets/gradient_container.dart';
import 'package:genchatapp/app/data/models/new_models/response_model/contact_response_model.dart';
import 'package:genchatapp/app/data/models/new_models/response_model/status_model.dart';
import 'package:genchatapp/app/modules/updates/widgets/status_title.dart';
import 'package:genchatapp/app/modules/updates/widgets/status_view.dart';
import 'package:get/get.dart';
import '../../../constants/colors.dart';
import '../../../routes/app_pages.dart';
import '../../../utils/TImeFormat.dart';
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
          // self = true
        ],
      ),
      body: GradientContainer(
        child: Obx(() {
          final grouped = controller.groupedStatusMap;
          final myUserId = controller.senderuserData?.userId?.toString() ?? '';
          final myStatuses = grouped[myUserId];

          // Clone grouped map and remove your own statuses
          final others = Map<String, List<dynamic>>.from(grouped)
            ..remove(myUserId);

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              // -------- MY STATUS --------
              ListTile(
                onTap: () {
                  if (myStatuses != null && myStatuses.isNotEmpty) {
                    // View your own status
                    Get.to(
                      () => StatusView(
                        controller: controller,
                        statusList: myStatuses,
                        startIndex: 0,
                        isSelf: true,
                      ),
                    );
                  } else {
                    // Add new status
                    Get.toNamed(Routes.CAMERA);
                  }
                },
                leading: Stack(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.grey[800],
                      child: CachedNetworkImage(
                        imageUrl:
                            controller.senderuserData?.displayPictureUrl ?? '',
                        imageBuilder: (context, imageProvider) => CircleAvatar(
                          backgroundImage: imageProvider,
                          radius: 25,
                        ),
                        placeholder: (context, url) => const CircleAvatar(
                          radius: 25,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        errorWidget: (context, url, error) =>
                            const CircleAvatar(
                              radius: 25,
                              child: Icon(Icons.person, color: Colors.white70),
                            ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => Get.toNamed(Routes.CAMERA),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(2),
                          child: const Icon(
                            Icons.add,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                title: const Text(
                  "My Status",
                  style: TextStyle(color: Colors.black),
                ),
                subtitle: Text(
                  myStatuses != null && myStatuses.isNotEmpty
                      ? "Tap to view your status"
                      : "Tap to add status update",
                  style: const TextStyle(color: Colors.black38),
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  "Recent updates",
                  style: TextStyle(color: Colors.grey),
                ),
              ),

              // -------- RECENT UPDATES (OTHERS) --------
              if (others.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      "No recent updates",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                )
              else
                ...others.entries.map((entry) {
                  final userId = entry.key;
                  final List<Statusmodel> statuses =
                      entry.value as List<Statusmodel>;
                  final user = controller.contacts.firstWhereOrNull(
                    (contact) => contact.userId.toString() == userId,
                  );

                  return StatusTile(
                    name: (user?.localName?.isNotEmpty ?? false)
                        ? user!.localName!
                        : (user?.phoneNumber ?? ''),
                    statusTime: formatStatusTime(
                      context,
                      statuses.last.createdAt,
                    ),
                    userPic: user?.displayPictureUrl ?? "",
                    onTap: () {
                      Get.to(
                        () => StatusView(
                          controller: controller,
                          statusList: statuses,
                          startIndex: 0,
                        ),
                      );
                    },
                  );
                }),
            ],
          );
        }),
      ),
    );
  }
}
