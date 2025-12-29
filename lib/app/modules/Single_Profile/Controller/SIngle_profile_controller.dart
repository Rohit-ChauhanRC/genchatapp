import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../constants/constants.dart';
import '../../../data/models/new_models/response_model/contact_response_model.dart';

class SingleProfileController extends GetxController {
  // 🔹 Receiver user data
  UserList? receiverUserData;

  // 🔹 Reactive flags
  final RxBool userExist = false.obs;
  final RxBool blocked = false.obs;
  final RxInt blockedByMe = 0.obs;

  // 🔹 Init
  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  void _loadUserData() {
    // Example – set from arguments or API
    receiverUserData = Get.arguments as UserList?;

    if (receiverUserData?.localName != null &&
        receiverUserData!.localName!.isNotEmpty) {
      userExist.value = true;
    }
  }

  // 🔹 Display name logic
  String getDisplayName() {
    if (receiverUserData == null) return "";

    if (receiverUserData!.localName != null &&
        receiverUserData!.localName!.isNotEmpty) {
      return receiverUserData!.localName!;
    }

    return "+${receiverUserData!.countryCode ?? ''} "
        "${receiverUserData!.phoneNumber ?? ''}";
  }

  // 🔹 Block / Unblock
  void blockUser() {
    blocked.value = true;
    blockedByMe.value = 1;
    // TODO: API call
  }

  void unblockUser() {
    blocked.value = false;
    blockedByMe.value = 0;
    // TODO: API call
  }



}
