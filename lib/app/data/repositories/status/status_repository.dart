// import '../../models/new_models/response_model/contact_response_model.dart';

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:genchatapp/app/network/api_client.dart';
import 'package:genchatapp/app/network/api_endpoints.dart';
import 'package:genchatapp/app/services/shared_preference_service.dart';
import 'package:genchatapp/app/utils/ApiUtils/form_data_helper.dart';
import 'package:genchatapp/app/utils/alert_popup_utils.dart';
import 'package:genchatapp/app/utils/utils.dart';

class StatusRepository {
  final SharedPreferenceService sharedPreferences;
  final ApiClient apiClient;

  StatusRepository({required this.apiClient, required this.sharedPreferences});

  Future<Response?> fetchStatus({required List<int> userIds}) async {
    try {
      final param = {'userIds': userIds};
      return await apiClient.post(ApiEndpoints.fetchStatus, param);
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

  Future<Response?> deleteStatus({required int statusId}) async {
    try {
      final param = {'statusId': statusId};
      return await apiClient.post(ApiEndpoints.deleteStatus, param);
    } catch (e) {
      // print('Error in verifyOTPAPI: $e');
      showAlertMessage("Error: $e");
      return null;
    }
  }
  Future<Response?> uploadStatus({
    File? imageFile,
    String text = "",
    ProgressCallback? onProgress,
    bool isAssets = false,
  }) async {
    print("🟦 uploadStatus() called");
    print("📝 Text: $text");
    print("📌 isAssets: $isAssets");

    Map<String, dynamic> body = {};

    if (imageFile != null) {
      print("📸 Image file found: ${imageFile.path}");

      String fileName = imageFile.path.split('/').last;
      String mimeType = getFileMimeType(imageFile);
      String? assetType = getFileMimeTypeStatus(imageFile);

      print("📁 File Name: $fileName");
      print("📄 MIME Type: $mimeType");
      print("🔖 Asset Type: $assetType");

      // Check file exists and size
      final exists = await imageFile.exists();
      final size = exists ? await imageFile.length() : 0;
      print("📦 File Exists: $exists | Size: $size bytes");

      if (!exists || size == 0) {
        print("❌ ERROR: File does NOT exist or is EMPTY!");
      }

      body = {
        "text": text,
        "assetType": assetType,
        "isAsset": isAssets,
        "status-asset": MultipartFile.fromFileSync(
          imageFile.path,
          filename: fileName,
          contentType: DioMediaType.parse(mimeType),
        ),
      };

    } else {
      print("⚠️ No file attached. Sending only text status.");
      body = {
        "text": text,
        "assetType": "",
        "isAsset": isAssets,
        "status-asset": null,
      };
    }

    FormData buildFormData() {
      print("🧱 Building FormData...");
      final form = FormData.fromMap(body);

      // Print all form fields
      form.fields.forEach((f) {
        print("🔍 FIELD: ${f.key} = ${f.value}");
      });

      if (form.files.isNotEmpty) {
        print("📎 FILE ATTACHED: ${form.files.first.value.filename}");
      } else {
        print("📎 No file in FormData.");
      }

      return form;
    }

    print("🚀 Calling retryFormDataUpload()...");

    return await retryFormDataUpload(
      url: ApiEndpoints.createStatus,
      onProgress: (count, total) {
        if (onProgress != null) onProgress(count, total);
        final percent = (total > 0) ? (count / total * 100).toStringAsFixed(1) : "0";
        print("📤 Upload Progress: $percent% ($count / $total)");
      },

      formDataBuilder: buildFormData,

      uploadCall: (formData, {onProgress}) async {
        print("📨 Final upload call -> ${ApiEndpoints.createStatus}");
        try {
          final response = await apiClient.uploadFile(
            ApiEndpoints.createStatus,
            formData,
          );
          print("✅ Upload SUCCESS: ${response.statusCode}");
          return response;
        } catch (e) {
          print("❌ Upload FAILED: $e");
          rethrow;
        }
      },
    );
  }

// Future<Response?> uploadStatus({
  //   File? imageFile,
  //   String text = "",
  //   ProgressCallback? onProgress,
  //   bool isAssets = false,
  // }) async {
  //   Map<String, dynamic> body = {};
  //   if (imageFile != null) {
  //     String fileName = imageFile.path.split('/').last;
  //     String mimeType = getFileMimeType(imageFile);
  //     String? assetType = getFileMimeTypeStatus(imageFile);
  //     body = {
  //       "text": text,
  //       "assetType": assetType,
  //       "isAsset": isAssets,
  //       "status-asset": MultipartFile.fromFileSync(
  //         imageFile.path,
  //         filename: fileName,
  //         contentType: DioMediaType.parse(mimeType),
  //       ),
  //     };
  //   } else {
  //     body = {
  //       "text": text,
  //       "assetType": "",
  //       "isAsset": isAssets,
  //       "status-asset": null,
  //     };
  //   }
  //
  //   FormData buildFormData() {
  //     return FormData.fromMap(body);
  //   }
  //
  //   return await retryFormDataUpload(
  //     url: ApiEndpoints.createStatus,
  //     onProgress: onProgress,
  //
  //     formDataBuilder: buildFormData,
  //     uploadCall: (formData, {onProgress}) =>
  //         apiClient.uploadFile(ApiEndpoints.createStatus, formData),
  //   );
  // }

  // Future<Response?> updateGroupNameAndDescription({
  //   required bool isEditingGroupName,
  //   int? groupId,
  //   String? groupName,
  //   String? groupDescription,
  // }) async {
  //   try {
  //     final param = {
  //       'groupId': groupId,
  //       if (isEditingGroupName)
  //         'groupName': groupName
  //       else
  //         'groupDescription': groupDescription,
  //     };
  //     return await apiClient.post(ApiEndpoints.updateGroup, param);
  //   } catch (e) {
  //     // print('Error in verifyOTPAPI: $e');
  //     showAlertMessage("Error: $e");
  //     return null;
  //   }
  // }

  // Future<Response?> makeNewAdmin({
  //   required int userId,
  //   required int groupId,
  // }) async {
  //   try {
  //     final param = {'groupId': groupId, 'userId': userId};
  //     return await apiClient.post(ApiEndpoints.makeAdmin, param);
  //   } catch (e) {
  //     // print('Error in verifyOTPAPI: $e');
  //     showAlertMessage("Error: $e");
  //     return null;
  //   }
  // }

  // Future<Response?> removeAdmin({
  //   required int userId,
  //   required int groupId,
  // }) async {
  //   try {
  //     final param = {'groupId': groupId, 'userId': userId};
  //     return await apiClient.post(ApiEndpoints.removeAdmin, param);
  //   } catch (e) {
  //     // print('Error in verifyOTPAPI: $e');
  //     showAlertMessage("Error: $e");
  //     return null;
  //   }
  // }

  // Future<Response?> removeUser({
  //   required int userId,
  //   required int groupId,
  // }) async {
  //   try {
  //     final param = {'groupId': groupId, 'userId': userId};
  //     return await apiClient.post(ApiEndpoints.removeUser, param);
  //   } catch (e) {
  //     // print('Error in verifyOTPAPI: $e');
  //     showAlertMessage("Error: $e");
  //     return null;
  //   }
  // }

  // Future<Response?> addUsers({
  //   required List<int> userId,
  //   required int groupId,
  // }) async {
  //   try {
  //     final param = {'groupId': groupId, 'userIdsArray': userId};
  //     return await apiClient.post(ApiEndpoints.addUser, param);
  //   } catch (e) {
  //     // print('Error in verifyOTPAPI: $e');
  //     showAlertMessage("Error: $e");
  //     return null;
  //   }
  // }

  // /// Upload Profile Picture (Multipart FormData)
}
