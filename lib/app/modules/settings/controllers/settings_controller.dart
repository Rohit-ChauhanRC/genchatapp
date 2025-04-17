import 'package:genchatapp/app/config/services/socket_service.dart';
import 'package:genchatapp/app/data/models/new_models/response_model/verify_otp_response_model.dart';
import 'package:genchatapp/app/data/models/user_model.dart';
import 'package:genchatapp/app/modules/home/controllers/home_controller.dart';
import 'package:genchatapp/app/services/shared_preference_service.dart';
import 'package:get/get.dart';

import '../../../data/local_database/local_database.dart';

class SettingsController extends GetxController {
  //
  final SharedPreferenceService sharedPreferenceService = Get.find<SharedPreferenceService>();
  final homeController = Get.find<HomeController>();
  final DataBaseService db = Get.find<DataBaseService>();
  final socketService = Get.find<SocketService>();

  late Rx<UserData> _userData = UserData().obs;
  UserData get userData => _userData.value;
  set userData(UserData userData) => _userData.value = (userData);

  @override
  void onInit() {
    super.onInit();
    isRefreshed();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void isRefreshed(){
    UserData? userDetails = sharedPreferenceService.getUserData();
    if (userDetails != null) {
      _userData.value = userDetails;
    }
  }

}
