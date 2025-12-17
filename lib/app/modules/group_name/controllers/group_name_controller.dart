import 'dart:io';

import 'package:flutter/material.dart';
import 'package:genchatapp/app/data/local_database/chatconnect_table.dart';
import 'package:genchatapp/app/data/local_database/contacts_table.dart';
import 'package:genchatapp/app/data/local_database/groups_table.dart';
import 'package:genchatapp/app/data/models/chat_conntact_model.dart';
import 'package:genchatapp/app/data/models/new_models/response_model/contact_response_model.dart';
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

  final ContactsTable contactsTable = ContactsTable();

  FocusNode focusNode = FocusNode();

  final RxString _groupName = ''.obs;
  String get groupName => _groupName.value;
  set groupName(String searchText) => _groupName.value = searchText;

  final RxList<int> _selectedUserIds = <int>[].obs;
  List<int> get selectedUserIds => _selectedUserIds;
  set selectedUserIds(List<int> i) => _selectedUserIds.assignAll(i);

  final RxBool _circularProgress = false.obs;
  bool get circularProgress => _circularProgress.value;
  set circularProgress(bool v) => _circularProgress.value = v;

  final Rx<File?> _image = Rx<File?>(null);
  File? get image => _image.value;
  set image(File? img) => _image.value = img;

  RxBool isOn = false.obs;

  final RxList<int> _selectedUserIdVanishMode = <int>[].obs;
  List<int> get selectedUserIdVanishMode => _selectedUserIdVanishMode;
  set selectedUserIdVanishMode(List<int> i) =>
      _selectedUserIdVanishMode.assignAll(i);

  final RxList<UserList> contacts = <UserList>[].obs;

  final RxBool isLoading = true.obs;

  final RxInt groupId = RxInt(0);

  @override
  void onInit() {
    super.onInit();
    selectedUserIds = Get.arguments;
  }

  @override
  void onReady() async {
    super.onReady();
    await fetchData();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void selectImage() async {
    showImagePicker(
      onGetImage: (img) {
        if (img != null) {
          image = img;
        }
      },
    );
  }

  Future<void> createGroup() async {
    if (selectedUserIds.isEmpty) return;

    try {
      circularProgress = true;

      // Step 1: Create group
      final response = await groupRepository.createGroup(
        groupName,
        selectedUserIds,
      );

      if (response != null && response.statusCode == 200) {
        final createGroupModelResponse = CreateGroupModel.fromJson(
          response.data,
        );

        if (createGroupModelResponse.status == true) {
          final data = createGroupModelResponse.data;
          groupId.value = data?.group?.id ?? 0;

          // Step 2: Insert initial group data into DB
          await groupsTable.insertOrUpdateGroup(data!);

          // Step 3: Only upload image if selected
          if (image != null) {
            await uploadGroupIcon(groupId: groupId.value);
          } else {
            await chatConectTable.insert(
              contact: ChatConntactModel(
                lastMessageId: 0,
                contactId: groupId.value.toString(),
                lastMessage: "",
                name: data.group?.name ?? '',
                profilePic: data.group?.displayPictureUrl ?? '',
                timeSent:
                    data.group?.updatedAt ??
                    "", //DateTime.now().toString(), //?? data.group?.createdAt,
                uid: groupId.value.toString(),
                isGroup: 1,
              ),
            );
          }

          if (isOn.value) {
            await isReadOnlyAdGroup();
          }

          if (selectedUserIdVanishMode.isNotEmpty) {
            await isVanishModeGroup();
          }

          print("✅ Create group response: $data");
          Get.offAllNamed(Routes.HOME);
          // Get.until((route) => route.settings.name == Routes.HOME);
        }
      }
    } catch (e) {
      showAlertMessage("Something went wrong: $e");
    } finally {
      circularProgress = false;
    }
  }

  Future<void> uploadGroupIcon({required int groupId}) async {
    if (image == null) return;

    try {
      final processedImage = image!;
      final uploadResponse = await groupRepository.uploadGroupPic(
        processedImage,
        groupId,
      );

      if (uploadResponse != null && uploadResponse.statusCode == 200) {
        print("✅ Group icon uploaded: ${uploadResponse.data}");
        final responseModel = CreateGroupModel.fromJson(uploadResponse.data);

        if (responseModel.status == true && responseModel.data != null) {
          if (responseModel.status == true) {
            await groupsTable.insertOrUpdateGroup(responseModel.data!);
            final data = responseModel.data;
            final groupId = data?.group?.id ?? 0;
            await chatConectTable.insert(
              contact: ChatConntactModel(
                lastMessageId: 0,
                contactId: groupId.toString(),
                lastMessage: "",
                name: data?.group?.name ?? '',
                profilePic: data?.group?.displayPictureUrl ?? '',
                timeSent:
                    data?.group?.updatedAt ??
                    '', // DateTime.now().toString(),//data?.group?.createdAt ?? '',
                uid: groupId.toString(),
                isGroup: 1,
              ),
            );
          }
        }
      } else {
        showAlertMessage('Failed to upload group picture.');
      }
    } catch (e) {
      showAlertMessage("Error uploading group icon: $e");
    }
  }

  void showKeyboard() => focusNode.requestFocus();
  void hideKeyboard() => focusNode.unfocus();

  void setValue(bool value) {
    isOn.value = value;
  }

  void toggleSelection(int userId) {
    if (selectedUserIdVanishMode.contains(userId)) {
      selectedUserIdVanishMode.remove(userId);
    } else {
      selectedUserIdVanishMode.add(userId);
    }
  }

  Future<void> fetchData() async {
    // isLoading.value = true;

    contacts.clear();
    if (selectedUserIds.isNotEmpty) {
      for (var i = 0; i < selectedUserIds.length; i++) {
        final allContacts = await contactsTable.getUserById(selectedUserIds[i]);
        contacts.add(allContacts!);
      }
    }
    // isLoading.value = false;
  }

  Future<void> isVanishModeGroup() async {
    if (selectedUserIdVanishMode.isEmpty) return;

    try {
      circularProgress = true;

      // Step 1: Create group
      final response = await groupRepository.isVanishModeGroup(
        selectedUserIdVanishMode,
        groupId.value,
      );

      if (response != null && response.statusCode == 200) {
        final responseModel = CreateGroupModel.fromJson(response.data);

        if (responseModel.status == true && responseModel.data != null) {
          if (responseModel.status == true) {
            await groupsTable.insertOrUpdateGroup(responseModel.data!);
          }
        }
      }
    } catch (e) {
      showAlertMessage("Something went wrong: $e");
    } finally {
      circularProgress = false;
    }
  }

  // isReadOnlyAdminGroup

  Future<void> isReadOnlyAdGroup() async {
    // if (selectedUserIdVanishMode.isEmpty) return;

    try {
      circularProgress = true;

      // Step 1: Create group
      final response = await groupRepository.isReadOnlyAdminGroup(
        groupId.value,
      );

      if (response != null && response.statusCode == 200) {
        await groupsTable.updateGroupReadOnly(
          groupId.value,
          response.data['data']['isReadOnly'] == true ? 1 : 0,
        );
      }
    } catch (e) {
      showAlertMessage("Something went wrong: $e");
    } finally {
      circularProgress = false;
    }
  }
}
