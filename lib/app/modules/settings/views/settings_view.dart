import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:genchatapp/app/routes/app_pages.dart';
import 'package:genchatapp/app/common/widgets/gradient_container.dart';
import 'package:genchatapp/app/utils/alert_popup_utils.dart';

import 'package:get/get.dart';

import '../../../constants/colors.dart';
import '../../../constants/constants.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: textBarColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 18,
            color: whiteColor,
            fontWeight: FontWeight.w400,
          ),
        ),
        centerTitle: false,
      ),
      body: GradientContainer(
          child: Stack(
              alignment: Alignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(()=> InkWell(
                          onTap: () {
                            Get.toNamed(Routes.CREATE_PROFILE, arguments: true);
                          },
                          child: Row(
                            children: [
                              CachedNetworkImage(
                                imageUrl: controller.userData.displayPictureUrl ?? "",
                                imageBuilder: (context, image) {
                                  return CircleAvatar(
                                      backgroundColor: greyColor.withOpacity(0.4),
                                      radius: 30,
                                      backgroundImage: image);
                                },
                                placeholder: (context, url) =>
                                    const CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      controller.userData.name != ""
                                          ? controller.userData.name ?? ''
                                          : "",
                                      style: const TextStyle(
                                          fontSize: 18, fontWeight: FontWeight.w500),
                                    ),
                                    Text(
                                      controller.userData.phoneNumber != ""
                                          ? controller.userData.phoneNumber ?? ''
                                          : "",
                                      style: const TextStyle(
                                          color: greyColor,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14),
                                    )
                                  ],
                                ),
                              ),
                              // const Icon(
                              //   Icons.qr_code_sharp,
                              //   color: tabColor,
                              // )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Container(
                        width: double.infinity,
                        height: 1,
                        color: greyColor.withOpacity(.4),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      _settingsItemWidget(
                          title: "Delete Account",
                          description: "Your account will be deleted forever.",
                          icon: Icons.delete_forever_rounded,
                          onTap: () {}),
                      const SizedBox(
                        height: 10,
                      ),
                      _settingsItemWidget(
                          title: "Logout",
                          description: "You have to login again.",
                          icon: Icons.logout_rounded,
                          onTap: () async {
                            showAlertMessageWithAction(
                                title: "Confirm Logout?",
                                message: "• Your chat history will be cleared from this phone\n"
                                    "• You will be logged out from all GenChat groups\n"
                                "• All locally stored data (chats, groups, media) will be deleted",
                                confirmText: "Logout",
                                cancelText: "Cancel",
                                onConfirm: () async{
                                  await controller.logout((){
                                    Get.offAllNamed(Routes.LANDING);
                                  });
                                },
                                context: context);

                          }),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/images/genMakLogo.png",
                          width: 50,
                          height: 50,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        const Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              poweredBy,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: blackColor,
                                  height: 0.1),
                            ),
                            Text(
                              genmak,
                              style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: textBarColor),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
          )
      ),
    );
  }

  _settingsItemWidget(
      {String? title,
      String? description,
      IconData? icon,
      VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            color: greyColor,
            size: 25,
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$title",
                  style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.normal,
                      color: blackColor),
                ),
                const SizedBox(
                  height: 3,
                ),
                Text(
                  "$description",
                  style: const TextStyle(
                      color: greyColor,
                      fontWeight: FontWeight.normal,
                      fontSize: 14),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
