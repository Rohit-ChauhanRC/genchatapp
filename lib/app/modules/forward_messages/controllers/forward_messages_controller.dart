import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/local_database/chatconnect_table.dart';
import '../../../data/local_database/contacts_table.dart';
import '../../../data/models/chat_conntact_model.dart';
import '../../../data/models/new_models/response_model/contact_response_model.dart';
import '../../../data/models/new_models/response_model/new_message_model.dart';
import '../../../utils/alert_popup_utils.dart';

class ForwardMessagesController extends GetxController {
  //
  FocusNode focusNode = FocusNode();
  final ContactsTable contactsTable = ContactsTable();
  final ChatConectTable chatConectTable = ChatConectTable();

  final RxList<UserList> recentChats = <UserList>[].obs;
  final RxList<UserList> contacts = <UserList>[].obs;
  final RxList<int> selectedUserIds = <int>[].obs;

  final RxString _searchQuery = ''.obs;
  String get searchQuery => _searchQuery.value;
  set searchQuery(String searchText) => _searchQuery.value = searchText;

  List<NewMessageModel> get messagesToForward => Get.arguments as List<NewMessageModel>;

  final RxBool isLoading = true.obs;

  List<UserList> get filteredRecents => recentChats
      .where((u) => (u.localName ?? '').toLowerCase().contains(searchQuery.toLowerCase()))
      .toList();

  List<UserList> get filteredContacts => contacts
      .where((u) => (u.localName ?? '').toLowerCase().contains(searchQuery.toLowerCase()))
      .toList();

  List<String> get selectedUserNames {
    final all = [...recentChats, ...contacts];
    return all
        .where((u) => selectedUserIds.contains(u.userId))
        .map((u) => u.localName ?? u.phoneNumber ?? '')
        .toList();
  }
  @override
  void onInit() {
    super.onInit();
    fetchData();
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
    final recentRaw = await chatConectTable.fetchAll();
    final allContacts = await contactsTable.fetchAll();

    // Convert ChatConntactModel to UserList format
    final recent = recentRaw.map((chat) => UserList(
      userId: int.parse(chat.uid.toString()),
      phoneNumber: chat.name,
      displayPictureUrl: chat.profilePic,
      localName: chat.name,
    )).toList();
    recentChats.assignAll(recent);
    contacts.assignAll(allContacts);
    isLoading.value = false;
  }

  void toggleSelection(int userId) {
    selectedUserIds.contains(userId)
        ? selectedUserIds.remove(userId)
        : selectedUserIds.add(userId);
  }

  void forwardMessages() {
    if (selectedUserIds.isEmpty || messagesToForward.isEmpty) return;

    for (final userId in selectedUserIds) {
      for (final msg in messagesToForward) {
        // SocketService.to.sendForwardedMessage(to: userId, message: msg);
      }
    }

    Get.back();
    showAlertMessage("Messages forwarded successfully");
  }

  void showKeyboard() => focusNode.requestFocus();
  void hideKeyboard() => focusNode.unfocus();
}
