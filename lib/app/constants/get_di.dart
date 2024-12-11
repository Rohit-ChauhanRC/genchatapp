import 'package:genchatapp/app/data/local_database/local_database.dart';
import 'package:get/get.dart';

import '../config/services/connectivity_service.dart';
import '../config/services/firebase_controller.dart';
import '../config/services/folder_creation.dart';
import '../services/shared_preference_service.dart';

init() async {
  Get.lazyPut(() => SharedPreferenceService());
  Get.lazyPut(() => ConnectivityService());
  Get.lazyPut(() => FolderCreation());
  Get.lazyPut(() => FirebaseController());
  Get.lazyPut(() => DataBaseService());
  // Get.put<SharedPreferenceService>(sharedPreferenceService);
  // Get.put<ConnectivityService>(ConnectivityService());
  // Get.put<FolderCreation>(FolderCreation());
  // Get.put<FirebaseController>(FirebaseController());
  final sharedPreferenceService = Get.find<SharedPreferenceService>();
  await sharedPreferenceService.init();
  final folder = Get.find<FolderCreation>();
  await folder.createAppFolderStructure();
  final db = Get.find<DataBaseService>();
  await db.database;
}
