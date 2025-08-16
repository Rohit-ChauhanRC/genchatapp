import 'dart:async';
import 'dart:io';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genchatapp/app/config/services/connectivity_service.dart';
import 'package:genchatapp/app/config/services/encryption_service.dart';
import 'package:genchatapp/app/config/services/folder_creation.dart';
import 'package:genchatapp/app/config/services/socket_service.dart';
import 'package:genchatapp/app/constants/message_enum.dart';
import 'package:genchatapp/app/data/local_database/chatconnect_table.dart';
import 'package:genchatapp/app/data/local_database/contacts_table.dart';
import 'package:genchatapp/app/data/local_database/groups_table.dart';
import 'package:genchatapp/app/data/local_database/message_table.dart';
import 'package:genchatapp/app/data/models/message_reply.dart'
    show MessageReply;
import 'package:genchatapp/app/data/models/new_models/response_model/contact_response_model.dart';
import 'package:genchatapp/app/data/models/new_models/response_model/message_ack_model.dart';
import 'package:genchatapp/app/data/models/new_models/response_model/new_message_model.dart';
import 'package:genchatapp/app/data/models/new_models/response_model/upload_file_model.dart';
import 'package:genchatapp/app/data/models/new_models/response_model/verify_otp_response_model.dart';
import 'package:genchatapp/app/data/repositories/profile/profile_repository.dart';
import 'package:genchatapp/app/routes/app_pages.dart';
import 'package:genchatapp/app/services/shared_preference_service.dart';
import 'package:genchatapp/app/utils/alert_popup_utils.dart';
import 'package:genchatapp/app/utils/utils.dart';
import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:tenor_flutter/tenor_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../data/models/new_models/response_model/create_group_model.dart';

class GroupChatsController extends GetxController with WidgetsBindingObserver {
  //

  final connectivityService = Get.find<ConnectivityService>();
  final sharedPreferenceService = Get.find<SharedPreferenceService>();
  final FolderCreation folderCreation = Get.find<FolderCreation>();
  final ContactsTable contactsTable = ContactsTable();
  final socketService = Get.find<SocketService>();

  final ChatConectTable chatConectTable = ChatConectTable();

  final EncryptionService encryptionService = Get.find();

  final ProfileRepository profileRepository = Get.put<ProfileRepository>(
    ProfileRepository(apiClient: Get.find()),
  );

  var hasScrolledInitially = false.obs;
  // final isKeyboardVisible = false.obs;
  final showScrollToBottom = false.obs;

  final TextEditingController messageController = TextEditingController();

  final Rx<Emoji> emoji = const Emoji("", "").obs;

  final ScrollController scrollController = ScrollController();

  final Rx<MessageReply> _messageReply = MessageReply().obs;
  MessageReply get messageReply => _messageReply.value;
  set messageReply(MessageReply msg) => _messageReply.value = msg;

  final RxBool _isShowSendButton = false.obs;
  bool get isShowSendButton => _isShowSendButton.value;
  set isShowSendButton(bool b) => _isShowSendButton.value = b;

  final RxBool _isRepUpdate = false.obs;
  bool get isRepUpdate => _isRepUpdate.value;
  set isRepUpdate(bool b) => _isRepUpdate.value = b;

  final RxBool _isReply = false.obs;
  bool get isReply => _isReply.value;
  set isReply(bool b) => _isReply.value = b;

  final RxBool _isShowEmojiContainer = false.obs;
  bool get isShowEmojiContainer => _isShowEmojiContainer.value;
  set isShowEmojiContainer(bool b) => _isShowEmojiContainer.value = b;

  final RxBool _isRecording = false.obs;
  bool get isRecording => _isRecording.value;
  set isRecording(bool b) => _isRecording.value = b;

  final RxBool _isRecorderInit = false.obs;
  bool get isRecorderInit => _isRecorderInit.value;
  set isRecorderInit(bool b) => _isRecorderInit.value = b;

  final RxBool _isReceiverTyping = false.obs;
  bool get isReceiverTyping => _isReceiverTyping.value;
  set isReceiverTyping(bool b) => _isReceiverTyping.value = b;

  final RxString _typingDisplayText = "".obs;
  String get typingDisplayText => _typingDisplayText.value;
  set typingDisplayText(String b) => _typingDisplayText.value = b;

  final RxBool _isLoading = true.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(bool b) => _isLoading.value = b;

  final RxList<NewMessageModel> messageList = <NewMessageModel>[].obs;

  FocusNode focusNode = FocusNode();

  final Rx<UserData?> _senderuserData = UserData().obs;
  UserData? get senderuserData => _senderuserData.value;
  set senderuserData(UserData? userData) => _senderuserData.value = (userData);

  final Rx<GroupData?> _receiverUserData = Rx<GroupData?>(null);
  GroupData? get receiverUserData => _receiverUserData.value;
  set receiverUserData(GroupData? userData) {
    // print("receiverUserData updated: ${userData?.isOnline}");
    _receiverUserData.value = (userData);
  }

  final RxString _id = "".obs;
  String get id => _id.value;
  set id(String str) => _id.value = str;

  final RxString _fullname = "".obs;
  String get fullname => _fullname.value;
  set fullname(String str) => _fullname.value = str;

  final RxString _rootPath = "".obs;
  String get rootPath => _rootPath.value;
  set rootPath(String str) => _rootPath.value = str;

  final RxList<NewMessageModel> selectedMessages = <NewMessageModel>[].obs;

  bool get allMessagesHaveServerId =>
      selectedMessages.every((msg) => msg.messageId != null);

  bool get isOnlySenderMessages =>
      selectedMessages.every((msg) => msg.senderId == senderuserData?.userId);

  bool get hasAnyDeleted =>
      selectedMessages.any((msg) => msg.messageType == MessageType.deleted);

  bool get canDeleteForEveryone =>
      isOnlySenderMessages && !hasAnyDeleted && allMessagesHaveServerId;

  late Stream<List<NewMessageModel>> messageStream;
  late StreamSubscription<List<NewMessageModel>> messageSubscription;

  late StreamSubscription<GroupData?> receiverUserSubscription;
  Timer? typingTimer;

  ScrollController textScrollController = ScrollController();

  final Set<String> _sendingMessageIds = {};

  Map<int, double> itemHeights = {}; // messageId : height
  final ValueNotifier<String?> replyId = ValueNotifier(null);

  final itemScrollController = ItemScrollController();
  final itemPositionsListener = ItemPositionsListener.create();
  final Map<String, int> messageIdToIndex = {};

  final ValueNotifier<String?> highlightedMessageId = ValueNotifier(null);

  final RxBool _isInCurrentChat = true.obs;
  bool get isInCurrentChat => _isInCurrentChat.value;
  set isInCurrentChat(bool b) => _isInCurrentChat.value = b;

  final RxInt _currentOffset = 0.obs;
  int get currentOffset => _currentOffset.value;
  set currentOffset(int a) => _currentOffset.value = a;

  final RxInt _pageSize = 10.obs;
  int get pageSize => _pageSize.value;
  set pageSize(int a) => _pageSize.value = a;

  final RxBool _isPaginating = false.obs;
  bool get isPaginating => _isPaginating.value;
  set isPaginating(bool b) => _isPaginating.value = b;

  final RxBool _hasMoreMessages = true.obs;
  bool get hasMoreMessages => _hasMoreMessages.value;
  set hasMoreMessages(bool b) => _hasMoreMessages.value = b;

  final RxInt _groupId = 0.obs;
  int get groupId => _groupId.value;
  set groupId(int a) => _groupId.value = a;

  final RxBool _isCurrentUserRemoved = false.obs;
  bool get isCurrentUserRemoved => _isCurrentUserRemoved.value;
  set isCurrentUserRemoved(bool b) => _isCurrentUserRemoved.value = b;

  final RxString _groupMemberNames = "".obs;
  String get groupMemberNames => _groupMemberNames.value;
  set groupMemberNames(String b) => _groupMemberNames.value = b;

  final RxMap<int, String> senderNamesCache = <int, String>{}.obs;

  @override
  void onInit() async {
    super.onInit();
    FocusManager.instance.primaryFocus?.unfocus();

    SystemChannels.textInput.invokeMethod('TextInput.hide');

    WidgetsBinding.instance.addObserver(this);
    senderuserData = sharedPreferenceService.getUserData();

    GroupData? groupData = Get.arguments;
    if (groupData != null) {
      checkUserOnline(groupData);
      receiverUserData = groupData;
      groupId = groupData.group?.id ?? 0;
      bindReceiverUserStream(groupData.group?.id ?? 0);
      final groupDetails = await GroupsTable().getGroupById(groupId);
      checkIfCurrentUserRemoved(groupDetails);
      groupMemberNames = await getSortedGroupMemberNames(groupDetails?.users);
    }
    socketService.monitorGroupTyping(groupId.toString(), (typingUsers) {
      if (typingUsers.isNotEmpty) {
        _typingDisplayText.value = '${typingUsers.join(', ')} is typing...';
      } else {
        _typingDisplayText.value = '';
      }
    });

    getRootFolder();

    closeKeyboard();
    await loadInitialMessages();
    bindSocketEvents();
    monitorScrollPosition();
    isInCurrentChat = true;
    hasScrolledInitially.value = false;
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
    WidgetsBinding.instance.removeObserver(this);
    selectedMessages.clear();
    messageList.clear();
    // messageSubscription.cancel();
    receiverUserSubscription.cancel();
    scrollController.dispose();
    typingTimer?.cancel();
    _sendingMessageIds.clear();
    replyId.dispose();
    isInCurrentChat = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        print('💬 SingleChatController resumed.');
        if (connectivityService.isConnected.value &&
            socketService.isConnected) {
          checkUserOnline(receiverUserData);
        }

        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.paused:
        break;
      default:
    }
  }

  Future<void> scrollToOriginalMessage(int? repliedId) async {
    if (repliedId == null) return;

    final index = messageIdToIndex[repliedId.toString()];
    if (index != null) {
      itemScrollController.scrollTo(
        index: index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

      // Trigger highlight
      highlightedMessageId.value = repliedId.toString();

      // Clear highlight after some time
      Future.delayed(const Duration(seconds: 2), () {
        if (highlightedMessageId.value == repliedId.toString()) {
          highlightedMessageId.value = null;
        }
      });
    } else {
      print('Original message not currently visible');
      checkMessageInList(repliedId);
    }
  }

  void checkUserOnline(GroupData? user) async {
    if (user == null) return;
    var params = {"recipientId": user.group?.id};
    if (socketService.isConnected) {
      socketService.checkUserOnline(params);
    }
  }

  void handleDeletedMessage(NewMessageModel msg) {
    // You can still show a greyed-out bubble in the chat
    print("Message '${msg.message}' was deleted.");
    // Get.snackbar(
    //   "Original message deleted",
    //   "The message you're replying to has been deleted.",
    //   snackPosition: SnackPosition.BOTTOM,
    // );
    showAlertMessage("The message does not exit or lost.");
  }

  void handleMessageNotExist(int repliedId) {
    // Get.snackbar(
    //   "Message not found",
    //   "The message you're replying to does not exist in the database.",
    //   snackPosition: SnackPosition.BOTTOM,
    // );
    showAlertMessage("The message does not exit or lost.");
  }

  Future<void> checkMessageInList(int repliedId) async {
    int localOffset = currentOffset;
    bool messageFound = false;

    while (!messageFound) {
      final messages = await MessageTable().fetchGroupMessagesPaginated(
        receiverId: receiverUserData?.group?.id ?? 0,

        offset: localOffset,
        limit: pageSize,
      );

      if (messages.isEmpty) {
        // All pages scanned, message not found. Check if it existed and is deleted
        final deletedMsg = await MessageTable().fetchMessageById(repliedId);
        if (deletedMsg != null) {
          print("Message existed but was deleted.");
          handleDeletedMessage(deletedMsg);
        } else {
          print("Message never existed.");
          handleMessageNotExist(repliedId);
        }
        break;
      }

      // Only insert if message is in this page
      final index = messages.indexWhere((e) => e.messageId == repliedId);
      if (index != -1) {
        messageList.insertAll(0, messages);
        updateMessageIdToIndex();
        scrollToOriginalMessage(repliedId);
        messageFound = true;

        currentOffset = localOffset + messages.length;
      } else {
        // Don't insert, just go to next page
        localOffset += messages.length;
      }
    }
  }

  void updateMessageIdToIndex() {
    messageIdToIndex.clear();
    for (int i = 0; i < messageList.length; i++) {
      messageIdToIndex[messageList[i].messageId.toString()] = i;
    }
  }

  void monitorScrollPosition() {
    itemPositionsListener.itemPositions.addListener(() async {
      final positions = itemPositionsListener.itemPositions.value;

      if (positions.isNotEmpty) {
        final maxIndex = positions
            .map((e) => e.index)
            .reduce((a, b) => a > b ? a : b);
        final totalCount = messageList.length + (isReceiverTyping ? 1 : 0);

        // If the last visible index is less than the last item, show the button
        showScrollToBottom.value = maxIndex < totalCount - 1;
      }
    });
  }

  void scrollToBottom({bool animated = false}) {
    if (itemScrollController.isAttached) {
      final lastIndex = messageList.length - 1;
      if (animated) {
        itemScrollController.scrollTo(
          index: lastIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        itemScrollController.scrollTo(
          curve: Curves.easeInOut,

          index: lastIndex,
          duration: const Duration(milliseconds: 300),
        );
      }
    }
  }

  void checkIfCurrentUserRemoved(GroupData? groupData) {
    final currentUserId = senderuserData?.userId ?? 0;
    // print("CurrentUserId: $currentUserId");

    final matchingUser = groupData?.users?.firstWhere(
      (u) => u.userInfo?.userId == currentUserId,
      orElse: () => User(userInfo: null, userGroupInfo: null),
    );

    // print("Matched User: ${matchingUser?.toJson()}");

    final removed = matchingUser?.userGroupInfo?.isRemoved == true;
    // print("IsUserRemoved: $removed");

    isCurrentUserRemoved = removed;
    // // Optional: log all user IDs
    // print("All group user IDs:");
    // receiverUserData?.users?.forEach((u) {
    //   print("-> ${u.userInfo?.userId}");
    // });
  }

  Future<String> getSortedGroupMemberNames(List<User>? users) async {
    if (users == null) return '';

    // Step 1: Filter out removed users
    final activeUserIds = users
        .where((u) => u.userGroupInfo?.isRemoved != true)
        .map((u) => u.userInfo?.userId)
        .whereType<int>()
        .toList();

    // Step 2: Separate saved and unsaved contacts
    final savedNames = <String>[];
    final unsavedNumbers = <String>[];

    for (final userId in activeUserIds) {
      final contact = await contactsTable.getUserById(userId);
      final localName = contact?.localName?.trim();
      final phone = contact?.phoneNumber?.trim();

      if (localName != null && localName.isNotEmpty) {
        savedNames.add(localName);
      } else if (phone != null && phone.isNotEmpty) {
        unsavedNumbers.add(phone);
      }
    }

    // Step 3: Sort both lists alphabetically
    savedNames.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    unsavedNumbers.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    // Step 4: Combine both lists
    final allNames = [...savedNames, ...unsavedNumbers];

    return allNames.join(', ');
  }

  void bindReceiverUserStream(int userId) {
    receiverUserSubscription = getReceiverStream(userId).listen((user) {
      if (user != null) {
        receiverUserData = user;
        checkIfCurrentUserRemoved(receiverUserData);
      }
    });
  }

  Stream<GroupData?> getReceiverStream(int userId) async* {
    yield* Stream.periodic(const Duration(seconds: 1), (_) async {
      return await GroupsTable().getGroupById(userId);
    }).asyncMap((event) async => await event);
  }

  void bindSocketEvents() {
    ever(socketService.incomingMessage, (NewMessageModel? message) async {
      if (!isInCurrentChat) return;
      bool isFromCurrentChat(NewMessageModel msg) {
        return (msg.recipientId == receiverUserData?.group?.id);
      }

      if (message != null && isFromCurrentChat(message)) {
        messageList.add(message);
        final id = message.senderId ?? 0;
        if (!senderNamesCache.containsKey(id)) {
          await contactsTable.getUserById(id).then((user) {
            final name = user?.localName ?? user?.name;
            senderNamesCache[id] = name!;
          });
        }
        // Acknowledge seen if message is incoming and not already seen
        if (message.recipientId == receiverUserData?.group?.id &&
            socketService.isConnected &&
            (message.state == MessageState.sent ||
                message.state == MessageState.unsent ||
                message.state == MessageState.delivered) &&
            message.messageId != null) {
          // socketService.sendMessageSeen(message.messageId!);
          if (message.senderId != senderuserData?.userId &&
              message.state != MessageState.read) {
            socketService.sendMessageSeen(
              message.messageId!,
              // senderuserData!.userId.toString(),
            );
          }
        }
        // scrollToBottomIfNear();
      }
    });

    ever(socketService.deletedMessage, (DeletedMessageModel? del) {
      if (!isInCurrentChat) return;
      if (del == null) return;

      int index = messageList.indexWhere((m) => m.messageId == del.messageId);

      if (index != -1) {
        if (del.isDeleteFromEveryone) {
          final updated = messageList[index].copyWith(
            message: "This message was deleted",
            messageType: MessageType.deleted,
          );
          messageList[index] = updated;
        } else {
          messageList.removeAt(index);
        }
        messageList.refresh(); // Update UI
      }
    });

    ever(socketService.messageAcknowledgement, (MessageAckModel? ack) {
      if (!isInCurrentChat) return;
      if (ack == null) return;

      int index = messageList.indexWhere(
        (msg) =>
            msg.clientSystemMessageId == ack.clientSystemMessageId ||
            msg.messageId == ack.messageId,
      );

      if (index != -1) {
        if (ack.state == 1) {
          final updatedMessage = messageList[index].copyWith(
            state: MessageState.sent,
            messageId: ack.messageId,
            syncStatus: SyncStatus.synced,
          );
          messageList[index] = updatedMessage;
          messageList.refresh(); // Notify UI
        } else if (ack.state == 2) {
          final updatedMessage = messageList[index].copyWith(
            state: MessageState.delivered,
            messageId: ack.messageId,
            syncStatus: SyncStatus.synced,
          );
          messageList[index] = updatedMessage;
          messageList.refresh();
        } else if (ack.state == 3) {
          final updatedMessage = messageList[index].copyWith(
            state: MessageState.read,
            messageId: ack.messageId,
            syncStatus: SyncStatus.synced,
          );
          messageList[index] = updatedMessage;
          messageList.refresh();
        }
      }
    });
  }

  void scrollToTop({bool animated = false}) {
    if (itemScrollController.isAttached) {
      final firstIndex = pageSize - 5;
      if (animated) {
        itemScrollController.scrollTo(
          index: firstIndex,
          duration: const Duration(seconds: 1),
          curve: Curves.fastOutSlowIn,
        );
      } else {
        itemScrollController.scrollTo(
          index: firstIndex,
          duration: const Duration(seconds: 1),
          curve: Curves.fastOutSlowIn,
        );
      }
    }
  }

  Future<void> loadInitialMessages() async {
    currentOffset = 0;
    hasMoreMessages = true;
    messageList.clear();
    await loadMoreMessages();
  }

  Future<void> loadMoreMessages() async {
    if (isPaginating || !hasMoreMessages) return;

    isPaginating = true;
    final messages = await MessageTable().fetchGroupMessagesPaginated(
      receiverId: receiverUserData?.group?.id ?? 0,

      offset: currentOffset,
      limit: pageSize,
    );
    if (messages.isNotEmpty) {
      // Add message keys

      // if (currentOffset != messageList.length) {
      //   messageList.clear();
      // }
      // messageList.clear();
      messageList.insertAll(0, messages);

      currentOffset += messages.length;
      // ✅ Cache sender names for newly loaded messages
      for (var msg in messages) {
        final id = msg.senderId ?? 0;
        if (!senderNamesCache.containsKey(id)) {
          await contactsTable.getUserById(id).then((user) {
            final name = user?.localName ?? user?.name;
            senderNamesCache[id] = name!;
          });
        }
      }

      // ✅ Existing sync/seen logic...
      for (var i in messages) {
        if ((i.state == MessageState.sent ||
                i.state == MessageState.unsent ||
                i.state == MessageState.delivered) &&
            i.messageId != null) {
          if (receiverUserData!.group?.id == i.recipientId &&
              socketService.isConnected) {
            if (i.senderId != senderuserData?.userId &&
                i.state != MessageState.read) {
              socketService.sendMessageSeen(
                i.messageId!,
                // senderuserData!.userId.toString(),
              );
            }
          }
        } else if (senderuserData!.userId == i.senderId &&
            i.syncStatus == SyncStatus.pending &&
            i.messageId == null) {
          if (socketService.isConnected) {
            if (!_isAlreadyBeingSent(i.clientSystemMessageId.toString())) {
              socketService.sendMessageSync(i);
            }
          }
        } else if (senderuserData!.userId == i.senderId &&
            i.syncStatus == SyncStatus.pending &&
            i.messageId != null) {
          if (socketService.isConnected) {
            if (!_isAlreadyBeingSent(i.clientSystemMessageId.toString())) {
              socketService.sendMessageSync(i);
            }
          }
        }
      }
      scrollToTop();
    } else {
      hasMoreMessages = false;
    }
    isPaginating = false;
  }

  void _startLoadingTimer() {
    Timer(const Duration(seconds: 3), () {
      isLoading = false; // Stop loading after 3 seconds
    });
  }

  Future<void> getRootFolder() async {
    rootPath = await folderCreation.getRootFolderPath();
  }

  bool _isAlreadyBeingSent(String clientSystemMessageId) {
    return _sendingMessageIds.contains(clientSystemMessageId);
  }

  Future<void> sendTextMessage() async {
    final message = messageController.text.trim();
    if (message.isEmpty) return;
    if (message.length > 800) {
      showAlertMessage("This message is too long, Please shorter the message.");
      return;
    }

    final clientSystemMessageId = const Uuid().v1();
    final timeSent = DateTime.now();

    final newMessage = NewMessageModel(
      isGroupMessage: true,
      senderId: senderuserData?.userId,
      recipientId: receiverUserData?.group?.id,
      message: encryptionService.encryptText(message),
      messageSentFromDeviceTime: timeSent.toString(),
      clientSystemMessageId: clientSystemMessageId,
      state: MessageState.unsent,
      syncStatus: SyncStatus.pending,
      createdAt: timeSent.toString(),
      senderPhoneNumber: senderuserData?.phoneNumber,
      messageType: MessageType.text,
      isForwarded: false,
      forwardedMessageId: 0,
      showForwarded: false,
      isRepliedMessage: messageReply == null ? false : messageReply.isReplied,
      messageRepliedOnId: messageReply == null ? 0 : messageReply.messageId,
      messageRepliedOn: messageReply == null ? '' : messageReply.message,
      messageRepliedOnType: messageReply == null
          ? MessageType.text
          : messageReply.messageType,
      messageRepliedOnAssetThumbnail: messageReply == null
          ? ''
          : messageReply.assetsThumbnail,
      messageRepliedOnAssetServerName: messageReply == null
          ? ''
          : messageReply.message,
      isAsset: false,
      assetOriginalName: "",
      assetServerName: "",
      assetUrl: "",
      messageRepliedUserId: messageReply.message == null
          ? 0
          : messageReply.isMe == true
          ? senderuserData?.userId
          : messageReply.recipientUserId,
      assetThumbnail: "",
    );
    print("Message All details Request: ${newMessage.toMap()}");

    messageList.add(newMessage);
    await MessageTable().insertMessage(newMessage).then((onValue) {
      Future.delayed(Durations.medium4);
      if (socketService.isConnected) {
        _sendingMessageIds.add(clientSystemMessageId);
        // encryptionService.encryptText();

        socketService.sendMessage(newMessage);
      } else {
        socketService.saveChatContacts(newMessage);
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 100), () {
          scrollToBottom(animated: true);
        });
      });
    });

    messageController.clear();
    var receiverUserId = receiverUserData?.group?.id.toString() ?? '';
    socketService.emitGroupTypingStatus(
      recipientId: receiverUserId,
      isTyping: false,
    );
    typingTimer?.cancel();
    await cancelReply();
  }

  void onTextChanged(String text) {
    final receiverId = receiverUserData?.group?.id.toString() ?? "";

    if (text.isNotEmpty) {
      isShowSendButton = true;

      // Emit isTyping: true
      socketService.emitGroupTypingStatus(
        recipientId: receiverId,
        isTyping: true,
      );

      // Debounce logic for isTyping: false
      typingTimer?.cancel();
      typingTimer = Timer(const Duration(seconds: 2), () {
        socketService.emitGroupTypingStatus(
          recipientId: receiverId,
          isTyping: false,
        );
      });
    } else {
      isShowSendButton = false;

      // Immediately emit false if field is cleared
      socketService.emitGroupTypingStatus(
        recipientId: receiverId,
        isTyping: false,
      );
      typingTimer?.cancel();
    }

    // messageController.text = text;
  }

  void toggleMessageSelection(NewMessageModel message) {
    if (selectedMessages.contains(message)) {
      selectedMessages.remove(message);
      if (kDebugMode) {
        print("Message removed from list:------> ${message.toMap()}");
      }
    } else {
      selectedMessages.add(message);
      if (kDebugMode) {
        print("Message added to list:------> ${message.toMap()}");
      }
    }
    updateForwardAvailability();
    selectedMessages.refresh();
  }

  void clearSelectedMessages() {
    selectedMessages.clear();
  }

  Future<void> deleteMessages({required bool deleteForEveryone}) async {
    if (selectedMessages.isEmpty) return;

    final isOnline = connectivityService.isConnected.value;

    for (var message in selectedMessages) {
      final hasMessageId = message.messageId != null;

      final isLast = hasMessageId
          ? await MessageTable().isLastMessage(
              messageId: message.messageId!,
              senderId: message.senderId!,
              receiverId: message.recipientId!,
            )
          : false;

      if (!hasMessageId && message.clientSystemMessageId != null) {
        await MessageTable().deleteMessageByClientSystemMessageId(
          message.clientSystemMessageId.toString(),
        );
        // 🟢 Remove from message list (offline messages)
        messageList.removeWhere(
          (m) => m.clientSystemMessageId == message.clientSystemMessageId,
        );
        continue;
      }

      if (hasMessageId) {
        if (deleteForEveryone) {
          // 🔵 Emit socket event or mark for deletion
          if (isOnline) {
            socketService.emitMessageDelete(
              messageId: message.messageId!,
              isDeleteFromEveryOne: true,
            );
          } else {
            await MessageTable().markForDeletion(
              messageId: message.messageId!,
              isDeleteFromEveryone: true,
            );
          }

          // 🔵 Update local DB
          await MessageTable().updateMessageContent(
            messageId: message.messageId!,
            newText: "This message was deleted",
            newType: MessageType.deleted,
          );

          // 🟢 Update messageList manually
          final index = messageList.indexWhere(
            (m) => m.messageId == message.messageId,
          );
          if (index != -1) {
            messageList[index] = messageList[index].copyWith(
              message: "This message was deleted",
              messageType: MessageType.deleted,
            );
          }

          if (isLast) {
            await ChatConectTable().updateContact(
              lastMessageId: 0,
              uid: message.recipientId.toString(),
              isGroup: 1,
              lastMessage: "This message was deleted",
              timeSent: message.messageSentFromDeviceTime,
            );
          }
        } else {
          // 🟣 Delete for me only
          await MessageTable().deleteMessage(message.messageId!);
          // 🟣 Remove from messageList
          messageList.removeWhere((m) => m.messageId == message.messageId);
          if (isOnline) {
            if (message.senderId != senderuserData?.userId) {
              // socketService.emitMessageDelete(
              //   messageId: message.messageId!,
              //   isDeleteFromEveryOne: false,
              // );
            }
          } else {
            if (message.senderId != senderuserData?.userId) {
              // await MessageTable().markForDeletion(
              //   messageId: message.messageId!,
              //   isDeleteFromEveryone: false,
              // );
            }
          }
          if (isLast) {
            final newLast = await MessageTable().getLatestMessageForUser(
              message.recipientId!,
              message.senderId!,
            );
            if (newLast != null) {
              final isFromMe = newLast.senderId == senderuserData?.userId;
              // final contactUid = isFromMe
              //     ? newLast.recipientId.toString()
              //     : newLast.senderId.toString();
              await chatConectTable.updateContact(
                lastMessageId: newLast.messageId,
                uid: newLast.recipientId.toString(),
                isGroup: 1,
                lastMessage: newLast.message,
                timeSent: newLast.messageSentFromDeviceTime,
              );
            } else {
              // If no new message, still determine correct uid for contact
              final isFromMe = message.senderId == senderuserData?.userId;
              // final contactUid = isFromMe
              //     ? message.recipientId.toString()
              //     : message.senderId.toString();
              // Optional: reset chat contact if all messages deleted
              await chatConectTable.updateContact(
                lastMessageId: 0,
                uid: message.recipientId.toString(),
                isGroup: 1,
                lastMessage: '',
                timeSent: '',
              );
            }
          }
        }
      }
    }
    selectedMessages.clear();
    messageList.refresh();
  }

  Future<void> cancelReply() async {
    messageReply = MessageReply(isMe: false, message: null, isReplied: false);
  }

  final RxBool _canForward = false.obs;
  bool get canForward => _canForward.value;
  set canForward(bool b) => _canForward.value = b;

  void updateForwardAvailability() {
    final selected = selectedMessages;

    if (selected.isEmpty) {
      canForward = false;
      return;
    }

    // ❗ If even one selected message is deleted, disable forward
    final hasDeleted = selected.any(
      (msg) => msg.messageType == MessageType.deleted,
    );

    if (hasDeleted) {
      canForward = false;
      return;
    }

    // Optional: limit total forwardable messages
    if (selected.length > 30) {
      canForward = false;
      return;
    }

    // Optional: limit media messages
    final mediaMessages = selected.where(
      (msg) =>
          msg.messageType == MessageType.image ||
          msg.messageType == MessageType.video ||
          msg.messageType == MessageType.audio ||
          msg.messageType == MessageType.document ||
          msg.messageType == MessageType.gif,
    );

    if (mediaMessages.length > 5) {
      canForward = false;
      return;
    }

    canForward = true;
  }

  void prepareToForward() {
    final messagesToForward = selectedMessages.toList();
    clearSelectedMessages();
    Get.toNamed(Routes.FORWARD_MESSAGES, arguments: messagesToForward);
    // Get.to(() => SelectUsersToForwardView(messages: messagesToForward));
  }

  Future<List<File>> pickImageAndVideo() async {
    Completer<List<File>> completer = Completer<List<File>>();
    await showMediaPickerBottomSheet(
      onSendFiles: (img, fileType) {
        completer.complete(img);
      },
    );

    return completer.future;
  }

  Future<UploadFileModel?> uploadFileToServer(File imageFile) async {
    try {
      final response = await profileRepository.uploadMessageFiles(
        imageFile,
        onProgress: (sent, total) {
          final percent = (sent / total) * 100;
          print("📤 Upload progress: ${percent.toStringAsFixed(0)}%");
        },
      );

      if (response?.statusCode == 200) {
        final result = UploadFileModel.fromJson(response?.data);
        if (result.status == true) {
          print("response of upload Files:----> ${result.data?.toJson()}");
          return result;
        } else {
          // showAlertMessage('Upload failed: Invalid response status.');
        }
      } else {
        // showAlertMessage('Failed to upload file: ${response?.statusCode}');
      }
    } catch (e) {
      // showAlertMessage('Error uploading file: ${e.toString()}');
    }

    return null; // return empty result on error
  }

  Future<void> sendFileMessage({
    required File file,
    required MessageType messageEnum,
  }) async {
    final clientSystemMessageId = const Uuid().v1();
    final timeSent = DateTime.now();
    final fileType = messageEnum.value.split('.').last;
    final fileExtension = file.toString().split('.').last.replaceAll("'", "");
    try {
      // Save file locally
      final fileName =
          "genchat_message_${senderuserData!.userId.toString()}_${DateTime.now().millisecondsSinceEpoch}";

      Map<String, File?> f = await compressFiles(file, fileExtension);

      final localFilePath = await saveFileLocally(
        f.values.first!,
        fileType,
        f.keys.first,
        fileName,
      );
      final String? assetThumnail = f.keys.first == "mp4"
          ? await getThumbnail(File(localFilePath))
          : "";

      final fileWithExtensions = "$fileName.${f.keys.first}";

      final fileData = await uploadFileToServer(f.values.first!);
      final newMessage = NewMessageModel(
        senderId: senderuserData?.userId,
        recipientId: receiverUserData?.group?.id,
        message: '',
        messageSentFromDeviceTime: timeSent.toString(),
        clientSystemMessageId: clientSystemMessageId,
        state: MessageState.unsent,
        syncStatus: SyncStatus.pending,
        createdAt: timeSent.toString(),
        senderPhoneNumber: senderuserData?.phoneNumber,
        messageType: messageEnum,
        isForwarded: false,
        isGroupMessage: true,
        forwardedMessageId: 0,
        showForwarded: false,
        isRepliedMessage: messageReply == null ? false : messageReply.isReplied,
        messageRepliedOnId: messageReply == null ? 0 : messageReply.messageId,
        messageRepliedOn: messageReply == null ? '' : messageReply.message,
        messageRepliedOnType: messageReply == null
            ? MessageType.text
            : messageReply.messageType,
        messageRepliedOnAssetServerName: messageReply == null
            ? ''
            : messageReply.message,
        messageRepliedOnAssetThumbnail: messageReply == null
            ? ''
            : messageReply.assetsThumbnail,
        isAsset: true,
        assetThumbnail: assetThumnail ?? "",
        assetOriginalName: fileData == null ? "" : fileData.data?.originalName,
        assetServerName: fileWithExtensions,
        assetUrl: fileData == null ? "" : fileData.data?.url,
        messageRepliedUserId: messageReply.message == null
            ? 0
            : messageReply.isMe == true
            ? senderuserData?.userId
            : receiverUserData?.group?.id,
      );
      print("Message All details Request: ${newMessage.toMap()}");
      await MessageTable().insertMessage(newMessage);
      messageList.add(newMessage);

      if (fileData?.statusCode == 200 && fileData?.status == true) {
        if (socketService.isConnected) {
          socketService.sendMessage(newMessage);
        }
      } else {
        socketService.saveChatContacts(newMessage);
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error sending file message: $e");
      }
    }
  }

  void selectFile(String fileType) async {
    if (fileType == MessageType.image.value ||
        fileType == MessageType.video.value) {
      final selectedFiles = await pickImageAndVideo();
      for (File file in selectedFiles) {
        print("Yes Getting back all files:---> $file");
        await sendFileMessage(file: file, messageEnum: getMessageType(file));
        cancelReply();
      }
    } else if (fileType == MessageType.audio.value) {
      //  final selectedFile = await pickAudio();
    } else if (fileType == MessageType.document.value) {
      await pickAndSendDocuments((selectedFiles) async {
        for (File file in selectedFiles) {
          print("Yes Getting back all files:---> $file");
          await sendFileMessage(file: file, messageEnum: getMessageType(file));
        }
      });
      cancelReply();
    }
  }

  Future<String> saveFileLocally(
    File file,
    String fileType,
    String fileExtension,
    String fileName,
  ) async {
    final subFolderName = fileType.toTitleCase;
    final name = "$fileName.$fileExtension";
    //     "genchat_message_${senderuserData!.userId.toString()}_${DateTime.now().millisecondsSinceEpoch}.$fileExtension";
    final filePath = await folderCreation.saveFileFromFile(
      sourceFile: file,
      fileName: name,
      subFolder: subFolderName,
    );
    // print("FileName for saving locally:----------------> $fileName");
    // print("FilePath for saving locally:----------------> $filePath");
    return filePath;
  }

  Future<File?> pickImage() async {
    Completer<File?> completer = Completer<File?>();
    showImagePicker(
      onGetImage: (img) {
        if (img != null) {
          // sendFileMessage(
          //   file: img,
          //   messageEnum: MessageEnum.image,
          // );
          completer.complete(img);
        } else {
          completer.complete(null);
        }
      },
    );
    return completer.future;
  }

  void selectGif() async {
    TenorResult? gif = await pickGIF(Get.context!);
    if (gif != null) {
      print(
        "gif URL:---->  ${gif.media.tinyGif?.url ?? gif.media.tinyGifTransparent?.url ?? gif.url}",
      );
      final fileName =
          "genchat_gif_${senderuserData!.userId.toString()}_${DateTime.now().millisecondsSinceEpoch}.gif";
      downloadFile(
        MessageType.gif,
        fileName,
        gif.media.tinyGif?.url ?? gif.media.tinyGifTransparent?.url ?? gif.url,
      );
      sendGIFMessage(
        gifUrl:
            gif.media.tinyGif?.url ??
            gif.media.tinyGifTransparent?.url ??
            gif.url,
        messageEnum: MessageType.gif,
        fileName: fileName,
      );
      cancelReply();
    }
  }

  Future<void> retryPendingMediaFile(NewMessageModel messages) async {
    if (messages.isRetrying?.value == true) return;
    try {
      messages.isRetrying?.value = true;
      final rootPaths = rootPath;
      final messageType = messages.messageType?.value;
      final fileType = messageType?.toTitleCase;
      final fileName = messages.assetServerName;
      final file = File("$rootPaths$fileType/$fileName");
      print("Full file name with path: $file");
      update();
      final result = await uploadFileToServer(file);
      if (result != null) {
        final updatedMessage = messages.copyWith(
          assetOriginalName: result.data?.originalName,
          assetServerName: fileName,
          assetUrl: result.data?.url,
        );
        if (socketService.isConnected) {
          print("updatedMessage:----> ${updatedMessage.toMap()}");
          await MessageTable().updateMessageByClientId(updatedMessage);
          socketService.sendMessageSync(updatedMessage);
        }
      }
      messages.isRetrying?.value = false;
    } finally {
      // messages.isRetrying?.value = false;
    }
  }

  Future<void> sendGIFMessage({
    required String gifUrl,
    required MessageType messageEnum,
    required String fileName,
  }) async {
    final clientSystemMessageId = const Uuid().v1();
    final timeSent = DateTime.now();
    try {
      // Save file locally

      final newMessage = NewMessageModel(
        senderId: senderuserData?.userId,
        recipientId: receiverUserData?.group!.id,
        message: '',
        messageSentFromDeviceTime: timeSent.toString(),
        clientSystemMessageId: clientSystemMessageId,
        state: MessageState.unsent,
        syncStatus: SyncStatus.pending,
        createdAt: timeSent.toString(),
        senderPhoneNumber: senderuserData?.phoneNumber,
        messageType: messageEnum,
        isForwarded: false,
        isGroupMessage: true,
        forwardedMessageId: 0,
        showForwarded: false,
        isRepliedMessage: messageReply == null ? false : messageReply.isReplied,
        messageRepliedOnId: messageReply == null ? 0 : messageReply.messageId,
        messageRepliedOn: messageReply == null ? '' : messageReply.message,
        messageRepliedOnType: messageReply == null
            ? MessageType.text
            : messageReply.messageType,
        messageRepliedOnAssetServerName: messageReply == null
            ? ''
            : messageReply.message,
        messageRepliedOnAssetThumbnail: messageReply == null
            ? ''
            : messageReply.assetsThumbnail,
        isAsset: true,
        assetThumbnail: fileName,
        assetOriginalName: fileName,
        assetServerName: fileName,
        assetUrl: gifUrl,
        messageRepliedUserId: messageReply.message == null
            ? 0
            : messageReply.isMe == true
            ? senderuserData?.userId
            : receiverUserData?.group!.id,
      );
      print("Message All details Request: ${newMessage.toMap()}");
      await MessageTable().insertMessage(newMessage);
      messageList.add(newMessage);

      if (socketService.isConnected) {
        socketService.sendMessage(newMessage);
      } else {
        socketService.saveChatContacts(newMessage);
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error sending file message: $e");
      }
    }
  }

  void toggleEmojiKeyboardContainer() {
    if (isShowEmojiContainer) {
      showKeyboard();
      hideEmojiContainer();
    } else {
      hideKeyboard();
      showEmojiContainer();
    }
  }

  void onMessageSwipe({
    required String message,
    required bool isMe,
    required MessageType messageType,
    required bool isReplied,
    required int messageId,
    required String senderName,
    required int recipientUserId,
    required String assetsThumbnail,
  }) {
    messageReply = MessageReply(
      messageId: messageId,
      message: message,
      isMe: isMe,
      messageType: messageType,
      isReplied: isReplied,
      senderName: senderName,
      recipientUserId: recipientUserId,
      assetsThumbnail: assetsThumbnail,
    );
  }

  void showKeyboard() => focusNode.requestFocus();
  void hideKeyboard() => focusNode.unfocus();

  void hideEmojiContainer() {
    isShowEmojiContainer = false;
  }

  void showEmojiContainer() {
    isShowEmojiContainer = true;
  }

  Future<void> deleteTextMessage() async {
    MessageTable().deleteMessageText(
      messageType: "text",
      receiverId: receiverUserData!.group?.id,
      senderId: senderuserData?.userId,
    );

    //  'deleted'
    MessageTable().deleteMessageText(
      messageType: 'deleted',
      receiverId: receiverUserData!.group?.id,
      senderId: senderuserData?.userId,
    );

    await chatConectTable.updateContact(
      uid: receiverUserData!.group!.id.toString(),
      isGroup: 1,
      lastMessage: "",
      timeSent: "",
    );
  }

  Future<void> deleteMedia() async {
    await folderCreation.clearMediaFiles();
  }

  String getFilePath(MessageType type, String fileName) {
    return '$rootPath${getFolderName(type)}/$fileName';
  }

  String getFolderName(MessageType type) {
    switch (type) {
      case MessageType.image:
        return "Image";
      case MessageType.video:
        return "Video";
      case MessageType.document:
        return "Document";
      case MessageType.audio:
        return "Audio";
      case MessageType.gif:
        return "GIFs";
      default:
        return "Unknown";
    }
  }

  RxMap<String, bool> isDownloading = <String, bool>{}.obs;
  RxMap<String, bool> isDownloaded = <String, bool>{}.obs;
  RxMap<String, int> downloadedBytes = <String, int>{}.obs;
  RxMap<String, int> totalBytes = <String, int>{}.obs;

  Future<void> checkIfFileExists(MessageType type, String fileName) async {
    final path = getFilePath(type, fileName);
    final file = File(path);
    final exists = await file.exists();
    final size = exists ? await file.length() : 0;

    if (exists && size > 0) {
      isDownloaded[fileName] = true;
    } else {
      if (exists) await file.delete(); // delete corrupt
      isDownloaded[fileName] = false;
    }
  }

  Future<void> downloadFile(
    MessageType type,
    String fileName,
    String url,
  ) async {
    if (isDownloading[fileName] == true || isDownloaded[fileName] == true)
      return;

    isDownloading[fileName] = true;
    downloadedBytes[fileName] = 0;
    totalBytes[fileName] = 0;
    try {
      final filePath = await FolderCreation().checkAndHandleFileFromGroup(
        fileUrl: url,
        fileName: fileName,
        subFolderName: getFolderName(type),
        messageType: type.value,
        onReceiveProgress: (received, total) {
          downloadedBytes[fileName] = received;
          totalBytes[fileName] = total;
        },
        onCancel: () {
          isDownloading[fileName] = false;
          downloadedBytes[fileName] = 0;
          totalBytes[fileName] = 0;
        },
      );
      if (filePath != null && File(filePath).existsSync()) {
        if (type == MessageType.video) {
          await getThumbnail(File(filePath.toString()));

          // MessageTable().updateMessageForAsset(
          //     assetPath: assetName.toString(), fileName: fileName);
          Future.delayed(const Duration(seconds: 1));
        }
        isDownloaded[fileName] = true;
      }
    } catch (e) {
      showAlertMessage("Download failed: $e");
    } finally {
      isDownloading[fileName] = false;
      activeDownloads.remove(fileName);
    }
  }

  Map<String, StreamSubscription<List<int>>> activeDownloads = {};
  void cancelDownload(MessageType type, String fileName) {
    activeDownloads[fileName]?.cancel(); // force cancel
    isDownloading[fileName] = false;
    downloadedBytes[fileName] = 0;
    totalBytes[fileName] = 0;
    // Also ensure partial file (if any) is deleted
    final path = getFilePath(type, fileName);
    final file = File(path);
    if (file.existsSync()) {
      file.deleteSync(); // delete partial/corrupt file
    }
    activeDownloads.remove(fileName);
  }
}
