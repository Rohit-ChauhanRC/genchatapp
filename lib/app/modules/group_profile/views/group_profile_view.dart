import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:genchatapp/app/common/widgets/gradient_container.dart';

import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../common/widgets/user_avatar.dart';
import '../../../config/theme/app_colors.dart';
import '../../../data/models/new_models/response_model/create_group_model.dart';
import '../../../utils/time_utils.dart';
import '../controllers/group_profile_controller.dart';

class GroupProfileView extends GetView<GroupProfileController> {
  const GroupProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        final group = controller.groupDetails.group;
        final users = List<User>.from(controller.groupDetails.users ?? []);

        users.sort((a, b) {
          final aId = a.userGroupInfo?.userId;
          final bId = b.userGroupInfo?.userId;

          final isASuperAdmin = aId != null && aId == group?.creatorId;
          final isBSuperAdmin = bId != null && bId == group?.creatorId;

          if (isASuperAdmin && !isBSuperAdmin) return -1;
          if (!isASuperAdmin && isBSuperAdmin) return 1;

          final isAAdmin = a.userGroupInfo?.isAdmin ?? false;
          final isBAdmin = b.userGroupInfo?.isAdmin ?? false;

          if (isAAdmin && !isBAdmin) return -1;
          if (!isAAdmin && isBAdmin) return 1;

          final aName = a.userInfo?.name?.toLowerCase() ?? '';
          final bName = b.userInfo?.name?.toLowerCase() ?? '';
          return aName.compareTo(bName);
        });

        return NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: AppColors.textBarColor,
              leading: const BackButton(color: Colors.white),
              actions: [
                if (controller.canEditGroup || controller.canAddParticipants)
                  PopupMenuButton(
                  offset: const Offset(0, 40),
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditGroupNameDialog(context, controller.groupDetails);
                    } else if (value == 'add') {
                      controller.navigateToAddParticipant();
                    }
                  },
                  itemBuilder: (context) {
                    final items = <PopupMenuEntry<String>>[];
                    if (controller.canEditGroup) {
                      items.add(const PopupMenuItem(value: 'edit', child: Text('Edit Group Name')));
                    }
                    if (controller.canAddParticipants) {
                      items.add(const PopupMenuItem(value: 'add', child: Text('Add Participants')));
                    }
                    return items;
                  },
                ),
              ],
              flexibleSpace: LayoutBuilder(
                builder: (context, constraints) {
                  final top = constraints.biggest.height;
                  final isCollapsed =
                      top <= kToolbarHeight + MediaQuery.of(context).padding.top;

                  return FlexibleSpaceBar(
                    centerTitle: true,
                    title: isCollapsed
                        ? Row(
                      children: [
                        const SizedBox(width: 48),
                        Obx(() {
                          if (controller.image == null && (group?.displayPictureUrl ?? "").isEmpty) {
                            return CircleAvatar(
                              backgroundColor: AppColors.greyColor.withOpacity(0.4),
                              radius: 20,
                              child: Icon(Icons.group, color: AppColors.greyColor),
                            );
                          } else if (controller.image != null) {
                            return CircleAvatar(
                              backgroundColor: AppColors.greyColor.withOpacity(0.4),
                              backgroundImage: FileImage(controller.image!),
                              radius: 20,
                            );
                          } else {
                            return CachedNetworkImage(
                              imageUrl: group!.displayPictureUrl.toString(),
                              imageBuilder: (context, image) {
                                return CircleAvatar(
                                  backgroundColor: AppColors.greyColor.withOpacity(0.4),
                                  backgroundImage: image,
                                  radius: 20,
                                );
                              },
                              placeholder: (context, url) => const CircularProgressIndicator(),
                              errorWidget: (context, url, error) => const Icon(Icons.error),
                            );
                          }
                        }),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            group?.name ?? '',
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    )
                        : null,
                    background: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        InkWell(
                          onTap: controller.canEditGroup ? controller.selectImage : null,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Obx(() {
                                if (controller.image == null && (group?.displayPictureUrl ?? "").isEmpty) {
                                  return CircleAvatar(
                                    backgroundColor: AppColors.greyColor.withOpacity(0.4),
                                    radius: 64,
                                    child: Icon(Icons.group, size: 80.0, color: AppColors.greyColor),
                                  );
                                } else if (controller.image != null) {
                                  return CircleAvatar(
                                    backgroundColor: AppColors.greyColor.withOpacity(0.4),
                                    backgroundImage: FileImage(controller.image!),
                                    radius: 64,
                                  );
                                } else {
                                  return CachedNetworkImage(
                                    imageUrl: group!.displayPictureUrl.toString(),
                                    imageBuilder: (context, image) {
                                      return CircleAvatar(
                                        backgroundColor: AppColors.greyColor.withOpacity(0.4),
                                        backgroundImage: image,
                                        radius: 64,
                                      );
                                    },
                                    placeholder: (context, url) => const CircularProgressIndicator(),
                                    errorWidget: (context, url, error) => const Icon(Icons.error),
                                  );
                                }
                              }),

                              // 👇 Add/Edit Icon Overlay
                              if (controller.canEditGroup)
                                const Positioned(
                                  bottom: 6,
                                  right: 6,
                                  child: CircleAvatar(
                                    radius: 16,
                                    backgroundColor: Colors.black54,
                                    child: Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          group?.name ?? '',
                          style: const TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Group - ${users.length} members",
                          style: const TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                      ],
                    ),
                  );
                },
              ),
            )
          ],
          body: GradientContainer(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Description
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8,),
                  child: controller.canEditGroup
                      ? InkWell(
                    onTap: () => _showEditDescriptionDialog(context, controller.groupDetails),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        group?.groupDescription ?? 'Add group description',
                        key: ValueKey(group?.groupDescription),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: group?.groupDescription == null || group?.groupDescription == ""
                              ? AppColors.textBarColor
                              : AppColors.blackColor,
                        ),
                      ),
                    ),
                  )
                      : Text(
                    group?.groupDescription ?? 'No group description',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8, top: 10),
                  child: Text("Created by ${controller.creatorUserDetail.localName}, ${formatDateTime(group?.createdAt)}",
                      style: const TextStyle(
                          fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w400)),
                ),
                const SizedBox(height: 8),
                const Divider(),

                /// Members Header
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8,),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${users.length} members",
                        style:
                        const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      if (controller.canAddParticipants)
                      IconButton(
                        icon: Icon(Symbols.group_add_rounded,
                            color: AppColors.textBarColor),
                        onPressed: () {
                          controller.navigateToAddParticipant();
                        },
                      ),
                    ],
                  ),
                ),

                /// Members List
                ListView.builder(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index].userInfo;
                    final permission = users[index].userGroupInfo;
                    final isCreator = controller.groupDetails.group?.creatorId == permission?.userId;
                    return PopupMenuButton(
                      offset: const Offset(0, 56),
                      onSelected: (value) {
                        final userId = user?.userId;
                        if (userId == null) return;

                        switch (value) {
                          case 'make_admin':
                            // controller.makeAdmin(userId);
                            break;
                          case 'revoke_admin':
                            // controller.revokeAdmin(userId);
                            break;
                          case 'remove_member':
                            // controller.removeParticipant(userId);
                            break;
                        }
                      },
                      itemBuilder: (context) {
                        final currentUserId = controller.sharedPreferenceService.getUserData()?.userId;
                        final targetUserId = user?.userId;
                        final isTargetSuperAdmin = targetUserId == controller.groupDetails.group?.creatorId;
                        final isSelf = currentUserId == targetUserId;
                        final isTargetAdmin = permission?.isAdmin == true;

                        if (isSelf || isTargetSuperAdmin) return [];

                        final List<PopupMenuEntry<String>> options = [];

                        if (controller.isSuperAdmin) {
                          if (isTargetAdmin) {
                            options.add(const PopupMenuItem(value: 'revoke_admin', child: Text('Revoke Admin')));
                          } else {
                            options.add(const PopupMenuItem(value: 'make_admin', child: Text('Make Admin')));
                          }
                          options.add(const PopupMenuItem(value: 'remove_member', child: Text('Remove from Group')));
                        } else if (controller.isAdmin && !isTargetAdmin) {
                          options.add(const PopupMenuItem(value: 'remove_member', child: Text('Remove from Group')));
                        }

                        return options;
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundImage:
                              NetworkImage(user?.displayPictureUrl ?? ''),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FutureBuilder<String>(
                                    future: controller.getLocalName(user?.userId, user?.name),
                                    builder: (context, snapshot) {
                                      return Text(
                                        snapshot.data ?? "Loading...",
                                        style: const TextStyle(fontWeight: FontWeight.w500),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 4),
                                  Text(user?.phoneNumber ?? '',
                                      style: const TextStyle(
                                          fontSize: 13, color: Colors.grey)),
                                ],
                              ),
                            ),
                            if (permission?.isAdmin == true)
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppColors.textBarColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  isCreator ? "Super Admin" : "Admin",
                                  style: TextStyle(color: AppColors.textBarColor, fontSize: 10, fontWeight: FontWeight.w600),
                                ),
                              ),
                            // IconButton(
                            //   icon:
                            //   const Icon(Icons.remove_circle, color: Colors.red),
                            //   onPressed: () {
                            //     controller.removeParticipant(user.userId ?? 0);
                            //   },
                            // )
                          ],
                        ),
                      ),
                    );
                  },
                ),


                /// Exit Group
                if (controller.canExitGroup)...[
                  const Divider(),

                  const SizedBox(height: 10),

                  Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8),
                  child: InkWell(
                    onTap: () {
                      // exit logic here
                    },
                    child: const Row(
                      children: [
                        Icon(Symbols.logout_rounded, color: Colors.red),
                        SizedBox(width: 12),
                        Text(
                          "Exit Group",
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
      ]
              ],
            ),
          ),
        );
      }),
    );
  }

  void _showEditGroupNameDialog(BuildContext context, GroupData groupDetails) {
    final textController = TextEditingController(text: groupDetails.group?.name);
    Get.defaultDialog(
      title: "Edit Group Name",
      content: TextField(controller: textController),
      textConfirm: "Save",
      onConfirm: () {
        if (textController.text.isNotEmpty) {
          controller.updateGroupName(textController.text);
          Get.back();
        }
      },
    );
  }

  void _showEditDescriptionDialog(BuildContext context, GroupData groupDetails) {
    final textController =
    TextEditingController(text: groupDetails.group?.groupDescription);
    Get.defaultDialog(
      title: "Edit Description",
      content: TextField(controller: textController),
      textConfirm: "Save",
      onConfirm: () {
        if (textController.text.isNotEmpty) {
          controller.updateGroupDescription(textController.text);
          Get.back();
        }
      },
    );
  }
}
