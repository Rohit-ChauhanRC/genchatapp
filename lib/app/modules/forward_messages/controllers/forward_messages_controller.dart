import 'package:flutter/material.dart';
import 'package:genchatapp/app/data/local_database/groups_table.dart';
import 'package:genchatapp/app/data/models/new_models/response_model/create_group_model.dart';
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

  final RxList<int> selectedUserIsGroup = <int>[].obs;

  final RxString _searchQuery = ''.obs;
  String get searchQuery => _searchQuery.value;
  set searchQuery(String searchText) => _searchQuery.value = searchText;

  List<NewMessageModel> get messagesToForward =>
      Get.arguments as List<NewMessageModel>;

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

  final RxList<GroupData> groupsList = <GroupData>[].obs;

  @override
  void onInit() async {
    super.onInit();
    await fetchGroup();
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

  Future<void> fetchGroup() async {
    groupsList.value = await GroupsTable().fetchAllGroups();
  }

  // Future<void> fetchData() async {
  //   isLoading.value = true;

  //   // Replace with your methods to get recent chats and contacts
  //   final recentRaw = await chatConectTable.fetchAll();
  //   final allContacts = await contactsTable.fetchAll();

  //   // Convert ChatConntactModel to UserList format

  //   // (chatConntactModel.isGroup ==1)
  //   // List<ChatConntactModel> recentRaw
  //   final recent = recentRaw.map((chat) {
  //     final bool isGroup = chat.isGroup == 1;

  //     if (isGroup) {
  //       // groupsList.value how to get group with id
  //       //    final bool isReadOnly =
  //       // isGroup && groupData.value?.group?.isReadOnly == true;

  //    final group   = await GroupsTable().getGroupById(int.parse(chat.uid!));
  //       // final group = groupsList.firstWhereOrNull(
  //       //   (g) => g.group?.id.toString() == chat.uid.toString(),
  //       // );

  //       final bool isReadOnly = group?.group?.isReadOnly == true;

  //       return UserList(
  //         userId: int.parse(chat.uid.toString()),
  //         phoneNumber: chat.name,
  //         displayPictureUrl: chat.profilePic,
  //         localName: chat.name,
  //         isBlocked: isReadOnly ? true : chat.isBlocked == 1,
  //       );
  //     } else {
  //       return UserList(
  //         userId: int.parse(chat.uid.toString()),
  //         phoneNumber: chat.name,
  //         displayPictureUrl: chat.profilePic,
  //         localName: chat.name,
  //         isBlocked: chat.isBlocked == 1 ? true : false,
  //       );
  //     }
  //   }).toList();
  //   recentChats.assignAll(recent);
  //   contacts.assignAll(allContacts);
  //   isLoading.value = false;
  // }
  Future<void> fetchData() async {
    isLoading.value = true;

    final recentRaw = await chatConectTable.fetchAll();
    final allContacts = await contactsTable.fetchAll();

    final List<UserList> recent = [];

    for (final chat in recentRaw) {
      final bool isGroup = chat.isGroup == 1;
      bool isReadOnly = false;

      if (isGroup) {
        final group = await GroupsTable().getGroupById(int.parse(chat.uid!));

        isReadOnly = group?.group?.isReadOnly == true;
      }

      recent.add(
        UserList(
          userId: int.parse(chat.uid.toString()),
          phoneNumber: chat.name,
          displayPictureUrl: chat.profilePic,
          localName: chat.name,
          isBlocked: isReadOnly ? true : chat.isBlocked == 1,
        ),
      );
    }

    recentChats.assignAll(recent);
    contacts.assignAll(allContacts);
    isLoading.value = false;
  }

  void toggleSelection(int userId) async {
    if (selectedUserIds.contains(userId)) {
      selectedUserIds.remove(userId);
      if (selectedUserIsGroup.contains(userId)) {
        selectedUserIsGroup.remove(userId);
      }
    } else {
      if (selectedUserIds.length >= 5) {
        showAlertMessage("You can only share with up to 5 chats.");
        return;
      }

      selectedUserIds.add(userId);
      ChatConntactModel? chatUser = await chatConectTable.fetchUserById(
        uid: userId.toString(),
      );
      if (chatUser != null && chatUser.isGroup != 0) {
        selectedUserIsGroup.add(userId);
      }
    }
  }

  Future<void> forwardMessages() async {
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
          isForwarded: true,

          ///showForwarded
          isGroupMessage: selectedUserIsGroup.contains(userId) ? true : false,

          ///showForwarded
          forwardedMessageId: msg.messageId,
          showForwarded: msg.senderId == senderuserData?.userId ? false : true,
          isRepliedMessage: false,
          messageRepliedOnId: 0,
          messageRepliedOn: '',
          messageRepliedOnType: null,
          messageRepliedOnAssetServerName: "",
          messageRepliedOnAssetThumbnail: "",
          isAsset: msg.isAsset,
          assetThumbnail: msg.assetThumbnail,
          assetOriginalName: msg.assetOriginalName,
          assetServerName: msg.assetServerName,
          assetUrl: msg.assetUrl,
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
