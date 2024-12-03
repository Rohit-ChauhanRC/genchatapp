import 'package:flutter/material.dart';
import 'package:genchatapp/app/widgets/gradientContainer.dart';

import 'package:get/get.dart';

import '../../../constants/colors.dart';
import '../../../constants/constants.dart';
import '../../../utils/utils.dart';
import '../controllers/create_profile_controller.dart';

class CreateProfileView extends GetView<CreateProfileController> {
  const CreateProfileView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: appBarColor,
          automaticallyImplyLeading: false,
          title: const Text(
            createYurProfile,
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: GradientContainer(
            child: Padding(
              padding:
                  const EdgeInsets.only(left: 18.0, right: 18.0, bottom: 18.0),
              child: Form(
                  key: controller.createProfileKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: controller.selectImage,
                        child: Obx(
                          () => controller.image == null
                              ? CircleAvatar(
                                  backgroundColor: greyColor.withOpacity(0.4),
                                  radius: 64,
                                  child: const Icon(Icons.add_a_photo,
                                      size: 80.0, color: greyColor),
                                )
                              : CircleAvatar(
                                  backgroundColor: greyColor.withOpacity(0.4),
                                  backgroundImage: FileImage(
                                    controller.image!,
                                  ),
                                  radius: 64,
                                ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
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
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        onChanged: (v) => controller.email = v,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.email),
                          hintText: 'Email',
                        ),
                        cursorColor: textBarColor,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Email is required!";
                          } else if (!isEmail(value)) {
                            return "Please enter a valid email!";
                          }
                          return null;
                        },
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      SizedBox(
                        width: Get.width * 0.8,
                        child: ElevatedButton(
                          onPressed: controller.createProfile,
                          child: const Text(
                            next,
                            style: TextStyle(fontSize: 14, color: whiteColor),
                          ),
                        ),
                      ),
                    ],
                  )),
            ),
          ),
        ));
  }
}
