import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/scheduler.dart';
import 'package:genchatapp/app/config/services/connectivity_service.dart';
import 'package:genchatapp/app/config/services/firebase_controller.dart';
import 'package:genchatapp/app/data/models/user_model.dart';
import 'package:genchatapp/app/services/shared_preference_service.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class SingleChatController extends GetxController with WidgetsBindingObserver {
  //

  final ConnectivityService connectivityService = Get.find();
  final FirebaseController firebaseController = Get.find();
  final sharedPreferenceService = Get.find<SharedPreferenceService>();

  final Rx<UserModel> _userData = UserModel().obs;
  UserModel get userData => _userData.value;
  set userData(UserModel userData) => _userData.value = (userData);

  Rx<UserModel> userDataModel = UserModel(
    isOnline: false,
  ).obs;

  @override
  void onInit() {
    userData = Get.arguments;
    bindStream();
    print("UserData:-----------> $_userData");
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void bindStream() {
    userDataModel.bindStream(firebaseController.getUserData(userData.uid!));
  }
}
