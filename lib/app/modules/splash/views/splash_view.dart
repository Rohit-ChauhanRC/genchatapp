import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:genchatapp/app/common/widgets/gradient_container.dart';
import '../../../constants/colors.dart';
import '../../../constants/constants.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(alignment: Alignment.center, children: [
        GradientContainer(
          child: Center(
              child: Image.asset(
            "assets/images/genChatSplash.png",
            width: 120,
            height: 120,
          )),
        ),
        Positioned(
          bottom: 0,
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/images/genMakLogo.png",
                  width: 50,
                  height: 50,
                ),
                SizedBox(
                  width: 10,
                ),
                Column(
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
      ]),
    );
  }
}
