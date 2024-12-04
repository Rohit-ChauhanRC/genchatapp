import 'package:flutter/material.dart';
import 'package:genchatapp/app/widgets/gradientContainer.dart';

import 'package:get/get.dart';

import '../../../constants/colors.dart';
import '../controllers/call_controller.dart';

class CallView extends GetView<CallController> {
  const CallView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: textBarColor,
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Text(
          'Calls',
          style: TextStyle(
            fontSize: 20,
            color: whiteColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: GradientContainer(
        child: const Center(
          child: Text(
            'CallView is working',
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }
}
