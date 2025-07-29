import 'package:flutter/material.dart';
import 'package:genchatapp/app/common/widgets/gradient_container.dart';
import 'package:genchatapp/app/common/widgets/user_avatar.dart';
import 'package:genchatapp/app/constants/colors.dart' as AppColors;
import 'package:genchatapp/app/constants/colors.dart';
import 'package:genchatapp/app/constants/constants.dart';

import 'package:get/get.dart';

import '../controllers/group_name_controller.dart';

class GroupNameView extends GetView<GroupNameController> {
  const GroupNameView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'New Group',
          style: TextStyle(color: Colors.white, fontSize: 15),
        ),
        backgroundColor: AppColors.textBarColor,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: GradientContainer(
        child: Padding(
          padding: const EdgeInsets.only(left: 18.0, right: 18.0, bottom: 18.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              InkWell(
                onTap: controller.selectImage,
                child: Obx(
                  () => controller.image == null
                      ? const UserAvatar()
                      : CircleAvatar(
                          backgroundColor: AppColors.greyColor.withOpacity(0.4),
                          backgroundImage: FileImage(controller.image!),
                          radius: 64,
                        ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onChanged: (v) => controller.groupName = v,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.group),
                  hintText: 'Group Name',
                ),
                cursorColor: AppColors.textBarColor,
                validator: (value) =>
                    value!.isEmpty ? "Please enter group name!" : null,
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 50),
              Obx(
                () =>
                    controller.groupName.isNotEmpty &&
                        !controller.circularProgress
                    ? SizedBox(
                        width: Get.width * 0.8,
                        child: ElevatedButton(
                          onPressed: controller.createGroup,
                          child: const Text(
                            newGroup,
                            style: TextStyle(fontSize: 14, color: whiteColor),
                          ),
                        ),
                      )
                    : controller.groupName.isNotEmpty &&
                          controller.circularProgress
                    ? const CircularProgressIndicator()
                    : const SizedBox(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
