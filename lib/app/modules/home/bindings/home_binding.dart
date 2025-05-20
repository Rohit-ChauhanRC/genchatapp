import 'package:get/get.dart';

import '../../../config/services/connectivity_service.dart';
import '../../../data/repositories/select_contacts/select_contact_repository.dart';
import '../../../data/repositories/select_contacts/select_contact_repository_impl.dart';
import '../../../network/api_client.dart';
import '../../select_contacts/controllers/select_contacts_controller.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiClient>(()=> ApiClient());
    Get.lazyPut<ConnectivityService>(()=> ConnectivityService());
    Get.lazyPut<IContactRepository>(() => ContactRepositoryImpl(apiClient: Get.find<ApiClient>()));
    Get.lazyPut(() => ContactRepositoryImpl(apiClient: Get.find<ApiClient>()));
    Get.lazyPut<SelectContactsController>(() => SelectContactsController());
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );
  }
}
