import 'package:flutter/cupertino.dart';
import 'package:genchatapp/app/data/repositories/group/group_repository.dart';
import 'package:get/get.dart';

import '../../../config/services/socket_service.dart';
import '../../../data/local_database/chatconnect_table.dart';
import '../../../data/local_database/contacts_table.dart';
import '../../../data/models/new_models/response_model/contact_response_model.dart';
import '../../../data/models/new_models/response_model/create_group_model.dart';
import '../../../data/models/new_models/response_model/verify_otp_response_model.dart';
import '../../../routes/app_pages.dart';
import '../../../services/shared_preference_service.dart';
import '../../../utils/alert_popup_utils.dart';

class AddParticipentsInGroupController extends GetxController {
  FocusNode focusNode = FocusNode();
  final ContactsTable contactsTable = ContactsTable();
  final ChatConectTable chatConectTable = ChatConectTable();
  final socketService = Get.find<SocketService>();
  final sharedPreferenceService = Get.find<SharedPreferenceService>();
  final groupRepo = Get.find<GroupRepository>();

  final RxList<UserList> recentChats = <UserList>[].obs;
  final RxList<UserList> contacts = <UserList>[].obs;
  final RxList<int> selectedUserIds = <int>[].obs;

  final RxString _searchQuery = ''.obs;
  String get searchQuery => _searchQuery.value;
  set searchQuery(String searchText) => _searchQuery.value = searchText;

  final RxBool isLoading = true.obs;

  List<UserList> get filteredRecents => recentChats
      .where(
        (u) => (u.localName ?? '').toLowerCase().contains(
      searchQuery.toLowerCase(),
    ),
  )
      .toList();

  List<UserList> get filteredContacts => contacts
      .where(
        (u) => (u.localName ?? '').toLowerCase().contains(
      searchQuery.toLowerCase(),
    ),
  )
      .toList();

  List<UserList> get nonRecentFilteredContacts {
    final recentIds = recentChats.map((e) => e.userId).toSet();
    return filteredContacts
        .where((u) => !recentIds.contains(u.userId))
        .toList();
  }

  bool get showRecent => filteredRecents.isNotEmpty;
  bool get showAllContacts => nonRecentFilteredContacts.isNotEmpty;

  List<String> get selectedUserNames {
    final Map<int, UserList> userMap = {};
    for (final user in [...recentChats, ...contacts]) {
      userMap[user.userId ?? 0] = user; // replaces duplicates
    }

    return userMap.entries
        .where((entry) => selectedUserIds.contains(entry.key))
        .map((e) => e.value.localName ?? e.value.phoneNumber ?? '')
        .toList();
  }

  final Rx<UserData?> _senderuserData = UserData().obs;
  UserData? get senderuserData => _senderuserData.value;
  set senderuserData(UserData? userData) => _senderuserData.value = (userData);

  final RxList<int> existingMemberIds = <int>[].obs;
  final RxInt groupId = 0.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;

    if (args != null) {
      existingMemberIds.value =
      List<int>.from(args['existingMemberIds'] ?? <int>[]);
      groupId.value = args['groupId'] ?? 0;
    }

    fetchData();
    senderuserData = sharedPreferenceService.getUserData();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
    selectedUserIds.clear();
    selectedUserNames.clear();
  }

  Future<void> fetchData() async {
    isLoading.value = true;

    // Replace with your methods to get recent chats and contacts
    final recentRaw = await chatConectTable.fetchAllWithoutGroup();
    final allContacts = await contactsTable.fetchAll();

    // Convert ChatConntactModel to UserList format
    final recent = recentRaw
        .map(
          (chat) => UserList(
        userId: int.parse(chat.uid.toString()),
        phoneNumber: chat.name,
        displayPictureUrl: chat.profilePic,
        localName: chat.name,
      ),
    )
        .toList();
    recentChats.assignAll(recent);
    contacts.assignAll(allContacts);
    isLoading.value = false;
  }

  void toggleSelection(int userId) {
    if (selectedUserIds.contains(userId)) {
      selectedUserIds.remove(userId);
    } else {
      // if (selectedUserIds.length >= 5) {
      //   showAlertMessage("You can only share with up to 5 chats.");
      //   return;
      // }
      selectedUserIds.add(userId);
    }
  }

  Future<void> addParticipants() async {
    if (selectedUserIds.isEmpty && groupId.value == 0) return;
    try{
      final uploadResponse = await groupRepo.addUsers(userId: selectedUserIds, groupId: groupId.value);

      if (uploadResponse != null && uploadResponse.statusCode == 200) {
        print("✅ User Added in Group: ${uploadResponse.data}");
        final responseModel = CreateGroupModel.fromJson(uploadResponse.data);

        if (responseModel.status == true && responseModel.data != null) {
          if (responseModel.status == true) {
            // await groupTable.insertOrUpdateGroup(responseModel.data!);
            // final data = responseModel.data;
            // final groupId = data?.group?.id ?? 0;
            // await getGroupDetails(groupId: groupId);
            Get.until((route) => route.settings.name == Routes.GROUP_PROFILE);
          }
        }
      } else {
        showAlertMessage('Failed to Add in Group.');
      }
    }catch(e){
      showAlertMessage("Getting error adding group user: $e");
    }

    // Get.until((route) => route.settings.name == Routes.HOME);
  }

  void showKeyboard() => focusNode.requestFocus();
  void hideKeyboard() => focusNode.unfocus();
}
