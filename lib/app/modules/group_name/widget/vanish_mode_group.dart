import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:genchatapp/app/common/widgets/gradient_container.dart';
import 'package:genchatapp/app/constants/colors.dart' as AppColors;
import 'package:genchatapp/app/data/models/new_models/response_model/contact_response_model.dart';
import 'package:genchatapp/app/modules/group_name/controllers/group_name_controller.dart';
import 'package:get/get.dart';

class VanishModeGroup extends StatelessWidget {
  const VanishModeGroup({super.key, required this.groupNameController});

  final GroupNameController groupNameController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Select User for vanish mode',
          style: TextStyle(color: Colors.white, fontSize: 15),
        ),
        backgroundColor: AppColors.textBarColor,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        // if (groupNameController.isLoading.value) {
        //   return const Center(child: CircularProgressIndicator());
        // }

        return GradientContainer(
          child: ListView(
            children: [...groupNameController.contacts.map(_buildUserTile)],
          ),
        );
      }),
    );
  }

  Widget _buildUserTile(UserList user) {
    final isSelected = groupNameController.selectedUserIdVanishMode.contains(
      user.userId,
    );

    return InkWell(
      onTap: () {
        // controller.toggleSelection(user.userId!);
        // controller.hideKeyboard();

        if (user.isBlocked == true) {
          //
        } else {
          groupNameController.toggleSelection(user.userId!);
          groupNameController.hideKeyboard();
        }
      },
      child: Container(
        // margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.textBarColor.withOpacity(0.1)
              : Colors.transparent,
          // borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: Stack(
            children: [
              ((user.displayPictureUrl?.isNotEmpty ?? false) &&
                      user.isBlocked == false)
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
                        errorWidget: (context, url, error) =>
                            const CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.grey,
                              child: Icon(Icons.error, color: Colors.white),
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
                    decoration: const BoxDecoration(
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
            user.isBlocked == true
                ? "${user.localName} (This user is blocked by you!)"
                : user.localName ?? user.phoneNumber ?? '',
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
