import 'package:dio/dio.dart';
import 'package:genchatapp/app/network/api_client.dart';
import 'package:genchatapp/app/network/api_endpoints.dart';
import 'package:genchatapp/app/services/shared_preference_service.dart';
import 'package:genchatapp/app/utils/alert_popup_utils.dart';

class GroupRepository {
  final SharedPreferenceService sharedPreferences;
  final ApiClient apiClient;

  GroupRepository({required this.apiClient, required this.sharedPreferences});

  

  Future<Response?> createGroup(
      String groupName, List<int> userIdsArray) async {
    try {
      final param = {
        'userIdsArray': userIdsArray,
        'groupName': groupName,
      };
      return await apiClient.post(ApiEndpoints.createGroup, param);
    } catch (e) {
      // print('Error in verifyOTPAPI: $e');
      showAlertMessage("Error: $e");
      return null;
    }
  }


   Future<Response?> fetchGroup() async {
    try {
     
      return await apiClient.get(ApiEndpoints.groupFetch);
    } catch (e) {
      // print('Error in verifyOTPAPI: $e');
      showAlertMessage("Error: $e");
      return null;
    }
  }
}
