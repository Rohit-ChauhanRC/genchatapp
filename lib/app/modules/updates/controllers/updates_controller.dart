import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
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

  // void loadStatuses() {
  //   statusList.assignAll([
  //     StatusModel(
  //       name: "Alice",
  //       media: [
  //         {'type': 'image', 'url': 'https://i.pravatar.cc/150?img=2'},
  //         {
  //           'type': 'video',
  //           'url':
  //               'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
  //         },
  //         {'type': 'image', 'url': 'https://i.pravatar.cc/150?img=2'},
  //       ],
  //       ProfilePic: "https://i.pravatar.cc/150?img=2",

  //       time: "Today, 9:00 AM",
  //     ),
  //     StatusModel(
  //       name: "Bob",
  //       media: [
  //         {'type': 'image', 'url': 'https://i.pravatar.cc/150?img=2'},
  //         {
  //           'type': 'video',
  //           'url':
  //               'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
  //         },
  //         {'type': 'image', 'url': 'https://picsum.photos/801/1400'},
  //         {'type': 'text', 'text': 'Hello AbhiJha'},
  //       ],
  //       time: "Today, 10:30 AM",
  //       ProfilePic: "https://i.pravatar.cc/150?img=2",
  //     ),
  //     StatusModel(
  //       name: "Charlie",
  //       media: [
  //         {'type': 'image', 'url': 'https://picsum.photos/800/1400'},
  //         {
  //           'type': 'video',
  //           'url':
  //               'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
  //         },
  //         {'type': 'image', 'url': 'https://picsum.photos/801/1400'},
  //       ],
  //       time: "Yesterday, 8:15 PM",
  //       ProfilePic: "https://i.pravatar.cc/150?img=2",
  //       viewed: true,
  //     ),
  //   ]);
  // }

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
      if (contacts.isEmpty) {
        print(" No contacts → Skipping");
        return;
      }

      print("Fetching statuses for User IDs: $userIdList");

      final response = await statusRepository.fetchStatus(userIds: userIdList);

      if (response == null || response.statusCode != 200) {
        print(" API error → response invalid");
        return;
      }

      print(" API response OK");
      print("Raw response: ${response.data}");

      // ---------- PARSE MODEL ----------
      List<dynamic> raw = response.data['data'];
      print("Total records from API: ${raw.length}");

      List<Statusmodel> modelList = raw
          .map((e) => Statusmodel.fromJson(e))
          .toList();

      print("Parsed into modelList: ${modelList.length}");

      for (var s in modelList) {
        print(
          "Parsed Status => id:${s.id}, userId:${s.userId}, type:${s.statusAssetType}, isAsset:${s.isAsset}, text:${s.statusText}, url:${s.assetUrl}",
        );
      }

      // ---------- ATTACH LOCAL PATH ----------
      print(" Downloading and attaching localPath...");
      for (var status in modelList) {
        print("Processing userId=${status.userId}, statusId=${status.id}");

        for (var i = 0; i < status.media.length; i++) {
          final m = status.media[i];

          if (m["type"] == "text") continue;

          try {
            final f = await DefaultCacheManager().getSingleFile(m['url']);
            m['localPath'] = f.path;

            // ⭐ IMPORTANT — SAVE TO MODEL
            status.localPath = f.path;

            print("Downloaded → localPath=${f.path}");
          } catch (e) {
            print("Download failed: $e");
          }
        }

      }

      // ---------- SAVE TO DB ----------
      print("Saving ${modelList.length} statuses into SQLite...");

      await StatusTable().saveAllStatuses(modelList);

      print(" SQLite save completed!");

      print(" Fetching saved records from SQLite for verification...");
      final saved = await StatusTable().getAllStatuses();

      for (var s in saved) {
        print(
          " DB Record => id:${s.id}, userId:${s.userId}, text:${s.statusText}, url:${s.assetUrl}, type:${s.statusAssetType}, media:${s.media}",
        );
      }

      // ---------- GROUP DATA ----------
      final Map<String, List<Statusmodel>> grouped = {};
      for (var status in modelList) {
        grouped.putIfAbsent(status.userId.toString(), () => []);
        grouped[status.userId.toString()]!.add(status);
      }

      print(" Grouped users count: ${grouped.length}");
      groupedStatusMap.value = grouped;

      print("🏁 getStatus() finished successfully!");
    } catch (e, st) {
      print("🔥 ERROR in getStatus(): $e");
      print(st);
    }
  }
}
