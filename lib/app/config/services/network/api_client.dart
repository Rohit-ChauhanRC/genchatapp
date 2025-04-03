import 'package:dio/dio.dart';
import 'api_interceptor.dart';
import 'api_endpoints.dart';

class ApiClient {
  late Dio dio;

  ApiClient() {
    dio = Dio(BaseOptions(
      baseUrl: "${ApiEndpoints.baseUrl}${ApiEndpoints.apiVersion}",
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ));

    // dio.interceptors.add(ApiInterceptor());
  }

  /// GET Request
  Future<Response> get(String url, {Map<String, dynamic>? queryParams}) async {
    try {
      Response response = await dio.get(url, queryParameters: queryParams);
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// POST Request
  Future<Response> post(String url, dynamic data) async {
    try {
      Response response = await dio.post(url, data: data);
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT Request
  Future<Response> put(String url, dynamic data) async {
    try {
      Response response = await dio.put(url, data: data);
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE Request
  Future<Response> delete(String url) async {
    try {
      Response response = await dio.delete(url);
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Multipart Request
  Future<Response> uploadFile(String url, FormData formData) async {
    try {
      Response response = await dio.post(url, data: formData);
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Error Handling
  String _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return "Connection Timeout!";
        case DioExceptionType.receiveTimeout:
          return "Receive Timeout!";
        case DioExceptionType.badResponse:
          return "Error: ${error.response?.data['message'] ?? 'Something went wrong'}";
        case DioExceptionType.cancel:
          return "Request Cancelled!";
        case DioExceptionType.unknown:
        default:
          return "Unexpected Error Occurred!";
      }
    } else {
      return "Something went wrong!";
    }
  }
}
