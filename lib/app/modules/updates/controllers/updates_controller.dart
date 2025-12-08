import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:genchatapp/app/common/user_defaults/user_defaults_keys.dart';
import 'package:genchatapp/app/config/services/folder_creation.dart';
import 'package:genchatapp/app/config/services/socket_service.dart';
import 'package:genchatapp/app/data/local_database/contacts_table.dart';
// import 'package:genchatapp/app/data/local_database/groups_table.dart';
import 'package:genchatapp/app/data/local_database/local_database.dart';
import 'package:genchatapp/app/data/local_database/status_table.dart';
import 'package:genchatapp/app/data/models/chat_conntact_model.dart';
import 'package:genchatapp/app/data/models/new_models/response_model/contact_response_model.dart';
import 'package:genchatapp/app/data/models/new_models/response_model/status_model.dart';
import 'package:genchatapp/app/data/models/new_models/response_model/verify_otp_response_model.dart';
import 'package:genchatapp/app/data/models/status_model.dart';
import 'package:genchatapp/app/data/repositories/status/status_repository.dart';
import 'package:genchatapp/app/services/shared_preference_service.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart' as rx;

class UpdatesController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final statusRepository = Get.find<StatusRepository>();

  final socketService = Get.find<SocketService>();
  final sharedPreferenceService = Get.find<SharedPreferenceService>();

  FocusNode focusNode = FocusNode();
  var currentMediaCount = 0.obs;
  // CreateGroupModel
  final RxList<Statusmodel> statusList = <Statusmodel>[].obs;

  final FolderCreation folderCreation = Get.find<FolderCreation>();

  final DataBaseService db = Get.find<DataBaseService>();

  final ContactsTable contactsTable = ContactsTable();

  final RxList<UserList> contacts = <UserList>[].obs;

  final Rx<UserData?> _senderuserData = UserData().obs;
  UserData? get senderuserData => _senderuserData.value;
  set senderuserData(UserData? userData) => _senderuserData.value = (userData);

  final RxSet<String> selectedChatUids = <String>{}.obs;

  final RxString _searchText = ''.obs;
  String get searchText => _searchText.value;
  set searchText(String searchText) => _searchText.value = searchText;

  final RxList<ChatConntactModel> filteredContacts = <ChatConntactModel>[].obs;

  // var statusList = <StatusModel>[].obs;
  RxDouble progress = 0.0.obs;
  Timer? timer;

  final RxList<int> userIdList = <int>[].obs;

  final RxMap<String, List<Statusmodel>> groupedStatusMap =
      <String, List<Statusmodel>>{}.obs;

  @override
  void onInit() async {
    senderuserData = sharedPreferenceService.getUserData();

    await getContacts();

    // loadStatuses();
    await getLocalSaveSatus();
    await getStatus();
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
    selectedChatUids.clear();
    timer?.cancel();
  }

  void startProgress({double durationSeconds = 5, required Function onFinish}) {
    stopProgress();
    progress.value = 0;

    const tick = Duration(milliseconds: 50);
    final totalTicks = (durationSeconds * 1000 / tick.inMilliseconds).round();
    int currentTick = 0;

    timer = Timer.periodic(tick, (timer) {
      currentTick++;
      progress.value = currentTick / totalTicks;
      if (currentTick >= totalTicks) {
        stopProgress();
        onFinish(); // call when finished
      }
    });
  }

  void skip() {
    timer?.cancel();
    Get.back();
  }

  void stopProgress() {
    timer?.cancel();
    timer = null;
  }

  void setProgress(double p) {
    progress.value = p.clamp(0.0, 1.0);
  }

  void markAsViewed(StatusModel status) {
    status.viewed = true;
    statusList.refresh();
  }

  void showKeyboard() => focusNode.requestFocus();
  void hideKeyboard() => focusNode.unfocus();

  Future<void> getContacts() async {
    userIdList.clear();
    contacts(await contactsTable.fetchAll());
    for (var i = 0; i < contacts.length; i++) {
      userIdList.add(contacts[i].userId!);
    }
    userIdList.add(senderuserData!.userId!);
  }

  Future<void> getStatus() async {
    try {
      // CHECK INTERNET
      final connectivityResult = await Connectivity().checkConnectivity();
      final hasInternet = connectivityResult != ConnectivityResult.none;

      if (!hasInternet) {
        print("📛 No internet → Loading local saved statuses only...");
        await getLocalSaveSatus(); // ⭐ LOAD ONLY FROM DB
        return;
      }

      print("🌐 Internet available → Fetching from API");

      if (contacts.isEmpty) {
        print(" No contacts → Skipping API");
        return;
      }

      print("Fetching statuses for User IDs: $userIdList");

      final response = await statusRepository.fetchStatus(userIds: userIdList);

      if (response == null || response.statusCode != 200) {
        print(" API error → loading local DB instead");
        await getLocalSaveSatus(); // ⭐ FALLBACK
        return;
      }

      print(" API response OK");
      print("Raw response: ${response.data}");

      // ---------- PARSE MODEL ----------
      List<dynamic> raw = response.data['data'];
      List<Statusmodel> modelList = raw
          .map((e) => Statusmodel.fromJson(e))
          .toList();

      // ---------- ATTACH LOCAL PATH ----------
      for (var status in modelList) {
        for (var m in status.media) {
          if (m["type"] == "text") continue;

          try {
            final f = await DefaultCacheManager().getSingleFile(m['url']);
            m['localPath'] = f.path;
            status.localPath = f.path;
          } catch (_) {}
        }
      }

      // ---------- SAVE TO DB ----------
      await StatusTable().syncStatuses(modelList);

      // ---------- LOAD FROM DB ----------
      await getLocalSaveSatus();

      print("✅ getStatus() finished with ONLINE mode");
    } catch (e, st) {
      print("🔥 ERROR in getStatus(): $e");
      print(st);

      print(" Falling back to local DB...");
      await getLocalSaveSatus(); // ALWAYS fallback in errors
    }
  }

  Future<void> getLocalSaveSatus() async {
    int? statusTime = sharedPreferenceService.getInt(
      UserDefaultsKeys.statusDurationKey,
    );
    final saved = await StatusTable().getAllStatuses(statusTime: statusTime!);

    final Map<String, List<Statusmodel>> grouped = {};
    for (var status in saved) {
      grouped.putIfAbsent(status.userId.toString(), () => []);
      grouped[status.userId.toString()]!.add(status);
    }

    groupedStatusMap.value = grouped;
  }

  Future<void> deletStatus(int statusId) async {
    final response = await statusRepository.deleteStatus(statusId: statusId);

    if (response != null || response!.statusCode == 200) {
      // await getLocalSaveSatus(); // ⭐ FALLBACK
      await StatusTable().deleteStatusById(statusId);
      await getLocalSaveSatus();
    }
  }
}
