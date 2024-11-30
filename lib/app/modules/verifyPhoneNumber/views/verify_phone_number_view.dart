import 'package:flutter/material.dart';
import 'package:genchatapp/app/constants/colors.dart';

import 'package:get/get.dart';

import '../../../constants/constants.dart';
import '../../../widgets/gradientContainer.dart';
import '../controllers/verify_phone_number_controller.dart';

class VerifyPhoneNumberView extends GetView<VerifyPhoneNumberController> {
  const VerifyPhoneNumberView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => {Get.back()},
            icon: Icon(
              Icons.arrow_back,
              color: textBarColor,
            )),
        backgroundColor: appBarColor,
        title: Text(
          verifyPhoneNumber,
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w500, color: textBarColor),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: GradientContainer(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Form(
              key: controller.loginFormKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    verifyNumberTextForShowing,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: blackColor),
                  ),
                  SizedBox(height: 28,),
                  SizedBox(
                    width: Get.width * 0.8,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.only(top: 12, bottom: 12),
                          backgroundColor: whiteColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: textBarColor, width: 1,),
                        ),
                      ),
                      onPressed: controller.pickCountry,
                      icon: const Icon(Icons.arrow_drop_down, color: textBarColor,),
                      iconAlignment: IconAlignment.end,
                      label: Text(
                        chooseACountry,
                        style: TextStyle(fontSize: 14, color: blackColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: Get.width * 0.8,
                    child: TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      onChanged: (v) => controller.mobileNumber = v,
                      decoration:  InputDecoration(
                        filled: true,
                        fillColor: whiteColor,
                        prefixIcon: Padding(
                            padding: EdgeInsets.only(left: 10, right: 10, top: 14, bottom: 10),
                          child: Obx(() => controller.country != null
                              ? Text('+${controller.country!.phoneCode}')
                              : const SizedBox()),
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(color: textBarColor, width: 1)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(color: textBarColor, width: 1), // Border for enabled state
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(color: textBarColor, width: 2), // Border for focused state
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(color: Colors.red, width: 1), // Border for error state
                          ),
                        hintText: 'phone number',
                        hintStyle: TextStyle(color: greyColor, fontSize: 14, fontWeight: FontWeight.w200)
                      ),
                      validator: (value) => value!.length != 10
                          ? "Please enter valid mobile number!"
                          : null,
                      keyboardType: const TextInputType.numberWithOptions(
                          signed: false, decimal: false),
                    ),
                  ),
                  const SizedBox(height: 26,),
                  Obx(()=> controller.circularProgress ? SizedBox(
                    width: Get.width * 0.8,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.only(left: 60, right: 60),
                          backgroundColor: textBarColor),
                      onPressed: controller.sendPhoneNumber,
                      child: Text(
                        requestOTP,
                        style: TextStyle(fontSize: 14, color: whiteColor),
                      ),
                    ),
                  ) :
                  Center(child: CircularProgressIndicator(color: textBarColor,),))

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
