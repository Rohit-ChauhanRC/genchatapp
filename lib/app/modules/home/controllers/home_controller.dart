import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:genchatapp/app/config/services/connectivity_service.dart';
import 'package:genchatapp/app/config/services/firebase_controller.dart';
import 'package:genchatapp/app/services/shared_preference_service.dart';
import 'package:get/get.dart';

class HomeController extends GetxController with WidgetsBindingObserver {
  //
  final sharedPreferenceService = Get.find<SharedPreferenceService>();
  final ConnectivityService connectivityService = Get.find();
  final FirebaseController firebaseController = Get.find();

  final RxInt _currentPageIndex = 0.obs;
  int get currentPageIndex => _currentPageIndex.value;
  set currentPageIndex(int currentPageIndex) =>
      _currentPageIndex.value = currentPageIndex;

  @override
  void onInit() {
    super.onInit();
    print(sharedPreferenceService.getUserDetails()?.name);
    print(connectivityService.isConnected.value);
    SchedulerBinding.instance.addPostFrameCallback((timestamp) async {
      if (connectivityService.isConnected.value) {
        await setUserOnline();
      } else {
        await setUserOffline();
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
        if (connectivityService.isConnected.value) {
          await setUserOnline();
        }

        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.paused:
        await setUserOffline();

        break;
      default:
    }
  }

  Future<void> setUserOnline() async {
    final userRef = firebaseController.firestore
        .collection('users')
        .doc(sharedPreferenceService.getUserDetails()?.uid);

    // Set online status
    await userRef.set({
      'isOnline': true,
      'lastSeen': DateTime.now().microsecondsSinceEpoch.toString(),
    }, SetOptions(merge: true));

    // Set offline status on disconnection
    // userRef.update({
    //   'isOnline': false,
    //   'lastSeen': FieldValue.serverTimestamp()
    // }).then((_) {
    //   firebaseController.firestore.runTransaction((transaction) async {
    //     transaction.set(userRef, {'isOnline': false}, SetOptions(merge: true));
    //   });
    // });
  }

  Future<void> setUserOffline() async {
    final userRef = firebaseController.firestore
        .collection('users')
        .doc(sharedPreferenceService.getUserDetails()?.uid);
    await userRef.update({
      'isOnline': false,
      'lastSeen': DateTime.now().microsecondsSinceEpoch.toString(),
    });
  }
}
