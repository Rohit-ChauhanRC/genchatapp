import 'package:dio/dio.dart';
import 'package:genchatapp/app/common/user_defaults/user_defaults_keys.dart';
import 'package:genchatapp/app/modules/settings/controllers/settings_controller.dart';
import 'package:genchatapp/app/services/shared_preference_service.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_navigation/get_navigation.dart';

import '../config/services/socket_service.dart';
import '../data/local_database/local_database.dart';
import '../routes/app_pages.dart';
import 'api_client.dart';
import 'api_endpoints.dart';

class ApiInterceptor extends Interceptor {
  final SharedPreferenceService sharedPreference;
  final ApiClient apiClient;
  final DataBaseService db;
  final SocketService socketService;

  ApiInterceptor(this.sharedPreference, this.apiClient, this.db, this.socketService);
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    String? token = sharedPreference.getString(UserDefaultsKeys.accessToken);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Debugging logs
    print("📤 [API Request]: ${options.method} ${options.uri}");
    print("🟢 Query Parameters: ${options.queryParameters}");
    print("📄 Request Body: ${options.data}");
    print("🔑 Headers: ${options.headers}");

    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Debugging response logs
    print("✅ [API Response]: ${response.requestOptions.method} ${response.requestOptions.uri}");
    print("📥 Response Data: ${response.data}");

    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    print("❌ [API Error]: ${err.requestOptions.method} ${err.requestOptions.uri}");
    print("🔴 Error Message: ${err.message}");
    if (err.response != null) {
      print("🔴 Response Data: ${err.response?.data}");
    }

    if (err.response?.statusCode == 401) {
      final isFormData = err.requestOptions.data is FormData;

      // 🪝 Call refreshToken even for FormData requests
      bool tokenRefreshed = await refreshToken();

      if (tokenRefreshed) {
        if (isFormData) {
          print("⚠️ Interceptor won't retry FormData request. Repo will handle retry.");
          return handler.next(err); // Let the repository retry manually with new FormData
        } else {
          // Retry JSON request
          try {
            final retryResponse = await _retry(err.requestOptions);
            return handler.resolve(retryResponse);
          } catch (e) {
            return handler.next(err);
          }
        }
      }
    }

    return handler.next(err); // Other errors
  }


  /// Refresh Token Logic
  Future<bool> refreshToken() async {
    String? refreshToken = sharedPreference.getString(UserDefaultsKeys.refreshToken);
    int? userId = sharedPreference.getUserData()?.userId;

    print("🔄 Refreshing Token...\n🔑 RefreshToken: $refreshToken\n👤 UserId: $userId");


    if (refreshToken == null || userId == null) {
      print("🔴 No refresh token or user ID found!");
      return false;
    }

    try {
      final dio = Dio(BaseOptions(
        baseUrl: "${ApiEndpoints.baseUrl}${ApiEndpoints.apiVersion}",
        connectTimeout: const Duration(seconds: 50),
        receiveTimeout: const Duration(seconds: 50),
        headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
      ));

      Response response = await dio.post(
        'refresh-access-token',
        data: {"userId": userId, "refreshToken": refreshToken},
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        String newAccessToken = response.data['data']['accessToken']; // ✅ Corrected key
        String newRefreshToken = response.data['data']['refreshToken']; // ✅ Corrected key

        print("New Access Token: $newAccessToken\n New refresh token: $newRefreshToken");
        await sharedPreference.remove(UserDefaultsKeys.accessToken);
        await sharedPreference.remove(UserDefaultsKeys.refreshToken);
        await sharedPreference.setString(UserDefaultsKeys.accessToken, newAccessToken);
        await sharedPreference.setString(UserDefaultsKeys.refreshToken, newRefreshToken);

        print("✅ Token refreshed successfully!");
        return true;
      } else {
        print("🔴 Token refresh failed: ${response.data}");
      }
    } catch (e) {
      print("🔴 Refresh token request failed: $e");
    }
    print("🔴 Refresh token invalid, logging out...");

    await logout((){
      Get.offAllNamed(Routes.LANDING);
    });
    // await sharedPreference.clear().then((onValue) {
    //   Get.offAllNamed(Routes.LANDING);
    // });
    return false;
  }

  /// Retry Request after Token Refresh
  Future<Response> _retry(RequestOptions requestOptions) async {
    String? token = sharedPreference.getString(UserDefaultsKeys.accessToken);
    if (token != null) {
      requestOptions.headers['Authorization'] = 'Bearer $token';
    }

    print("🔄 Retrying request: ${requestOptions.method} ${requestOptions.uri}");

    // 💥 If original request was multipart/form-data, you CANNOT reuse the body
    if (requestOptions.data is FormData) {
      print("⚠️ Skipping retry for FormData. Let the repository handle retry manually.");
      throw DioException(
        requestOptions: requestOptions,
        error: "FormData cannot be reused after the original request failed. Retry manually.",
        type: DioExceptionType.unknown,
        response: Response(
          requestOptions: requestOptions,
          statusCode: 401,
        ),
      );
    }

    return apiClient.dio.fetch(requestOptions);
  }

  Future<void> logout(Function()? onSuccess) async{
    await db.closeDb();
    await socketService.disposeSocket();
    await sharedPreference.clear();
    onSuccess?.call();
  }
}
