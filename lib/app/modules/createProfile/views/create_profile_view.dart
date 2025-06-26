import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:genchatapp/app/common/widgets/gradient_container.dart';
import 'package:genchatapp/app/common/widgets/user_avatar.dart';

import 'package:get/get.dart';

import '../../../constants/colors.dart';
import '../../../constants/constants.dart';
import '../../../utils/utils.dart';
import '../controllers/create_profile_controller.dart';

class CreateProfileView extends GetView<CreateProfileController> {
  const CreateProfileView({super.key});
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isRestoring = controller.restoreProgress.value > 0 &&
          controller.restoreProgress.value < 1;
      return WillPopScope(
          onWillPop: () async => !isRestoring, // Disable back if restoring
          child: Stack(
            children: [
              Scaffold(
                appBar: AppBar(
                  backgroundColor: appBarColor,
                  automaticallyImplyLeading:
                      controller.isFromInsideApp ? true : false,
                  title: const Text(
                    createYurProfile,
                  ),
                  centerTitle: true,
                ),
                body: SingleChildScrollView(
                  child: GradientContainer(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 18.0, right: 18.0, bottom: 18.0),
                      child: Form(
                          key: controller.createProfileKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: controller.selectImage,
                                child: Obx(() => controller.image == null &&
                                        controller.photoUrl == ""
                                    ? const UserAvatar()
                                    : controller.image != null
                                        ? CircleAvatar(
                                            backgroundColor:
                                                greyColor.withOpacity(0.4),
                                            backgroundImage: FileImage(
                                              controller.image!,
                                            ),
                                            radius: 64,
                                          )
                                        : CachedNetworkImage(
                                            imageUrl: controller.photoUrl,
                                            imageBuilder: (context, image) {
                                              return CircleAvatar(
                                                  backgroundColor: greyColor
                                                      .withOpacity(0.4),
                                                  radius: 64,
                                                  backgroundImage: image);
                                            },
                                            placeholder: (context, url) =>
                                                const CircularProgressIndicator(),
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(Icons.error),
                                          )),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              TextFormField(
                                controller: controller.profileNameController,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                onChanged: (v) => controller.profileName = v,
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.person),
                                  hintText: 'Profile Name',
                                ),
                                cursorColor: textBarColor,
                                validator: (value) => value!.isEmpty
                                    ? "Please enter profile name!"
                                    : null,
                                keyboardType: TextInputType.name,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              TextFormField(
                                controller: controller.emailController,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                onChanged: (v) => controller.email = v,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.email),
                                  hintText: 'Email',
                                  suffixIcon: Container(
                                    width: 100,
                                    decoration: const BoxDecoration(
                                        border: Border.fromBorderSide(
                                            BorderSide(color: Colors.black)),
                                        borderRadius: const BorderRadius.only(
                                            bottomRight: Radius.circular(30),
                                            topRight: Radius.circular(30))
                                        // borderRadius: BorderRadius.only(bottomLeft: )
                                        ),
                                    alignment: Alignment.center,
                                    child: const Text("@gmail.com"),
                                  ),
                                ),
                                cursorColor: textBarColor,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Email is required!";
                                  } else if (!value.contains("@") ||
                                      !value.contains(".")) {
                                    return "Please enter a valid email!";
                                  }
                                  return null;
                                },
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(
                                height: 50,
                              ),
                              Obx(
                                () => controller.circularProgress
                                    ? const Center(
                                        child: CircularProgressIndicator(
                                          color: textBarColor,
                                        ),
                                      )
                                    : SizedBox(
                                        width: Get.width * 0.8,
                                        child: ElevatedButton(
                                          onPressed: controller.updateProfile,
                                          child: const Text(
                                            next,
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: whiteColor),
                                          ),
                                        ),
                                      ),
                              )
                            ],
                          )),
                    ),
                  ),
                ),
              ),
              if (isRestoring) _buildRestoreProgressDialog(context),
            ],
          ));
    });
  }

  Widget _buildRestoreProgressDialog(BuildContext context) {
    return Stack(
      children: [
        const Opacity(
          opacity: 0.5,
          child: ModalBarrier(dismissible: false, color: Colors.black),
        ),
        Center(
          child: Container(
            width: Get.width * 0.8,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Obx(() => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Restoring Backup",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                        value: controller.restoreProgress.value),
                    const SizedBox(height: 12),
                    Text(
                      "Restoring ${controller.restoreCopiedFiles.value} of ${controller.restoreTotalFiles.value} files",
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Size: ${controller.restoreCopiedSize.value} MB / ${controller.restoreSize.value} MB",
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    const CircularProgressIndicator(),
                  ],
                )),
          ),
        )
      ],
    );
  }
}
