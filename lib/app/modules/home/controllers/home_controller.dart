import 'dart:ffi';

import 'package:get/get.dart';

class HomeController extends GetxController {

  final RxInt _currentPageIndex = 0.obs;
  int get currentPageIndex => _currentPageIndex.value;
  set currentPageIndex(int currentPageIndex) => _currentPageIndex.value = currentPageIndex;

  @override
  void onInit() {
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
