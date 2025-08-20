import 'dart:io';

import 'package:dio/dio.dart';
import 'package:genchatapp/app/network/api_client.dart';
import 'package:genchatapp/app/network/api_endpoints.dart';
import 'package:genchatapp/app/services/shared_preference_service.dart';
import 'package:genchatapp/app/utils/alert_popup_utils.dart';

import '../../../utils/ApiUtils/form_data_helper.dart';
import '../../../utils/utils.dart';

class GroupRepository {
  final SharedPreferenceService sharedPreferences;
  final ApiClient apiClient;

  GroupRepository({required this.apiClient, required this.sharedPreferences});

  Future<Response?> createGroup(
    String groupName,
    List<int> userIdsArray,
  ) async {
    try {
      final param = {'userIdsArray': userIdsArray, 'groupName': groupName};
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
      if (e == "404_NOT_FOUND") {
        print("Group not found.");
        // showAlertMessage("Group not found.");
      } else {
        print("Error in fetchGroup: $e");
        // showAlertMessage("Error: $e");
      }
      return null;
    }
  }

  Future<Response?> updateGroupNameAndDescription({
    required bool isEditingGroupName,
    int? groupId,
    String? groupName,
    String? groupDescription,
  }) async {
    try {
      final param = {
        'groupId': groupId,
        if (isEditingGroupName)
          'groupName': groupName
        else
          'groupDescription': groupDescription,
      };
      return await apiClient.post(ApiEndpoints.updateGroup, param);
    } catch (e) {
      // print('Error in verifyOTPAPI: $e');
      showAlertMessage("Error: $e");
      return null;
    }
  }

  Future<Response?> makeNewAdmin({
    required int userId,
    required int groupId,
  }) async {
    try {
      final param = {'groupId': groupId, 'userId': userId};
      return await apiClient.post(ApiEndpoints.makeAdmin, param);
    } catch (e) {
      // print('Error in verifyOTPAPI: $e');
      showAlertMessage("Error: $e");
      return null;
    }
  }

  Future<Response?> removeAdmin({
    required int userId,
    required int groupId,
  }) async {
    try {
      final param = {'groupId': groupId, 'userId': userId};
      return await apiClient.post(ApiEndpoints.removeAdmin, param);
    } catch (e) {
      // print('Error in verifyOTPAPI: $e');
      showAlertMessage("Error: $e");
      return null;
    }
  }

  Future<Response?> removeUser({
    required int userId,
    required int groupId,
  }) async {
    try {
      final param = {'groupId': groupId, 'userId': userId};
      return await apiClient.post(ApiEndpoints.removeUser, param);
    } catch (e) {
      // print('Error in verifyOTPAPI: $e');
      showAlertMessage("Error: $e");
      return null;
    }
  }

  Future<Response?> deleteGroup({
    required int groupId,
  }) async {
    try {
      final param = {'groupId': groupId};
      return await apiClient.post(ApiEndpoints.deleteGroup, param);
    } catch (e) {
      // print('Error in verifyOTPAPI: $e');
      showAlertMessage("Error: $e");
      return null;
    }
  }

  Future<Response?> addUsers({
    required List<int> userId,
    required int groupId,
  }) async {
    try {
      final param = {'groupId': groupId, 'userIdsArray': userId};
      return await apiClient.post(ApiEndpoints.addUser, param);
    } catch (e) {
      // print('Error in verifyOTPAPI: $e');
      showAlertMessage("Error: $e");
      return null;
    }
  }

  /// Upload Profile Picture (Multipart FormData)
  Future<Response?> uploadGroupPic(
    File imageFile,
    int groupId, {
    ProgressCallback? onProgress,
  }) async {
    String fileName = imageFile.path.split('/').last;
    String mimeType = getImageMimeType(imageFile);

    // print("FileName: $fileName\nFileType: $mimeType\nImagePath: ${imageFile.path} ");

    FormData buildFormData() {
      return FormData.fromMap({
        "groupId": groupId,
        "display-picture": MultipartFile.fromFileSync(
          imageFile.path,
          filename: fileName,
          contentType: DioMediaType.parse(mimeType),
        ),
      });
    }

    return await retryFormDataUpload(
      url: ApiEndpoints.uploadGroupIcon,
      onProgress: onProgress,

      formDataBuilder: buildFormData,
      uploadCall: (formData, {onProgress}) =>
          apiClient.uploadFile(ApiEndpoints.uploadGroupIcon, formData),
    );
  }
}
