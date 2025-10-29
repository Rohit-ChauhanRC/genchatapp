import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:genchatapp/app/common/widgets/gradient_container.dart';

import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../constants/colors.dart';
import '../../../constants/constants.dart';
import '../controllers/otp_controller.dart';



class OtpView extends GetView<OtpController> {
  const OtpView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: appBarColor,
        title: const Text(
          "OTP",
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: greyColor),
        ),
        centerTitle: true,
      ),
      body: GradientContainer(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.06,
                vertical: height * 0.02,
              ),
              child: Form(
                key: controller.otpFormKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(height: height * 0.02),

                    // 🔹 Top Image
                    Flexible(
                      flex: 3,
                      child: Image.asset(
                        "assets/images/otpImg.png",
                        width: width * 0.7,
                        height: height * 0.25,
                        fit: BoxFit.contain,
                      ),
                    ),

                    SizedBox(height: height * 0.015),

                    // 🔹 Title
                    const Text(
                      verificationCode,
                      style: TextStyle(
                        color: textBarColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 28,
                      ),
                    ),

                    SizedBox(height: height * 0.01),

                    // 🔹 Info text
                    Flexible(
                      flex: 2,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: width * 0.02),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text:
                                "Waiting to automatically detect an SMS sent to +${Get.find<OtpController>().countryCode} ${Get.find<OtpController>().mobileNumber}",
                                style: const TextStyle(
                                    color: blackColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400),
                              ),
                              TextSpan(
                                text: "  Wrong Number?",
                                style: const TextStyle(
                                    color: textBarColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => Get.back(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: height * 0.02),

                    // 🔹 Pin Code Field
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.15),
                      child: PinCodeTextField(
                        appContext: context,
                        length: 4,
                        obscureText: false,
                        blinkWhenObscuring: true,
                        animationType: AnimationType.fade,
                        validator: (v) {
                          if (v!.length < 4) {
                            return "Enter 4-digit Code";
                          } else {
                            return null;
                          }
                        },
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.circle,
                          borderRadius: BorderRadius.circular(5),
                          fieldHeight: height * 0.07,
                          fieldWidth: width * 0.13,
                          activeColor: textBarColor.withOpacity(0.6),
                          inactiveColor: textBarColor.withOpacity(0.4),
                          selectedColor: textBarColor.withOpacity(0.7),
                        ),
                        cursorColor: textBarColor,
                        animationDuration:
                        const Duration(milliseconds: 300),
                        keyboardType: TextInputType.number,
                        onCompleted: (v) async {
                          if (v.length == 4) {
                            await controller.login();
                          }
                        },
                        onChanged: (val) {
                          controller.otp = val;
                        },
                        beforeTextPaste: (text) => true,
                      ),
                    ),

                    SizedBox(height: height * 0.015),

                    // 🔹 Resend Button
                    Obx(
                          () => TextButton(
                        onPressed: controller.isResendEnabled.value
                            ? controller.resendOtp
                            : null,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.message,
                                      color: controller.isResendEnabled.value
                                          ? textBarColor
                                          : greyColor,
                                      size: width * 0.05,
                                    ),
                                    SizedBox(width: width * 0.02),
                                    Text(
                                      "Resend SMS",
                                      style: TextStyle(
                                        color: controller.isResendEnabled.value
                                            ? textBarColor
                                            : greyColor,
                                        fontWeight: FontWeight.w500,
                                        fontSize: width * 0.035,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  controller.timerValue.value > 0
                                      ? "00:${controller.timerValue.value.toString().padLeft(2, '0')}"
                                      : "",
                                  style: TextStyle(
                                    color: controller.isResendEnabled.value
                                        ? textBarColor
                                        : greyColor,
                                    fontWeight: FontWeight.w400,
                                    fontSize: width * 0.035,
                                  ),
                                ),
                              ],
                            ),
                            Divider(
                              height: 1,
                              color: controller.isResendEnabled.value
                                  ? textBarColor
                                  : greyColor,
                              thickness: 1.6,
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: height * 0.03),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
