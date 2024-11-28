import 'package:flutter/material.dart';
import 'package:genchatapp/app/constants/colors.dart';

import 'package:get/get.dart';

import '../../../constants/constants.dart';
import '../controllers/verify_phone_number_controller.dart';

class VerifyPhoneNumberView extends GetView<VerifyPhoneNumberController> {
  const VerifyPhoneNumberView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: ()=>{ Get.back()}, icon: Icon(Icons.arrow_back, color: textBarColor,)),
        backgroundColor: appBarColor,
        title: Text(verifyPhoneNumber, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: textBarColor),),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: backgroundGradientColor,
            )
        ),
        child: Center(
          child: Text(
            'VerifyPhoneNumberView is working',
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }
}
