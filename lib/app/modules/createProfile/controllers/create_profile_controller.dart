import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import '../../../utils/utils.dart';

class CreateProfileController extends GetxController {
  GlobalKey<FormState>? createProfileKey = GlobalKey<FormState>();

  final RxString _profileName = ''.obs;
  String get profileName => _profileName.value;
  set profileName(String profileName) => _profileName.value = profileName;

  final RxString _email = ''.obs;
  String get email => _email.value;
  set email(String email) => _email.value = email;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
    _profileName.close();
    _email.close();
  }

  void createProfile() async {
    String profileNam = profileName;
    String emailId = email;
    if (profileNam.isNotEmpty && emailId.isNotEmpty) {
      await validateProfileData();
    } else {
      showSnackBar(context: Get.context!, content: 'Fill out all the fields');
    }
  }

  Future validateProfileData() async {
    if (!createProfileKey!.currentState!.validate()) {
      return null;
    }
    Get.toNamed(Routes.HOME);
  }
}
