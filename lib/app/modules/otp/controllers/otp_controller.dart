import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:genchatapp/app/modules/verifyPhoneNumber/controllers/verify_phone_number_controller.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../constants/constants.dart';
import '../../../routes/app_pages.dart';
import '../../../services/shared_preference_service.dart';
import '../../../utils/utils.dart';

class OtpController extends GetxController {
  final sharedPreferenceService = Get.find<SharedPreferenceService>();
  final verifyPhoneNumberController = Get.find<VerifyPhoneNumberController>();
  GlobalKey<FormState>? otpFormKey = GlobalKey<FormState>();

  final RxString _mobileNumber = ''.obs;
  String get mobileNumber => _mobileNumber.value;
  set mobileNumber(String mobileNumber) => _mobileNumber.value = mobileNumber;

  final RxString _otp = ''.obs;
  String get otp => _otp.value;
  set otp(String op) => _otp.value = op;

  final RxBool _circularProgress = true.obs;
  bool get circularProgress => _circularProgress.value;
  set circularProgress(bool v) => _circularProgress.value = v;

  RxInt timerValue = 60.obs;
  RxBool isResendEnabled = false.obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    mobileNumber = Get.arguments;
    startTimer();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void startTimer() {
    timerValue.value = 60;
    isResendEnabled.value = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timerValue.value > 0) {
        timerValue.value--;
      } else {
        timer.cancel();
        isResendEnabled.value = true;
      }
    });
  }

  void resendOtp() {
    if (isResendEnabled.value) {
      print("Resending OTP to $mobileNumber...");
      startTimer();
      verifyPhoneNumberController.loginCred(mobileNumber, true);
    }
  }

  Future login() async {
    if (!otpFormKey!.currentState!.validate()) {
      return null;
    }
    await verifyOTPLoginCred();
  }

  verifyOTPLoginCred() async {
    circularProgress = false;
    try {
      var res = await http.post(
          Uri.parse("http://app.maklife.in:9001/api/OTPValidation"),
          body: {"MobileNo": mobileNumber, "OTP": otp});
      final a = jsonDecode(res.body);
      // print("MobileNumber:----> $mobileNumber OTP:---> $otp");
      if (res.statusCode == 200 &&
          a.toString().isNotEmpty &&
          a != "Invalid OTP ?") {
        saveIsNumVerified(true, a, mobileNumber);
        Get.offAllNamed(
          Routes.CREATE_PROFILE,
          // arguments: [mobileNumber, a.toString()],
        );
      } else {
        showSnackBar(context: Get.context!, content: json.decode(res.body));
        //
        // Utils.showDialog(json.decode(res.body));
      }
      circularProgress = true;
    } catch (e) {
      circularProgress = true;
      // showSnackBar(context: Get.context!, content: e.toString());
    }
  }

  void saveIsNumVerified(bool isNumVerified, String uid, String mob) {
    sharedPreferenceService.setBool(isNumVerify, isNumVerified);
    sharedPreferenceService.setString(userUId, uid);
    sharedPreferenceService.setString(userMob, mob);
  }
}
