import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:genchatapp/app/data/models/new_models/response_model/verify_otp_response_model.dart';
import 'package:genchatapp/app/modules/verifyPhoneNumber/controllers/verify_phone_number_controller.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../common/user_defaults/user_defaults_keys.dart';
import '../../../constants/constants.dart';
import '../../../data/repositories/auth/auth_repository.dart';
import '../../../routes/app_pages.dart';
import '../../../services/shared_preference_service.dart';
import '../../../utils/alert_popup_utils.dart';
import '../../../utils/utils.dart';

class OtpController extends GetxController {
  final AuthRepository authRepository;

  OtpController({required this.authRepository});
  final sharedPreferenceService = Get.find<SharedPreferenceService>();
  final verifyPhoneNumberController = Get.find<VerifyPhoneNumberController>();
  GlobalKey<FormState>? otpFormKey = GlobalKey<FormState>();

  final RxString _mobileNumber = ''.obs;
  String get mobileNumber => _mobileNumber.value;
  set mobileNumber(String mobileNumber) => _mobileNumber.value = mobileNumber;

  final RxString _countryCode = ''.obs;
  String get countryCode => _countryCode.value;
  set countryCode(String countryCode) => _countryCode.value = countryCode;

  final RxString _otp = ''.obs;
  String get otp => _otp.value;
  set otp(String op) => _otp.value = op;

  final RxBool _circularProgress = false.obs;
  bool get circularProgress => _circularProgress.value;
  set circularProgress(bool v) => _circularProgress.value = v;

  RxInt timerValue = 60.obs;
  RxBool isResendEnabled = false.obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    mobileNumber = Get.arguments[0];
    countryCode = Get.arguments[1];
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
      // print("Resending OTP to $mobileNumber...");
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

  Future<void> verifyOTPLoginCred() async {
    try {
      circularProgress = true;
      int countryNum = int.parse(countryCode);
      final response =
          await authRepository.verifyOtp(mobileNumber, countryNum, otp);
      if (response != null && response.statusCode == 200) {
        final getVerifyNumberResponse =
            VerifyOtpResponseModel.fromJson(response.data);
        if (getVerifyNumberResponse.status == true) {
          String? accessToken = getVerifyNumberResponse.data?.accessToken;
          String? refreshToken = getVerifyNumberResponse.data?.refreshToken;
          UserData? userDetails = getVerifyNumberResponse.data?.userData;
          int? userId = userDetails?.userId;
          String? mobileNum = userDetails?.phoneNumber;
          saveIsNumVerified(accessToken ?? "", refreshToken ?? "", true,
              userId ?? 0, mobileNum ?? "");
          sharedPreferenceService.setString(
              UserDefaultsKeys.userDetail, userDataToJson(userDetails!));
          // print("getUserData full details:---> ${sharedPreferenceService.getUserData()}");
          Get.offAllNamed(Routes.CREATE_PROFILE, arguments: false
              // arguments: [mobileNumber, a.toString()],
              );
        }
      }
    } catch (e) {
      // print("Error in verifyOTPCred: $e");
      showAlertMessage("Something went wrong: $e");
    } finally {
      circularProgress = false;
    }
  }

  void saveIsNumVerified(String accessToken, String refreshToken,
      bool isNumVerified, int uid, String mob) {
    sharedPreferenceService.setString(
        UserDefaultsKeys.accessToken, accessToken);
    sharedPreferenceService.setString(
        UserDefaultsKeys.refreshToken, refreshToken);
    sharedPreferenceService.setBool(
        UserDefaultsKeys.isNumVerify, isNumVerified);
    sharedPreferenceService.setInt(UserDefaultsKeys.userId, uid);
    sharedPreferenceService.setString(UserDefaultsKeys.userMobileNum, mob);
  }
}
