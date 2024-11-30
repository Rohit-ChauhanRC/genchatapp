import 'dart:convert';

import 'package:country_picker/country_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:genchatapp/app/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../utils/utils.dart';

class VerifyPhoneNumberController extends GetxController {


  GlobalKey<FormState>? loginFormKey = GlobalKey<FormState>();

  final RxString _mobileNumber = ''.obs;
  String get mobileNumber => _mobileNumber.value;
  set mobileNumber(String mobileNumber) => _mobileNumber.value = mobileNumber;

  final Rx<Country?> _country = Rx<Country?>(null);
  Country? get country => _country.value;
  set country(Country? c) => _country.value = c;

  final RxBool _circularProgress = true.obs;
  bool get circularProgress => _circularProgress.value;
  set circularProgress(bool v) => _circularProgress.value = v;

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
    _country.close();
    _mobileNumber.close();
  }

  void pickCountry() {
    showCountryPicker(
        context: Get.context!,
        onSelect: (Country ctr) {
          country = ctr;
        });
  }

  void sendPhoneNumber() async {
    String phoneNumber = mobileNumber.trim();
    if (country != null && phoneNumber.isNotEmpty) {
      // Get.toNamed(Routes.OTP);
      await login();
    } else {
      showSnackBar(context: Get.context!, content: 'Fill out all the fields');
    }
  }

  Future login() async {
    if (!loginFormKey!.currentState!.validate()) {
      return null;
    }
    // Get.toNamed(Routes.OTP,arguments: mobileNumber);
    await loginCred();
  }

  loginCred() async {
    circularProgress = false;
    try {
      var res = await http.post(
          Uri.parse("http://app.maklife.in:9001/api/user"),
          body: {"MobileNo": mobileNumber});
      final a = jsonDecode(res.body);

      if (res.statusCode == 200 && a == "OTP Sent !") {
        Get.toNamed(
          Routes.OTP,
          arguments: mobileNumber,
        );
      } else {
        //
        showSnackBar(context: Get.context!, content: json.decode(res.body));
      }
      circularProgress = true;
    } catch (e) {
      circularProgress = true;
      showSnackBar(context: Get.context!, content: e.toString());
    }
  }
}
