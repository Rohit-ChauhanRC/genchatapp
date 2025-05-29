import 'package:genchatapp/app/data/repositories/group/group_repository.dart';
import 'package:genchatapp/app/network/api_client.dart';
import 'package:get/get.dart';

import '../controllers/group_name_controller.dart';

class GroupNameBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ApiClient());
    Get.lazyPut(() => GroupRepository(apiClient: Get.find(), sharedPreferences: Get.find()));

    Get.lazyPut<GroupNameController>(
      () => GroupNameController(groupRepository: Get.find()),
    );
  }
}
