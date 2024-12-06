import 'dart:convert';

import 'package:genchatapp/app/constants/constants.dart';
import 'package:genchatapp/app/data/models/user_model.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../routes/app_pages.dart';

class SharedPreferenceService {
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Setters
  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  Future<void> setDouble(String key, double value) async {
    await _prefs.setDouble(key, value);
  }

  Future<void> setList(String key, List<String> value) async {
    await _prefs.setStringList(key, value);
  }

  // Getters
  String? getString(String key) => _prefs.getString(key);

  bool? getBool(String key) => _prefs.getBool(key);

  int? getInt(String key) => _prefs.getInt(key);

  double? getDouble(String key) => _prefs.getDouble(key);

  List<String>? getList(String key) => _prefs.getStringList(key);

  // Remove specific key
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  // Clear all preferences
  Future<void> clear() async {
    await _prefs.clear();
    await _prefs.reload();
  }

  UserModel? getUserDetails() {
    if (getString(userDetail) == null || getString(userDetail) == "") {
      print("UserIsNotEmpty:-----------> ${getString(userDetail)}");
      clear();
      Get.offAllNamed(Routes.LANDING);
      return null;
    } else {
      print("UserExits:--------> ${getString(userDetail)}");
      UserModel user = userModelFromJson(getString(userDetail) ?? "");
      print("UserDetails:------> ${json.decode(getString(userDetail) ?? "")}");
      return user;
    }
  }
}
