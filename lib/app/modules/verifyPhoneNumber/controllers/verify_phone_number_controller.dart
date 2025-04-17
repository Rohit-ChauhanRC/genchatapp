import 'dart:convert';

import 'package:country_picker/country_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:genchatapp/app/data/models/new_models/response_model/verify_number_response_model.dart';
import 'package:genchatapp/app/data/repositories/auth/auth_repository.dart';
import 'package:genchatapp/app/routes/app_pages.dart';
import 'package:genchatapp/app/utils/alert_popup_utils.dart';
import 'package:get/get.dart';
import '../../../utils/utils.dart';

class VerifyPhoneNumberController extends GetxController {

  final AuthRepository authRepository;

  VerifyPhoneNumberController({required this.authRepository});

  GlobalKey<FormState>? loginFormKey = GlobalKey<FormState>();

  final RxString _mobileNumber = ''.obs;
  String get mobileNumber => _mobileNumber.value;
  set mobileNumber(String mobileNumber) => _mobileNumber.value = mobileNumber;

  final Rx<Country?> _country = Rx<Country?>(null);
  Country? get country => _country.value;
  set country(Country? c) => _country.value = c;

  final RxBool _circularProgress = false.obs;
  bool get circularProgress => _circularProgress.value;
  set circularProgress(bool v) => _circularProgress.value = v;

  @override
  void onInit() {
    super.onInit();
    country = Country(
      phoneCode: '91',
      countryCode: 'IN',
      e164Sc: 91,
      geographic: true,
      level: 1,
      name: 'India',
      nameLocalized: 'India',
      example: '9123456789',
      displayName: 'India (IN) [+91]',
      displayNameNoCountryCode: 'India (IN)',
      e164Key: '91-IN-0',
      fullExampleWithPlusSign: '+919123456789',
    );
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
    // _country.close();
    // _mobileNumber.close();
  }

  void pickCountry() {
    showCountryPicker(
        context: Get.context!,
        onSelect: (Country ctr) {
          country = ctr;
        });
  }

  void sendPhoneNumber() async {
    print("sendPhoneNumber clicked"); // Debugging
    try {
      String phoneNumber = mobileNumber.trim();
      if (country != null && phoneNumber.isNotEmpty) {
        await login();
      } else {
        showSnackBar(context: Get.context!, content: 'Please select a country and enter a valid phone number.');
      }
    } catch (e) {
      print("Error in sendPhoneNumber: $e");
      showSnackBar(context: Get.context!, content: 'Something went wrong: $e');
    }
  }

  Future login() async {
    if (!loginFormKey!.currentState!.validate()) {
      print("Form validation failed");
      return null;
    }
    // Get.toNamed(Routes.OTP,arguments: mobileNumber);

    print("Form validation passed");
    await loginCred(mobileNumber, false);
  }

  Future<void> loginCred(String resendOtpMobNum, bool isFromResend) async{
    try{
      String? mobileNum = resendOtpMobNum ?? mobileNumber;
      String? countryCode = country?.phoneCode;
      circularProgress = true;
      final response = await authRepository.sendOtp(mobileNum, countryCode ?? "");
      if(response != null && response.statusCode == 200){
        final getVerifyNumberResponse = VerifyNumberResponseModel.fromJson(response.data);
        if(getVerifyNumberResponse.status == true){
          if (!isFromResend) {
            Get.toNamed(Routes.OTP, arguments: [mobileNumber,countryCode]);
          }

        }else{
          showAlertMessage(getVerifyNumberResponse.message.toString());
        }
      }
    } catch (e) {
      print("Error in loginCred: $e");
      showAlertMessage("Something went wrong: $e");
    } finally{
      circularProgress = false;
    }
  }
}
