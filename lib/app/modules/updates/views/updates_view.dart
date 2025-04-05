import 'package:flutter/material.dart';
import 'package:genchatapp/app/common/widgets/gradient_container.dart';

import 'package:get/get.dart';

import '../../../constants/colors.dart';
import '../controllers/updates_controller.dart';

class UpdatesView extends GetView<UpdatesController> {
  const UpdatesView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: textBarColor,
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: const Text(
          'Updates',
          style: TextStyle(
            fontSize: 20,
            color: whiteColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
              onPressed: (){},
              icon: const Icon(Icons.camera_alt_outlined, color: whiteColor,)
          ),
          IconButton(
              onPressed: (){},
              icon: const Icon(Icons.more_vert, color: whiteColor,)
          )
        ],
      ),
      body: GradientContainer(
        child: const Center(
          child: Text(
            'UpdatesView is working',
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }
}
