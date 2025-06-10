import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:genchatapp/app/config/services/connectivity_service.dart';
import 'package:genchatapp/app/config/services/firebase_controller.dart';
import 'package:genchatapp/app/config/services/socket_service.dart';
import 'package:genchatapp/app/modules/call/controllers/call_controller.dart';
import 'package:genchatapp/app/modules/chats/controllers/chats_controller.dart';
import 'package:genchatapp/app/modules/select_contacts/controllers/select_contacts_controller.dart';
import 'package:genchatapp/app/modules/updates/controllers/updates_controller.dart';
import 'package:genchatapp/app/services/shared_preference_service.dart';
import 'package:genchatapp/app/utils/utils.dart';
import 'package:get/get.dart';

class HomeController extends GetxController with WidgetsBindingObserver {
  //
  final sharedPreferenceService = Get.find<SharedPreferenceService>();
  final connectivityService = Get.find<ConnectivityService>();
  final selectedContactController = Get.find<SelectContactsController>();

  final socketService = Get.find<SocketService>();

  final RxInt _currentPageIndex = 0.obs;
  int get currentPageIndex => _currentPageIndex.value;
  set currentPageIndex(int currentPageIndex) =>
      _currentPageIndex.value = currentPageIndex;

  @override
  void onInit() async {
    super.onInit();
    closeKeyboard();

    // FocusManager.instance.primaryFocus?.unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');

    controllerInit();

    String? userId = sharedPreferenceService.getUserData()?.userId.toString();
    socketService.initSocket(userId!, onConnected: () {
      print(
          'Initial socket connection established in HomeController: UserId for socket connection: $userId');
    });
    // connectSocket();
    // print(sharedPreferenceService.getUserDetails()?.name);
    // print(connectivityService.isConnected.value);
    SchedulerBinding.instance.addPostFrameCallback((timestamp) async {
      if (connectivityService.isConnected.value) {
        // await setUserOnline();
      } else {
        // await setUserOffline();
      }
    });
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        print('📱 App Resumed: Trying to reconnect socket...');
        if (connectivityService.isConnected.value) {
          // await setUserOnline();
          await connectSocket();
          await selectedContactController.syncContactsWithServer();
        }

        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.paused:
        print('📴 App Backgrounded: Disposing socket...');
        disConnectSocket();

        break;
      default:
    }
  }

  Future<void> connectSocket() async {
    String? userId = sharedPreferenceService.getUserData()?.userId.toString();
    if (userId != null && !socketService.isConnected) {
      await socketService.initSocket(userId);
    }
  }

  void disConnectSocket() async {
    socketService.disposeSocket();
  }

  void controllerInit() {
    Get.lazyPut<ChatsController>(
      () => ChatsController(groupRepository: Get.find()),
    );
    Get.lazyPut<UpdatesController>(
      () => UpdatesController(),
    );
    Get.lazyPut<CallController>(
      () => CallController(),
    );
  }
}
