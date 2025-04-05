import 'dart:io';
import 'package:dio/dio.dart';
import 'package:genchatapp/app/network/api_endpoints.dart';
import 'package:get/instance_manager.dart';

import '../../../network/api_client.dart';
import '../../../network/api_interceptor.dart';
import '../../../utils/ApiUtils/form_data_helper.dart';
import '../../../utils/alert_popup_utils.dart';

class ProfileRepository {
  final ApiClient apiClient;

  ProfileRepository({required this.apiClient});

  /// Update user details (Name & Email)
  Future<Response?> updateUserDetails({required String name, required String email}) async {
    try {

      final param = {
        'name': name,
        'email': email
      };
      return await apiClient.post(ApiEndpoints.updateUser, param);

    } catch (e) {
      print("🔥 Error updating user details: $e");
      showAlertMessage("Error updating user details: $e");
      return null;
    }
  }

  /// Upload Profile Picture (Multipart FormData)
  Future<Response?> uploadProfilePicture(File imageFile) async {
    String fileName = imageFile.path.split('/').last;
    String mimeType = getImageMimeType(imageFile);

    FormData buildFormData() {
      return FormData.fromMap({
        "display-picture": MultipartFile.fromFileSync(
          imageFile.path,
          filename: fileName,
          contentType: DioMediaType.parse(mimeType),
        ),
      });
    }

    return await retryFormDataUpload(
      url: ApiEndpoints.updateUserProPic,
      formDataBuilder: buildFormData,
      uploadCall: (formData) => apiClient.uploadFile(ApiEndpoints.updateUserProPic, formData),
    );
  }


  /// Function to get the correct content type for images dynamically
  String getImageMimeType(File file) {
    String extension = file.path.split('.').last.toLowerCase();

    switch (extension) {
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'gif':
        return 'image/gif';
      case 'bmp':
        return 'image/bmp';
      case 'webp':
        return 'image/webp';
      default:
        return 'application/octet-stream'; // Default if unknown
    }
  }
}
