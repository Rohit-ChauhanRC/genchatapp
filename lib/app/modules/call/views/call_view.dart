import 'package:flutter/material.dart';
import 'package:genchatapp/app/common/widgets/gradient_container.dart';

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
        title: const Text(
          'Calls',
          style: TextStyle(
            fontSize: 20,
            color: whiteColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: const GradientContainer(
        child: Center(
          child: Text(
            'This section is comming soon...',
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }
}
