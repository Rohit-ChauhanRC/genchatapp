import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:genchatapp/app/config/theme/app_colors.dart';

import 'package:get/get.dart';

import '../../../common/widgets/gradient_container.dart';
import '../../../constants/colors.dart';
import '../../../data/models/new_models/response_model/contact_response_model.dart';
import '../controllers/forward_messages_controller.dart';

class ForwardMessagesView extends GetView<ForwardMessagesController> {
  const ForwardMessagesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
          controller.selectedUserIds.isEmpty
              ? 'Forward To'
              : '${controller.selectedUserIds.length} selected',
          style: const TextStyle(color: Colors.white),
        )),
        actions: [
          Obx(() => controller.selectedUserIds.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.send, color: Colors.white),
            onPressed: controller.forwardMessages,
          )
              : const SizedBox.shrink()),
        ],
        backgroundColor: AppColors.textBarColor,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return GradientContainer(
          child: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.only(bottom: 60),
                children: [
                  _buildSearchBar(),

                  if (controller.showRecent)
                    _buildSectionTitle('Recent Chats'),
                  ...controller.filteredRecents.map(_buildUserTile),

                  if (controller.showAllContacts)
                    _buildSectionTitle('All Contacts'),
                  ...controller.nonRecentFilteredContacts.map(_buildUserTile),
                ],
              ),

              // Bottom "Sending to" section
              Obx(() => controller.selectedUserIds.isNotEmpty
                  ? Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  color: AppColors.textBarColor.withOpacity(0.15),
                  child: Text(
                    "Sending to: ${controller.selectedUserNames.join(', ')}",
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
                  : const SizedBox.shrink()),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Text(title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }


  Widget _buildUserTile(UserList user) {
    final isSelected = controller.selectedUserIds.contains(user.userId);

    return InkWell(
      onTap: () {
        controller.toggleSelection(user.userId!);
        controller.hideKeyboard();},
      child: Container(
        // margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.textBarColor.withOpacity(0.1) : Colors.transparent,
          // borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: Stack(
            children: [
              (user.displayPictureUrl?.isNotEmpty ?? false)
                  ? Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: CachedNetworkImage(
                                    imageUrl: user.displayPictureUrl.toString(),
                                    imageBuilder: (context, image) {
                    return CircleAvatar(
                        backgroundColor: greyColor.withOpacity(0.4),
                        radius: 25,
                        backgroundImage: image);
                                    },
                                    placeholder: (context, url) =>
                                    const CircularProgressIndicator(),
                                    errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                                  ),
                  )
                  : const Padding(
                    padding: EdgeInsets.only(right: 4.0),
                    child: CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, color: Colors.white),
                                  ),
                  ),
              if (isSelected)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.textBarColor,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(3),
                    child: const Icon(Icons.check, color: Colors.white, size: 16),
                  ),
                ),
            ],
          ),
          title: Text(user.localName ?? user.phoneNumber ?? '',
              style: const TextStyle(fontSize: 16)),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: TextFormField(
        onChanged: (val) => controller.searchQuery = val,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          hintText: "Search contacts...",
          hintStyle: const TextStyle(
            color: greyColor,
            fontSize: 14,
            fontWeight: FontWeight.w200,
          ),
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

