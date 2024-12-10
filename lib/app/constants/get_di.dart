import 'package:get/get.dart';

import '../config/services/connectivity_service.dart';
import '../config/services/firebase_controller.dart';
import '../config/services/folder_creation.dart';
import '../services/shared_preference_service.dart';

init() async{

  Get.lazyPut(()=> SharedPreferenceService());
  Get.lazyPut(()=>ConnectivityService());
  Get.lazyPut(()=> FolderCreation());
  Get.lazyPut(()=> FirebaseController());
  // Get.put<SharedPreferenceService>(sharedPreferenceService);
  // Get.put<ConnectivityService>(ConnectivityService());
  // Get.put<FolderCreation>(FolderCreation());
  // Get.put<FirebaseController>(FirebaseController());
  final sharedPreferenceService = Get.find<SharedPreferenceService>();
  await sharedPreferenceService.init();
}