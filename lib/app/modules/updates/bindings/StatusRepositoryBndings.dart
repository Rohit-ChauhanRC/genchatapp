import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../data/repositories/status/status_repository.dart';
import '../../../network/api_client.dart';
import '../../../services/shared_preference_service.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ApiClient());
    Get.put(SharedPreferenceService());

    Get.put(StatusRepository(

      apiClient: Get.find<ApiClient>(),
      sharedPreferences: Get.find<SharedPreferenceService>(),
    ));
  }
}