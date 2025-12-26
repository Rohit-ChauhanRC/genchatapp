import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:genchatapp/app/constants/colors.dart';
import 'package:genchatapp/app/constants/constants.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../../common/widgets/gradient_container.dart';
import '../../../config/theme/app_colors.dart';
import '../../../data/models/new_models/response_model/contact_response_model.dart';
import '../../../routes/app_pages.dart';
import '../../singleChat/controllers/single_chat_controller.dart';
import '../../singleChat/views/single_chat_view.dart';

class SingleUserProfileView extends StatelessWidget {
  final UserList? user;
  const SingleUserProfileView({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    final SingleChatController controller = Get.find<SingleChatController>();
    return Scaffold(
      backgroundColor: Colors.teal.shade700,

      body: GradientContainer(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              automaticallyImplyLeading: false,
              iconTheme: const IconThemeData(color: Colors.white),

              expandedHeight: 300,
              pinned: true,

              backgroundColor: AppColors.textBarColor,

              leading: const BackButton(color: Colors.white),
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 10, bottom: 16),
                title: Text(
                  controller.getDisplayName(),
                  style: const TextStyle(color: Colors.white),
                ),
                background: Stack(
                  children: [
                    // Obx(
                    //   () =>
                    Container(
                      width: double.infinity,
                      height: double.infinity,

                      // color: AppColors.greyColor
                      //     .withOpacity(0.4),
                      child:
                          controller
                              .receiverUserData!
                              .displayPictureUrl!
                              .isNotEmpty
                          // &&
                          //     (!controller.blocked.value ||
                          //         (controller.blocked.value &&
                          //             controller.blockedByMe.value == 1))
                          ? CachedNetworkImage(
                              imageUrl: controller
                                  .receiverUserData!
                                  .displayPictureUrl
                                  .toString(),
                              imageBuilder: (context, image) {
                                return Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: image,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              },
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            )
                          // Image.network(
                          //     user.displayPictureUrl!,
                          //     fit: BoxFit.cover,
                          //   )
                          : const Center(
                              child: Icon(
                                Icons.person,
                                size: 120,
                                color: Colors.white,
                              ),
                            ),
                      // ),
                    ),

                    Container(color: Colors.black26),

                    Positioned(
                      bottom: 20,
                      right: 20,
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => showComingSoon(context),
                            child: _headerAction(Icons.videocam_rounded),
                          ),
                          const SizedBox(width: 14),

                          GestureDetector(
                            onTap: () => showComingSoon(context),
                            child: _headerAction(Icons.call_rounded),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // CONTENT
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  // Card: User info
                  _sectionCard(
                    children: [
                      _tile(
                        title:
                            (controller.receiverUserData!.localName != null &&
                                controller
                                    .receiverUserData!
                                    .localName!
                                    .isNotEmpty)
                            ? controller.receiverUserData!.localName!
                            : "+${controller.receiverUserData!.countryCode ?? ''} ${controller.receiverUserData!.phoneNumber ?? ''}",
                        subtitle: "Name",
                        icon: Icons.person,
                      ),

                      _tile(
                        title:
                            "+${controller.receiverUserData!.countryCode ?? ''} ${controller.receiverUserData!.phoneNumber ?? ''}",
                        subtitle: "Phone Number",
                        icon: Icons.phone,
                        trailing: GestureDetector(
                          onTap: () => Get.back(),

                          child: const Icon(Icons.message),
                        ),
                      ),
                      if (controller.receiverUserData!.userDescription !=
                              null &&
                          controller
                              .receiverUserData!
                              .userDescription!
                              .isNotEmpty)
                        _tile(
                          title: controller.receiverUserData!.userDescription!,
                          subtitle: "About",
                          icon: Icons.info_outline,
                        ),

                      Obx(
                        () => (controller.userExist.value)
                            ? _tile(
                                title: saveContact,
                                subtitle: "Save Contact",
                                icon: Icons.person,
                                //  trailing: GestureDetector(
                                //     onTap: () => Get.back(),

                                //      child: const Icon(Icons.message),
                                //   ),
                                onTap: () {
                                  controller.showSaveContactDialog(
                                    Get.context!,
                                  );
                                },
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  //
                  const SizedBox(height: 12),

                  // Settings: Mute, Wall
                  _sectionCard(
                    children: [
                      Obx(() {
                        final isBlocked =
                            controller.blocked.value &&
                                (controller.blockedByMe.value == 1 ||
                                    controller.blockedByMe.value == 2)
                            ? true
                            : false;

                        return _tile(
                          title: isBlocked
                              ? "Unblock ${controller.receiverUserData!.localName ?? ''}"
                              : "Block ${controller.receiverUserData!.localName ?? ''}",
                          icon: isBlocked ? Icons.lock_open : Icons.block,
                          titleColor: isBlocked ? Colors.green : Colors.red,
                          iconColor: isBlocked ? Colors.green : Colors.red,
                          onTap: () {
                            if (isBlocked) {
                              controller.unblockUser();
                            } else {
                              controller.blockUser();
                            }
                          },
                        );
                      }),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Header action button
  Widget _headerAction(IconData icon) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: Colors.black54,
      child: Icon(icon, color: Colors.white),
    );
  }

  Widget _sectionCard({required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          const BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _tile({
    required String title,
    String? subtitle,
    required IconData icon,
    Color? titleColor,
    Color? iconColor,
    Widget? trailing,
    Function()? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: iconColor ?? Colors.teal),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: titleColor ?? Colors.black,
        ),
      ),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing,
    );
  }

  Widget _mediaShortcut(
    IconData icon,
    String label,
    Color color,
    BuildContext context,
  ) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => showComingSoon(context),
          child: CircleAvatar(
            radius: 26,
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, color: color),
          ),
        ),
        const SizedBox(height: 6),
        Text(label),
      ],
    );
  }

  void showComingSoon(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          "Coming Soon",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text("This feature will be available soon."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}
