import 'package:genchatapp/app/data/repositories/profile/profile_repository.dart';
import 'package:genchatapp/app/network/api_client.dart';
import 'package:get/get.dart';

import '../controllers/single_chat_controller.dart';

class SingleChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiClient>(() => ApiClient());
    Get.lazyPut<ProfileRepository>(
        () => ProfileRepository(apiClient: Get.find<ApiClient>()));
    Get.put<SingleChatController>(SingleChatController());
  }
}
