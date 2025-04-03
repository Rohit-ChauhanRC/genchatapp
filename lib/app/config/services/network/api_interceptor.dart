// import 'package:dio/dio.dart';
// import 'package:genchatapp_new_bloc/core/common/user_defaults/user_defaults_keys.dart';
// import 'package:genchatapp_new_bloc/core/services/shared_preferences_service.dart';
// import 'package:genchatapp_new_bloc/core/network/api_client.dart';
// import 'package:get_it/get_it.dart';

// class ApiInterceptor extends Interceptor {
//   @override
//   void onRequest(
//       RequestOptions options, RequestInterceptorHandler handler) async {
//     String? token =
//         SharedPreferenceService.getString(UserDefaultsKeys.accessToken);

//     if (token != null) {
//       options.headers['Authorization'] = 'Bearer $token';
//     }

//     return handler.next(options);
//   }

//   @override
//   void onResponse(Response response, ResponseInterceptorHandler handler) {
//     return handler.next(response);
//   }

//   @override
//   void onError(DioException err, ErrorInterceptorHandler handler) async {
//     if (err.response?.statusCode == 401) {
//       bool tokenRefreshed = await _refreshToken();
//       if (tokenRefreshed) {
//         return handler.resolve(await _retry(err.requestOptions));
//       }
//     }
//     return handler.next(err);
//   }

//   /// Refresh Token Logic
//   Future<bool> _refreshToken() async {
//     String? refreshToken =
//         SharedPreferenceService.getString(UserDefaultsKeys.refreshToken);

//     if (refreshToken == null) return false;

//     try {
//       Dio dio = Dio();
//       Response response = await dio
//           .post('YOUR_REFRESH_API', data: {"refresh_token": refreshToken});
//       if (response.statusCode == 200) {
//         String newToken = response.data['access_token'];
//         String newRefreshToken = response.data['refresh_token'];
//         await SharedPreferenceService.setString(
//             UserDefaultsKeys.accessToken, newToken);
//         await SharedPreferenceService.setString(
//             UserDefaultsKeys.refreshToken, newRefreshToken);
//         return true;
//       }
//     } catch (e) {
//       return false;
//     }
//     return false;
//   }

//   /// Retry Request
//   Future<Response> _retry(RequestOptions requestOptions) async {
//     String? token =
//         SharedPreferenceService.getString(UserDefaultsKeys.accessToken);

//     if (token != null) {
//       requestOptions.headers['Authorization'] = 'Bearer $token';
//     }

//     return GetIt.instance<ApiClient>().dio.fetch(requestOptions);
//   }
// }
