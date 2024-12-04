import 'package:genchatapp/app/services/shared_preference_service.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  //
  final sharedPreferenceService = Get.find<SharedPreferenceService>();

  final RxInt _currentPageIndex = 0.obs;
  int get currentPageIndex => _currentPageIndex.value;
  set currentPageIndex(int currentPageIndex) =>
      _currentPageIndex.value = currentPageIndex;

  @override
  void onInit() {
    super.onInit();
    print(sharedPreferenceService.getUserDetails().name);
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
