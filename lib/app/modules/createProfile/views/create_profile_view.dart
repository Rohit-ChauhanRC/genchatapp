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
        title:  const Text(createYurProfile, style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w500, color: textBarColor),),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: GradientContainer(
          child: Padding(
            padding: const EdgeInsets.only(left: 18.0, right: 18.0, bottom: 18.0),
            child: Form(
              key: controller.createProfileKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      height: 140,
                      width: 140,
                      decoration: BoxDecoration(
                        color: greyColor.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(Get.height/2),
                        border: Border.all(color: textBarColor.withOpacity(0.7), width: 1),
                      ),
                      child: Icon(Icons.add_a_photo, size: 80.0, color: greyColor),
                    ),
                    SizedBox(height: 20,),
                    TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      onChanged: (v) => controller.profileName = v,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.person),
                        hintText: 'Profile Name',
                        hintStyle: TextStyle(color: greyColor, fontSize: 14, fontWeight: FontWeight.w200),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: textBarColor, width: 2),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: textBarColor, width: 2),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: greyColor, width: 2),
                        ),
                      ),
                      cursorColor: textBarColor,
                      validator: (value) => value!.isEmpty
                          ? "Please enter profile name!"
                          : null,
                      keyboardType: TextInputType.name,
                    ),
                    SizedBox(height: 10,),
                    TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      onChanged: (v) => controller.email = v,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.email),
                        hintText: 'Email',
                        hintStyle: TextStyle(color: greyColor, fontSize: 14, fontWeight: FontWeight.w200),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: textBarColor, width: 2),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: textBarColor, width: 2),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: greyColor, width: 2),
                        ),
                      ),
                      cursorColor: textBarColor,
                      validator: (value){
                        if (value == null || value.isEmpty) {
                          return "Email is required!";
                        } else if (!isEmail(value)) {
                          return "Please enter a valid email!";
                        }
                        return null;
                      },
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 50,),
                    SizedBox(
                      width: Get.width * 0.8,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.only(left: 60, right: 60),
                            backgroundColor: textBarColor),
                        onPressed: controller.createProfile,
                        child: Text(
                          next,
                          style: TextStyle(fontSize: 14, color: whiteColor),
                        ),
                      ),
                    ),
                  ],
                )
            ),
          ),
        ),
      )
    );
  }
}
