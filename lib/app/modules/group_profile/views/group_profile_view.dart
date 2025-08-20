import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:genchatapp/app/common/widgets/gradient_container.dart';
import 'package:genchatapp/app/utils/alert_popup_utils.dart';

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
        final userCount =
            controller.groupDetails.users
                ?.where((u) => u.userGroupInfo?.isRemoved != true)
                .length ??
            0;

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
                        _showEditGroupNameDialog(
                          context,
                          controller.groupDetails,
                        );
                      } else if (value == 'add') {
                        controller.navigateToAddParticipant();
                      }
                    },
                    itemBuilder: (context) {
                      final items = <PopupMenuEntry<String>>[];
                      if (controller.canEditGroup) {
                        items.add(
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit Group Name'),
                          ),
                        );
                      }
                      if (controller.canAddParticipants) {
                        items.add(
                          const PopupMenuItem(
                            value: 'add',
                            child: Text('Add Participants'),
                          ),
                        );
                      }
                      return items;
                    },
                  ),
              ],
              flexibleSpace: LayoutBuilder(
                builder: (context, constraints) {
                  final top = constraints.biggest.height;
                  final isCollapsed =
                      top <=
                      kToolbarHeight + MediaQuery.of(context).padding.top;

                  return FlexibleSpaceBar(
                    centerTitle: true,
                    title: isCollapsed
                        ? Row(
                            children: [
                              const SizedBox(width: 48),
                              Obx(() {
                                if (controller.image == null &&
                                    (group?.displayPictureUrl ?? "").isEmpty) {
                                  return CircleAvatar(
                                    backgroundColor: AppColors.greyColor
                                        .withOpacity(0.4),
                                    radius: 20,
                                    child: Icon(
                                      Icons.group,
                                      color: AppColors.greyColor,
                                    ),
                                  );
                                } else if (controller.image != null) {
                                  return CircleAvatar(
                                    backgroundColor: AppColors.greyColor
                                        .withOpacity(0.4),
                                    backgroundImage: FileImage(
                                      controller.image!,
                                    ),
                                    radius: 20,
                                  );
                                } else {
                                  return CachedNetworkImage(
                                    imageUrl: group!.displayPictureUrl
                                        .toString(),
                                    imageBuilder: (context, image) {
                                      return CircleAvatar(
                                        backgroundColor: AppColors.greyColor
                                            .withOpacity(0.4),
                                        backgroundImage: image,
                                        radius: 20,
                                      );
                                    },
                                    placeholder: (context, url) =>
                                        const CircularProgressIndicator(),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                  );
                                }
                              }),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  group?.name ?? '',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
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
                          onTap: controller.canEditGroup
                              ? controller.selectImage
                              : null,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Obx(() {
                                if (controller.image == null &&
                                    (group?.displayPictureUrl ?? "").isEmpty) {
                                  return CircleAvatar(
                                    backgroundColor: AppColors.greyColor
                                        .withOpacity(0.4),
                                    radius: 64,
                                    child: Icon(
                                      Icons.group,
                                      size: 80.0,
                                      color: AppColors.greyColor,
                                    ),
                                  );
                                } else if (controller.image != null) {
                                  return CircleAvatar(
                                    backgroundColor: AppColors.greyColor
                                        .withOpacity(0.4),
                                    backgroundImage: FileImage(
                                      controller.image!,
                                    ),
                                    radius: 64,
                                  );
                                } else {
                                  return CachedNetworkImage(
                                    imageUrl: group!.displayPictureUrl
                                        .toString(),
                                    imageBuilder: (context, image) {
                                      return CircleAvatar(
                                        backgroundColor: AppColors.greyColor
                                            .withOpacity(0.4),
                                        backgroundImage: image,
                                        radius: 64,
                                      );
                                    },
                                    placeholder: (context, url) =>
                                        const CircularProgressIndicator(),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error, size: 70),
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
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Group - $userCount members",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
          body: GradientContainer(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Description
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8),
                    child: controller.canEditGroup
                        ? InkWell(
                            onTap: () => _showEditDescriptionDialog(
                              context,
                              controller.groupDetails,
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: Text(
                                group?.groupDescription ??
                                    'Add group description',
                                key: ValueKey(group?.groupDescription),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      group?.groupDescription == null ||
                                          group?.groupDescription == ""
                                      ? AppColors.textBarColor
                                      : AppColors.blackColor,
                                ),
                              ),
                            ),
                          )
                        : Text(
                            group?.groupDescription ?? 'No group description',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 8.0,
                      right: 8,
                      top: 10,
                    ),
                    child: Text(
                      "Created by ${controller.creatorUserDetail.localName}, ${formatDateTime(group?.createdAt)}",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Divider(),

                  /// Members Header
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "$userCount members",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (controller.canAddParticipants)
                          IconButton(
                            icon: Icon(
                              Symbols.group_add_rounded,
                              color: AppColors.textBarColor,
                            ),
                            onPressed: () {
                              controller.navigateToAddParticipant();
                            },
                          ),
                      ],
                    ),
                  ),

                  /// Members List

                  // const SizedBox(height: 4),
                  _buildMembersSection(users),

                  /// Exit Group
                  if (controller.canExitGroup) ...[
                    const Divider(),

                    const SizedBox(height: 10),

                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8),
                      child: InkWell(
                        onTap: () {
                          // exit logic here
                          showAlertMessageWithAction(
                            title: "Exit Group: ${group?.name}?",
                            message:
                                "Are you sure you want to leave this group.",
                            cancelText: "Cancel",
                            confirmText: "Exit group",
                            // onCancel: ()=> Get.back(),
                            onConfirm: () => controller.exitGroup(),
                            context: context,
                          );
                        },
                        child: const Row(
                          children: [
                            Icon(Symbols.logout_rounded, color: Colors.red),
                            SizedBox(width: 12),
                            Text(
                              "Exit Group",
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],


                  ///Delete Group
                  if (controller.isSuperAdmin) ...[
                    const Divider(),

                    const SizedBox(height: 10),

                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8),
                      child: InkWell(
                        onTap: () {
                          // exit logic here
                          showAlertMessageWithAction(
                              title: "Delete Group: ${group?.name}?",
                              message: "Are you sure you want to delete this group.",
                              cancelText: "Cancel",
                              confirmText: "Delete group",
                              // onCancel: ()=> Get.back(),
                              onConfirm: ()=> controller.deleteGroup(),
                              context: context
                          );

                        },
                        child: const Row(
                          children: [
                            Icon(Symbols.logout_rounded, color: Colors.red),
                            SizedBox(width: 12),
                            Text(
                              "Delete Group",
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMembersSection(List<User> allUsers) {
    final activeMembers = allUsers
        .where((u) => u.userGroupInfo?.isRemoved != true)
        .toList();
    final pastParticipants = allUsers
        .where((u) => u.userGroupInfo?.isRemoved == true)
        .toList();

    bool isPastExpanded = false;
    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (activeMembers.isNotEmpty)
              _buildUserList(activeMembers, isPast: false),
            if (pastParticipants.isNotEmpty) ...[
              // const SizedBox(height: 16),
              GestureDetector(
                onTap: () => setState(() => isPastExpanded = !isPastExpanded),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Past Participants (${pastParticipants.length})",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      Icon(
                        isPastExpanded ? Icons.expand_less : Icons.expand_more,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),
              if (isPastExpanded)
                _buildUserList(pastParticipants, isPast: true),
            ],
          ],
        );
      },
    );
  }

  Widget _buildUserList(List<User> users, {required bool isPast}) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index].userInfo;
        final perm = users[index].userGroupInfo;
        final isCreator =
            controller.groupDetails.group?.creatorId == perm?.userId;
        return buildUserTile(user, perm, isCreator, isPast: isPast);
      },
    );
  }

  Widget buildUserTile(
    UserInfo? user,
    UserGroupInfo? perm,
    bool isCreator, {
    required bool isPast,
  }) {
    final pictureUrl = user?.displayPictureUrl ?? '';
    return Opacity(
      opacity: isPast ? 0.6 : 1.0,
      child: IgnorePointer(
        ignoring: isPast, // disable actions if past participant
        child: PopupMenuButton<String>(
          offset: const Offset(0, 56),
          onSelected: (val) {
            final uid = user?.userId;
            if (uid == null) return;
            switch (val) {
              case 'make_admin':
                controller.makeAdmin(uid);
                break;
              case 'revoke_admin':
                controller.revokeAdmin(uid);
                break;
              case 'remove_member':
                controller.removeUser(uid);
                break;
            }
          },
          itemBuilder: (_) {
            final curUid = controller.sharedPreferenceService
                .getUserData()
                ?.userId;
            final isSelf = user?.userId == curUid;
            final isSuper =
                user?.userId == controller.groupDetails.group?.creatorId;
            final isAdmin = perm?.isAdmin == true;
            if (isSelf || isSuper) return [];
            final items = <PopupMenuEntry<String>>[];
            if (controller.isSuperAdmin) {
              items.add(
                isAdmin
                    ? const PopupMenuItem(
                        value: 'revoke_admin',
                        child: Text('Revoke Admin'),
                      )
                    : const PopupMenuItem(
                        value: 'make_admin',
                        child: Text('Make Admin'),
                      ),
              );
              items.add(
                const PopupMenuItem(
                  value: 'remove_member',
                  child: Text('Remove from Group'),
                ),
              );
            } else if (controller.isAdmin && !isAdmin) {
              items.add(
                const PopupMenuItem(
                  value: 'remove_member',
                  child: Text('Remove from Group'),
                ),
              );
            }
            return items;
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                // final userBlock = controller.getUerBlock(user!.userId);
                //
                FutureBuilder<bool>(
                  future: controller.getUerBlock(user!.userId),
                  builder: (_, snap) => pictureUrl.isEmpty || snap.data == true
                      ? CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.grey.withOpacity(0.4),
                          child: const Icon(Icons.person),
                        )
                      : CachedNetworkImage(
                          imageUrl: pictureUrl,
                          imageBuilder: (_, image) =>
                              CircleAvatar(backgroundImage: image, radius: 24),
                          placeholder: (_, __) =>
                              const CircularProgressIndicator(strokeWidth: 1.5),
                          errorWidget: (_, __, ___) => const CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.grey,
                            child: Icon(Icons.error),
                          ),
                        ),
                ),
                // pictureUrl.isEmpty || userBlock == true
                //     ? CircleAvatar(radius: 24, backgroundColor: Colors.grey.withOpacity(0.4), child: const Icon(Icons.person))
                //     : CachedNetworkImage(
                //   imageUrl: pictureUrl,
                //   imageBuilder: (_, image) => CircleAvatar(backgroundImage: image, radius: 24),
                //   placeholder: (_, __) => const CircularProgressIndicator(strokeWidth: 1.5),
                //   errorWidget: (_, __, ___) => const CircleAvatar(radius: 24, backgroundColor: Colors.grey, child: Icon(Icons.error)),
                // ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder<String>(
                        future: controller.getLocalName(
                          user?.userId,
                          user?.name,
                        ),
                        builder: (_, snap) => Text(
                          snap.data ?? "Loading…",
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.phoneNumber ?? '',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                if ((perm?.isAdmin == true) && !isPast)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.textBarColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isCreator ? "Super Admin" : "Admin",
                      style: TextStyle(
                        color: AppColors.textBarColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditGroupNameDialog(BuildContext context, GroupData groupDetails) {
    final textController = TextEditingController(
      text: groupDetails.group?.name,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Edit Group Name",
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 150),
              child: TextFormField(
                controller: textController,
                autofocus: true, // Opens keyboard automatically
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  hintText: "Enter group name...",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (textController.text.isNotEmpty) {
                  Navigator.of(context).pop();
                  controller.updateGroupName(textController.text);
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _showEditDescriptionDialog(
    BuildContext context,
    GroupData groupDetails,
  ) {
    final textController = TextEditingController(
      text: groupDetails.group?.groupDescription,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Edit Description",
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 150),
              child: TextFormField(
                controller: textController,
                autofocus: true, // Opens keyboard automatically
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  hintText: "Enter group description...",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (textController.text.isNotEmpty) {
                  Navigator.of(context).pop();
                  controller.updateGroupDescription(textController.text);
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }
}
