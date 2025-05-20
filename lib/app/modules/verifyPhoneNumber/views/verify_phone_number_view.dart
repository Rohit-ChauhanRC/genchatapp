import 'package:flutter/material.dart';
import 'package:genchatapp/app/constants/colors.dart';
import 'package:genchatapp/app/common/widgets/gradient_container.dart';

import 'package:get/get.dart';

import '../../../config/theme/app_colors.dart';
import '../../../constants/constants.dart';
import '../controllers/verify_phone_number_controller.dart';

class VerifyPhoneNumberView extends GetView<VerifyPhoneNumberController> {
  const VerifyPhoneNumberView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: const Text(
          verifyPhoneNumber,
        ),
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
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    verifyNumberTextForShowing,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: blackColor),
                  ),
                  const SizedBox(
                    height: 28,
                  ),
                  // SizedBox(
                  //   width: Get.width * 0.8,
                  //   child: ElevatedButton.icon(
                  //     style: ElevatedButton.styleFrom(
                  //       padding: const EdgeInsets.only(top: 12, bottom: 12),
                  //       backgroundColor: AppColors.blackColor.withOpacity(0.00),
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(20),
                  //         side: const BorderSide(
                  //           color: textBarColor,
                  //           width: 1,
                  //         ),
                  //       ),
                  //     ),
                  //     onPressed: controller.pickCountry,
                  //     icon: const Icon(
                  //       Icons.arrow_drop_down,
                  //       color: textBarColor,
                  //     ),
                  //     iconAlignment: IconAlignment.end,
                  //     label: Obx(() => controller.country != null
                  //         ? Text(
                  //             controller.country!.name,
                  //             style: const TextStyle(
                  //                 fontSize: 14, color: blackColor),
                  //           )
                  //         : const Text(
                  //             chooseACountry,
                  //             style: TextStyle(fontSize: 14, color: blackColor),
                  //           )),
                  //   ),
                  // ),
                  // const SizedBox(height: 15),
                  SizedBox(
                    width: Get.width * 0.8,
                    child: Obx(()=>
                       TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        onChanged: (v) => controller.mobileNumber = v,
                        decoration: InputDecoration(
                            filled: true,
                            // fillColor: whiteColor,
                            // prefixIcon: Padding(
                            //   padding: const EdgeInsets.only(
                            //       left: 10, right: 10, top: 14, bottom: 10),
                            //   child: Obx(() => controller.country != null
                            //       ? Text('+${controller.country!.phoneCode}')
                            //       : const SizedBox()),
                            // ),
                            hintText: 'phone number',
                            hintStyle: const TextStyle(
                                color: greyColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w200
                            ),
                          prefixIcon: InkWell(
                            onTap: controller.pickCountry,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 12),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    controller.country != null
                                        ? '+${controller.country!.phoneCode}'
                                        : '+91',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: blackColor,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_drop_down,
                                    color: textBarColor,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        validator: (value) {
                          String phone = value!.trim();
                          if (phone.isEmpty || phone.length < 10) {
                            return "Please enter a valid mobile number!";
                          }
                          return null;
                        },
                        keyboardType: const TextInputType.numberWithOptions(
                            signed: false, decimal: false),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 26,
                  ),
                  Obx(() => !controller.circularProgress
                      ? SizedBox(
                          width: Get.width * 0.8,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.only(left: 60, right: 60),
                                backgroundColor: textBarColor),
                            onPressed: controller.sendPhoneNumber,
                            child: const Text(
                              requestOTP,
                              style: TextStyle(fontSize: 14, color: whiteColor),
                            ),
                          ),
                        )
                      : const Center(
                          child: CircularProgressIndicator(
                            color: textBarColor,
                          ),
                        ))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
