import 'package:dio/dio.dart';
import 'package:get/instance_manager.dart';

import '../../network/api_interceptor.dart';
import '../alert_popup_utils.dart';


Future<Response?> retryFormDataUpload({
  required String url,
  required FormData Function() formDataBuilder,
  required Future<Response?> Function(FormData) uploadCall,
}) async {
  try {
    return await uploadCall(formDataBuilder());
  } on DioException catch (e) {
    final isUnauthorized = e.response?.statusCode == 401 ||
        e.response?.data['message']?.toString().toLowerCase() == 'invalid token';

    if (isUnauthorized) {
      print("🛑 DioException: 401 or invalid token. Refreshing...");
      final refreshed = await Get.find<ApiInterceptor>().refreshToken();

      if (refreshed) {
        try {
          print("🔁 Retrying upload after token refresh (DioException)");
          return await uploadCall(formDataBuilder());
        } catch (e) {
          print("❌ Retry after DioException failed: $e");
          showAlertMessage("Retry failed: ${e.toString()}");
          return null;
        }
      }
    }

    print("🔥 DioException (not auth): ${e.message}");
    showAlertMessage("Upload failed: ${e.message}");
    return null;
  } catch (e) {
    final message = e.toString().toLowerCase();
    if (message.contains("invalid token") || message.contains("401")) {
      print("🛑 Generic error with 401 message. Retrying...");
      try {
        print("🔁 Retrying upload after generic error");
        return await uploadCall(formDataBuilder());
      } catch (e) {
        print("❌ Retry after generic catch failed: $e");
        showAlertMessage("Retry failed: ${e.toString()}");
        return null;
      }
    }

    print("🔥 Unexpected error: $e");
    showAlertMessage("Unexpected error: ${e.toString()}");
    return null;
  }
}
