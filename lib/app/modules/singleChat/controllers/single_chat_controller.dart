import 'package:genchatapp/app/data/models/user_model.dart';
import 'package:get/get.dart';

class SingleChatController extends GetxController {
  //

  final RxList<UserModel> _userData = <UserModel>[].obs;
  List<UserModel> get mobileNumber => _userData;
  set userData(List<UserModel> userData) => _userData.assignAll(userData);
  @override
  void onInit() {
    userData = Get.arguments;
    print("UserData:-----------> $_userData");
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

}
