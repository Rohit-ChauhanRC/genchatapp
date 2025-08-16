import 'app_config.dart';

class ApiEndpoints {
  /// Base URLs
  // Local: http://app.maklife.in:10000
  // Production: https://payment-payu.maklifedairy.in:6040

  // static const String _base = "https://payment-payu.maklifedairy.in:6040";
  static String get baseUrl => AppConfig.baseUrl;
  // static const String baseUrl = "$_base/api/";
  static String get socketBaseUrl => AppConfig.socketUrl;
  // static const String socketBaseUrl = _base;
  static const String apiVersion = "v1/";

  /// API Endpoints
  static const String sendOtp = "send-otp";
  static const String verifyOtp = "login";
  static const String updateUser = "user/update-user";
  static const String updateUserProPic = "user/update-display-picture";
  static const String fetchUser = "user/fetch-users-existed";
  static const String createGroup = "group/create";
  // group/fetch
  static const String groupFetch = "group/fetch";
  static const String uploadGroupIcon = "group/update-display-picture";
  static const String updateGroup = "group/update";
  static const String makeAdmin = "group/add-admin";
  static const String removeAdmin = "group/remove-admin";
  static const String removeUser = "group/remove-user";
  static const String addUser = "group/add-users";

  static const String uploadMessageFiles = "message/file";
  static const String userBlock = "user/block-contact";
}
