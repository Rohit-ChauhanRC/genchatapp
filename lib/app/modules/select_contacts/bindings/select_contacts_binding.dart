import 'package:get/get.dart';

import '../../../data/repositories/select_contacts/select_contact_repository.dart';
import '../../../data/repositories/select_contacts/select_contact_repository_impl.dart';
import '../../../network/api_client.dart';
import '../controllers/select_contacts_controller.dart';

class SelectContactsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiClient>(()=> ApiClient());
    Get.lazyPut<IContactRepository>(() => ContactRepositoryImpl(apiClient: Get.find<ApiClient>()));
    Get.lazyPut(() => ContactRepositoryImpl(apiClient: Get.find<ApiClient>()));
    Get.lazyPut<SelectContactsController>(() => SelectContactsController());
  }
}
