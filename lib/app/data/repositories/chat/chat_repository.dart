import 'package:dio/dio.dart';
import 'package:genchatapp/app/network/api_client.dart';
import 'package:genchatapp/app/network/api_endpoints.dart';
import 'package:genchatapp/app/utils/alert_popup_utils.dart';

class ChatRepository {
  final ApiClient apiClient;

  ChatRepository({required this.apiClient});

  Future<Response?> userBlock(int blockContactUserId, bool isBlock) async {
    try {
      final param = {
        'blockContactUserId': blockContactUserId,
        'isBlock': isBlock,
      };
      return await apiClient.post(ApiEndpoints.userBlock, param);
    } catch (e) {
      // print('Error in verifyOTPAPI: $e');
      showAlertMessage("Error: $e");
      return null;
    }
  }
}
