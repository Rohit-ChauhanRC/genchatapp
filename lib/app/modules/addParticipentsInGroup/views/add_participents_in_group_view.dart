import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../common/widgets/gradient_container.dart';
import '../../../config/theme/app_colors.dart';
import '../../../data/models/new_models/response_model/contact_response_model.dart';
import '../controllers/add_participents_in_group_controller.dart';

class AddParticipentsInGroupView
    extends GetView<AddParticipentsInGroupController> {
  const AddParticipentsInGroupView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
              () => Text(
            controller.selectedUserIds.isEmpty
                ? 'New Group'
                : 'New Group: ${controller.selectedUserIds.length} of ${controller.contacts.length} selected',
            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),
        ),
        actions: [
          Obx(
                () => controller.selectedUserIds.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: controller.addParticipants,
            )
                : const SizedBox.shrink(),
          ),
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
                  if (controller.showRecent) _buildSectionTitle('Recent Chats'),
                  ...controller.filteredRecents.map(_buildUserTile),
                  if (controller.showAllContacts)
                    _buildSectionTitle('All Contacts'),
                  ...controller.nonRecentFilteredContacts.map(_buildUserTile),
                ],
              ),

              // Bottom "Sending to" section
              Obx(
                    () => controller.selectedUserIds.isNotEmpty
                    ? Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 100,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    color: AppColors.textBarColor.withOpacity(0.15),
                    child: Text(
                      "Group member: ${controller.selectedUserNames.join(', ')}",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildUserTile(UserList user) {
    final isSelected = controller.selectedUserIds.contains(user.userId);
    final isAlreadyAdded = controller.existingMemberIds.contains(user.userId);

    return InkWell(
      onTap:  isAlreadyAdded
          ? null
          : () {
        controller.toggleSelection(user.userId!);
        controller.hideKeyboard();
      },
      child: Container(
        // margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isAlreadyAdded
              ? Colors.blue.shade100
              : isSelected
              ? AppColors.textBarColor.withOpacity(0.1)
              : Colors.transparent,
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
                      backgroundColor: AppColors.greyColor.withOpacity(
                        0.4,
                      ),
                      radius: 25,
                      backgroundImage: image,
                    );
                  },
                  placeholder: (context, url) =>
                  const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.grey,
                    child: const Icon(Icons.error, color: Colors.white),
                  ),
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
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
          title: Text(
            user.localName ?? user.phoneNumber ?? '',
            style: TextStyle(fontSize: 16, color: isAlreadyAdded ? Colors.grey : Colors.black,),
          ),
          subtitle: isAlreadyAdded
              ? Text("Already added", style: TextStyle(color: AppColors.textBarColor, fontWeight: FontWeight.bold))
              : null,
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
          hintStyle: TextStyle(
            color: AppColors.greyColor,
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
