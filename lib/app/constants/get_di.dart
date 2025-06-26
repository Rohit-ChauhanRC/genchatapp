import 'package:genchatapp/app/config/services/encryption_service.dart';
import 'package:genchatapp/app/data/local_database/local_database.dart';
import 'package:genchatapp/app/data/repositories/auth/auth_repository.dart';
import 'package:genchatapp/app/data/repositories/group/group_repository.dart';
import 'package:genchatapp/app/data/repositories/profile/profile_repository.dart';
import 'package:genchatapp/app/data/repositories/select_contacts/select_contact_repository_impl.dart';
import 'package:genchatapp/app/modules/chats/controllers/chats_controller.dart';
import 'package:genchatapp/app/modules/createProfile/controllers/create_profile_controller.dart';
import 'package:genchatapp/app/modules/create_group/controllers/create_group_controller.dart';
import 'package:genchatapp/app/modules/forward_messages/controllers/forward_messages_controller.dart';
import 'package:genchatapp/app/modules/group_name/controllers/group_name_controller.dart';
import 'package:genchatapp/app/modules/home/controllers/home_controller.dart';
import 'package:genchatapp/app/modules/landing/controllers/landing_controller.dart';
import 'package:genchatapp/app/modules/verifyPhoneNumber/controllers/verify_phone_number_controller.dart';
import 'package:genchatapp/app/network/api_client.dart';
import 'package:get/get.dart';

import '../config/services/connectivity_service.dart';
import '../config/services/folder_creation.dart';
import '../config/services/socket_service.dart';
import '../data/repositories/select_contacts/select_contact_repository.dart';
import '../modules/group_profile/controllers/group_profile_controller.dart';
import '../modules/otp/controllers/otp_controller.dart';
import '../modules/select_contacts/controllers/select_contacts_controller.dart';
import '../modules/settings/controllers/settings_controller.dart';
import '../services/shared_preference_service.dart';

init() async {
  Get.lazyPut<EncryptionService>(() => EncryptionService());
  Get.lazyPut(() => ConnectivityService());
  Get.lazyPut(() => FolderCreation());
  // Get.lazyPut(() => FirebaseController());

  Get.lazyPut<SocketService>(() => SocketService());

  // Initialize SharedPreferenceService
  final sharedPreferenceService = SharedPreferenceService();
  await sharedPreferenceService.init();
  Get.put(sharedPreferenceService);

// Initialize Repositories
  Get.lazyPut(() => ApiClient());
  Get.lazyPut(() => AuthRepository(
      apiClient: Get.find<ApiClient>(),
      sharedPreferences: Get.find<SharedPreferenceService>()));
  Get.lazyPut(() => ProfileRepository(apiClient: Get.find<ApiClient>()));
  // GroupRepository
  Get.lazyPut(() => GroupRepository(
      apiClient: Get.find<ApiClient>(),
      sharedPreferences: Get.find<SharedPreferenceService>()));
  Get.lazyPut<IContactRepository>(
      () => ContactRepositoryImpl(apiClient: Get.find<ApiClient>()));

  Get.lazyPut(() => ContactRepositoryImpl(apiClient: Get.find<ApiClient>()));

  final folder = Get.find<FolderCreation>();
  // await folder.createAppFolderStructure();

  // Initialize Controllers
  Get.lazyPut(() => LandingController());
  Get.lazyPut(() =>
      VerifyPhoneNumberController(authRepository: Get.find<AuthRepository>()));
  Get.lazyPut(() => OtpController(authRepository: Get.find<AuthRepository>()));
  Get.lazyPut(() => CreateProfileController(
      profileRepository: Get.find<ProfileRepository>()));
  Get.lazyPut(() => HomeController());
  Get.lazyPut(() => ChatsController());
  Get.lazyPut(() => SelectContactsController());
  Get.lazyPut(() => SettingsController());

  Get.lazyPut(() => ForwardMessagesController());
  Get.lazyPut(() => CreateGroupController());
  Get.lazyPut(() => GroupNameController(groupRepository: Get.find<GroupRepository>()));
  Get.lazyPut(() => GroupProfileController());



}
