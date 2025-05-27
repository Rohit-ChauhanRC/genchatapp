import 'package:flutter/material.dart';
import 'package:genchatapp/app/services/shared_preference_service.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../../config/services/socket_service.dart';
import '../../../constants/message_enum.dart';
import '../../../data/local_database/chatconnect_table.dart';
import '../../../data/local_database/contacts_table.dart';
import '../../../data/local_database/message_table.dart';
import '../../../data/models/chat_conntact_model.dart';
import '../../../data/models/new_models/response_model/contact_response_model.dart';
import '../../../data/models/new_models/response_model/new_message_model.dart';
import '../../../data/models/new_models/response_model/verify_otp_response_model.dart';
import '../../../routes/app_pages.dart';
import '../../../utils/alert_popup_utils.dart';

class ForwardMessagesController extends GetxController {
  //
  FocusNode focusNode = FocusNode();
  final ContactsTable contactsTable = ContactsTable();
  final ChatConectTable chatConectTable = ChatConectTable();
  final socketService = Get.find<SocketService>();
  final sharedPreferenceService = Get.find<SharedPreferenceService>();

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

  List<UserList> get nonRecentFilteredContacts {
    final recentIds = recentChats.map((e) => e.userId).toSet();
    return filteredContacts.where((u) => !recentIds.contains(u.userId)).toList();
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

  @override
  void onInit() {
    super.onInit();
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
    if(selectedUserIds.contains(userId)){
      selectedUserIds.remove(userId);
    } else{
      if (selectedUserIds.length >= 5) {
        showAlertMessage("You can only share with up to 5 chats.");
        return;
      }
      selectedUserIds.add(userId);
    }
  }

  Future<void> forwardMessages() async{
    if (selectedUserIds.isEmpty || messagesToForward.isEmpty) return;

    for (final userId in selectedUserIds) {
      for (final msg in messagesToForward) {
        final clientSystemMessageId = const Uuid().v1();
        final timeSent = DateTime.now();

        final forwardMessage = NewMessageModel(
          senderId: senderuserData?.userId,
          recipientId: userId,
          message: msg.message,
          messageSentFromDeviceTime: timeSent.toString(),
          clientSystemMessageId: clientSystemMessageId,
          state: MessageState.unsent,
          syncStatus: SyncStatus.pending,
          createdAt: timeSent.toString(),
          senderPhoneNumber: senderuserData?.phoneNumber,
          messageType: msg.messageType,
          isForwarded:  true, ///showForwarded
          forwardedMessageId: msg.messageId,
          showForwarded: msg.senderId == senderuserData?.userId ? false : true,
          isRepliedMessage: false,
          messageRepliedOnId: 0,  
          messageRepliedOn: '',
          messageRepliedOnType: null,
          isAsset: msg.isAsset,
          assetOriginalName: "",
          assetServerName: "",
          assetUrl: "",
          messageRepliedUserId: 0,
        );

        print("Message All details Request: ${forwardMessage.toMap()}");

        await MessageTable().insertMessage(forwardMessage).then((onValue) {
          Future.delayed(Durations.medium4);
          socketService.saveChatContacts(forwardMessage);
          if (socketService.isConnected) {
            // _sendingMessageIds.add(clientSystemMessageId);
            socketService.sendMessage(forwardMessage);
          }
        });
      }
    }

    Get.until((route) => route.settings.name == Routes.HOME);
    // Get.offAndToNamed(Routes.HOME);
    // showAlertMessage("Messages forwarded successfully");
  }

  void showKeyboard() => focusNode.requestFocus();
  void hideKeyboard() => focusNode.unfocus();
}
