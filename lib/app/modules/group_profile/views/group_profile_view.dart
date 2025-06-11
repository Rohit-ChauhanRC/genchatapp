import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/group_profile_controller.dart';

class GroupProfileView extends GetView<GroupProfileController> {
  const GroupProfileView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GroupProfileView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'GroupProfileView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
