import 'dart:io';

import 'package:flutter/material.dart';
import 'package:genchatapp/app/data/local_database/chatconnect_table.dart';
import 'package:genchatapp/app/data/local_database/groups_table.dart';
import 'package:genchatapp/app/data/models/chat_conntact_model.dart';
import 'package:genchatapp/app/data/models/new_models/response_model/create_group_model.dart';
import 'package:genchatapp/app/data/repositories/group/group_repository.dart';
import 'package:genchatapp/app/routes/app_pages.dart';
import 'package:genchatapp/app/services/shared_preference_service.dart';
import 'package:genchatapp/app/utils/alert_popup_utils.dart';
import 'package:genchatapp/app/utils/utils.dart';
import 'package:get/get.dart';

class GroupNameController extends GetxController {
  final GroupRepository groupRepository;

  GroupNameController({required this.groupRepository});

  final sharedPreferenceService = Get.find<SharedPreferenceService>();

  final GroupsTable groupsTable = GroupsTable();
  final ChatConectTable chatConectTable = ChatConectTable();


  FocusNode focusNode = FocusNode();

  final RxString _searchQuery = ''.obs;
  String get searchQuery => _searchQuery.value;
  set searchQuery(String searchText) => _searchQuery.value = searchText;

  final RxList<int> _selectedUserIds = <int>[].obs;
  List<int> get selectedUserIds => _selectedUserIds;
  set selectedUserIds(List<int> i) => _selectedUserIds.assignAll(i);

  final RxBool _circularProgress = false.obs;
  bool get circularProgress => _circularProgress.value;
  set circularProgress(bool v) => _circularProgress.value = v;

  final Rx<File?> _image = Rx<File?>(null);
  File? get image => _image.value;
  set image(File? img) => _image.value = img;

  @override
  void onInit() {
    super.onInit();
    selectedUserIds = Get.arguments;
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void selectImage() async {
    showImagePicker(onGetImage: (img) {
      if (img != null) {
        image = img;
      }
    });
  }

  Future<void> createGroup() async {
    if (selectedUserIds.isEmpty) return;

    try {
      circularProgress = true;

      final response =
          await groupRepository.createGroup(searchQuery, selectedUserIds);
      if (response != null && response.statusCode == 200) {
        final getVerifyNumberResponse =
            CreateGroupModel.fromJson(response.data);
        if (getVerifyNumberResponse.status == true) {
          groupsTable.insertGroup(getVerifyNumberResponse.data!);
          final data = getVerifyNumberResponse.data!;
           await chatConectTable.insert(
            contact: ChatConntactModel(
              lastMessageId: 0,
              contactId: data.id.toString(),
              lastMessage: "",
              name: data.name,
              profilePic: data.displayPicture ?? '',
              timeSent: data.createdAt,
              uid: data.id.toString(),
            ),
          );
          Get.until((route) => route.settings.name == Routes.HOME);
        }
      }
    } catch (e) {
      // print("Error in verifyOTPCred: $e");
      showAlertMessage("Something went wrong: $e");
    } finally {
      circularProgress = false;
    }
    // Get.toNamed(Routes.GROUP_NAME, arguments: selectedUserIds);
  }

  void showKeyboard() => focusNode.requestFocus();
  void hideKeyboard() => focusNode.unfocus();
}
