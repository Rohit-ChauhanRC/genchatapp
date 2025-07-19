import 'package:get/get.dart';

import '../../../config/services/connectivity_service.dart';
import '../../../data/repositories/group/group_repository.dart';
import '../../../data/repositories/select_contacts/select_contact_repository.dart';
import '../../../data/repositories/select_contacts/select_contact_repository_impl.dart';
import '../../../network/api_client.dart';
import '../../../services/shared_preference_service.dart';
import '../../select_contacts/controllers/select_contacts_controller.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiClient>(()=> ApiClient());
    Get.lazyPut<SharedPreferenceService>(()=> SharedPreferenceService());
    Get.lazyPut<GroupRepository>(()=> GroupRepository(apiClient: Get.find<ApiClient>(), sharedPreferences: Get.find<SharedPreferenceService>()));
    Get.lazyPut<ConnectivityService>(()=> ConnectivityService());
    Get.lazyPut<IContactRepository>(() => ContactRepositoryImpl(apiClient: Get.find<ApiClient>()));
    Get.put<SelectContactsController>(SelectContactsController());
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );
  }
}
