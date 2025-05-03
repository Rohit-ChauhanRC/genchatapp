import 'package:dio/dio.dart';
import 'package:genchatapp/app/network/api_client.dart';
import 'package:genchatapp/app/network/api_endpoints.dart';
import 'package:genchatapp/app/services/shared_preference_service.dart';
import 'package:genchatapp/app/utils/alert_popup_utils.dart';

class AuthRepository {
  final SharedPreferenceService sharedPreferences;
  final ApiClient apiClient;

  AuthRepository({required this.apiClient, required this.sharedPreferences});

  Future<Response?> sendOtp(String mobileNumber, String countryCode) async {
    try {
      final param = {'countryCode': countryCode, 'phoneNumber': mobileNumber};
      return await apiClient.post(ApiEndpoints.sendOtp, param);
    } catch (e) {
      // print('Error in sendOtpAPI: $e');
      showAlertMessage("Error in sendOTPAPI: $e");
      return null;
    }
  }

  Future<Response?> verifyOtp(
      String mobileNumber, int countryCode, String otp) async {
    try {
      final param = {
        'countryCode': countryCode,
        'phoneNumber': mobileNumber,
        'otp': otp
      };
      return await apiClient.post(ApiEndpoints.verifyOtp, param);
    } catch (e) {
      // print('Error in verifyOTPAPI: $e');
      showAlertMessage("Error in verifyOTP: $e");
      return null;
    }
  }
}
