import 'dart:io';

import 'package:dio/dio.dart';
import 'package:genchatapp/app/common/user_defaults/user_defaults_keys.dart';
import 'package:genchatapp/app/services/shared_preference_service.dart';
import 'package:get/instance_manager.dart';
import '../config/services/socket_service.dart';
import '../data/local_database/local_database.dart';
import 'api_interceptor.dart';
import 'api_endpoints.dart';

class ApiClient {
  late Dio dio;
  final sharedPrefrence = Get.find<SharedPreferenceService>();
  final db = Get.find<DataBaseService>();
  final socketService = Get.find<SocketService>();

  ApiClient() {
    dio = Dio(BaseOptions(
      baseUrl: "${ApiEndpoints.baseUrl}${ApiEndpoints.apiVersion}",
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ));

    dio.interceptors.add(ApiInterceptor(sharedPrefrence, this,db, socketService )); // ✅ Pass `this`
  }

  Future<Response> get(String url, {Map<String, dynamic>? queryParams}) async {
    try {
      Response response = await dio.get(url, queryParameters: queryParams);
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(String url, dynamic data) async {
    try {
      Response response = await dio.post(url, data: data);
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> put(String url, dynamic data) async {
    try {
      Response response = await dio.put(url, data: data);
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> delete(String url) async {
    try {
      Response response = await dio.delete(url);
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> uploadFile(String url, FormData formData) async {
    try {
      Response response = await dio.post(url, data: formData, options: Options(
        headers: {
          "Accept": "application/json",
          "Content-Type": "multipart/form-data",
          "Authorization": "Bearer ${getAccessToken()}",
        },
      ));
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(dynamic error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;

      if (statusCode == 404) {
        return "404_NOT_FOUND";
      }
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return "Connection Timeout!";
        case DioExceptionType.receiveTimeout:
          return "Receive Timeout!";
        case DioExceptionType.badResponse:
          final responseData = error.response?.data;
          if (responseData is Map && responseData.containsKey('message')) {
            return responseData['message'];
          }
          return "Error: ${responseData ?? 'Something went wrong'}";
        case DioExceptionType.cancel:
          return "Request Cancelled!";
        case DioExceptionType.unknown:
          if (error.error is HandshakeException) {
            return "Secure connection failed. Please check your internet or certificate configuration.";
          }
          return "Unexpected Error Occurred!";
        default:
          return "Unexpected Error Occurred!";
      }
    }
    return "Something went wrong!";
  }

  String? getAccessToken() {
    return sharedPrefrence.getString(UserDefaultsKeys.accessToken);
  }
}

