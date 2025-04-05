import 'package:flutter/material.dart';
import 'package:genchatapp/app/routes/app_pages.dart';

import 'package:get/get.dart';

import '../../../constants/colors.dart';
import '../../../constants/constants.dart';
import 'package:genchatapp/app/common/widgets/gradient_container.dart';
import '../controllers/landing_controller.dart';

class LandingView extends GetView<LandingController> {
  const LandingView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: Text(
          welcomeToGenchat,
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 22, color: textBarColor),
        ),
        centerTitle: true,
      ),
      body: Stack(alignment: Alignment.center, children: [
        GradientContainer(
          child: Center(
            child: Image.asset(
              "assets/images/genMakLogo.png",
              width: 300,
              height: 300,
            ),
          ),
        ),
        Positioned(
            bottom: 10,
            child: Column(
              children: [
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(children: [
                    TextSpan(
                        text: tapAgreeAndContinue,
                        style: TextStyle(fontSize: 12, color: blackColor)),
                    TextSpan(
                        text: genmakTermsOfServices,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: textBarColor))
                  ]),
                ),
                SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.only(left: 60, right: 60),
                      backgroundColor: textBarColor),
                  onPressed: () => {
                    Get.toNamed(Routes.VERIFY_PHONE_NUMBER),
                  },
                  child: Text(
                    agreeAndContinue,
                    style: TextStyle(fontSize: 14, color: whiteColor),
                  ),
                )
              ],
            ))
      ]),
    );
  }
}
