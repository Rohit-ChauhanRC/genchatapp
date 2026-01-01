import 'package:genchatapp/app/config/services/socket_service.dart';
import 'package:genchatapp/app/data/models/new_models/response_model/verify_otp_response_model.dart';
import 'package:genchatapp/app/modules/home/controllers/home_controller.dart';
import 'package:genchatapp/app/services/shared_preference_service.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/local_database/local_database.dart';

class SettingsController extends GetxController {
  //
  final SharedPreferenceService sharedPreferenceService =
      Get.find<SharedPreferenceService>();
  final homeController = Get.find<HomeController>();
  final DataBaseService db = Get.find<DataBaseService>();
  final socketService = Get.find<SocketService>();

  late Rx<UserData> _userData = UserData().obs;
  UserData get userData => _userData.value;
  set userData(UserData userData) => _userData.value = (userData);

  // Version related variables
  final RxString _currentVersion = ''.obs;
  final RxString _latestVersion = ''.obs;
  final RxBool _isCheckingForUpdate = false.obs;
  final RxBool _updateAvailable = false.obs;

  final RxString currentVersion = ''.obs;
  final RxBool updateAvailable = false.obs ;
  String get latestVersion => _latestVersion.value;
  bool get isCheckingForUpdate => _isCheckingForUpdate.value;

  @override
  void onInit() {
    super.onInit();
    isRefreshed();
    _getCurrentVersion();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void isRefreshed() {
    UserData? userDetails = sharedPreferenceService.getUserData();
    if (userDetails != null) {
      _userData.value = userDetails;
    }
  }

  Future<void> logout(Function()? onSuccess) async {
    await db.resetDatabase();
    await socketService.disposeSocket();
    await sharedPreferenceService.clear();
    onSuccess?.call();
  }

  // Version related methods
  Future<void> _getCurrentVersion() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      _currentVersion.value = packageInfo.version;
    } catch (e) {
      _currentVersion.value = '1.0.1'; // Fallback to pubspec version
    }
  }

  Future<void> checkForUpdate() async {
    _isCheckingForUpdate.value = true;
    
    try {
      // Simulate checking for updates (replace with actual API call)
      await Future.delayed(const Duration(seconds: 2));
      
      // For testing purposes, simulate a newer version
      // Current version is 1.0.1, so we'll set latest to 1.0.2
      _latestVersion.value = '1.0.2'; // Test version higher than current
      
      // Compare versions
      if (_isVersionNewer(_latestVersion.value, _currentVersion.value)) {
        _updateAvailable.value = true;
      } else {
        _updateAvailable.value = false;
      }
    } catch (e) {
      print('Error checking for updates: $e');
    } finally {
      _isCheckingForUpdate.value = false;
    }
  }

  bool _isVersionNewer(String latest, String current) {
    List<String> latestParts = latest.split('.');
    List<String> currentParts = current.split('.');
    
    for (int i = 0; i < latestParts.length && i < currentParts.length; i++) {
      int latestPart = int.tryParse(latestParts[i]) ?? 0;
      int currentPart = int.tryParse(currentParts[i]) ?? 0;
      
      if (latestPart > currentPart) {
        return true;
      } else if (latestPart < currentPart) {
        return false;
      }
    }
    
    return false;
  }

  Future<void> openUpdateUrl() async {
    const url = 'https://play.google.com/store/apps/details?id=com.example.genchatapp';
    try {
      await launchUrl(Uri.parse(url));
    } catch (e) {
      print('Error launching URL: $e');
    }
  }

  // Test method to change the simulated latest version
  void setTestVersion(String version) {
    _latestVersion.value = version;
    _updateAvailable.value = _isVersionNewer(version, _currentVersion.value);
  }
}
