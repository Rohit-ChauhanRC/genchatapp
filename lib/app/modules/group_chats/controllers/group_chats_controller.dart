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
import 'package:genchatapp/app/data/models/new_models/response_model/verify_otp_response_model.dart';
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
    }
    socketService.monitorGroupTyping(
      groupId.toString(),
          (typingUsers) {
        if (typingUsers.isNotEmpty) {
          _typingDisplayText.value = '${typingUsers.join(', ')} is typing...';
        } else {
          _typingDisplayText.value = '';
        }
      },
    );

    // print(
    //     "reciverName:----> ${receiverUserData?.localName}\nreceiverUserId:----> ${receiverUserData?.userId}");
    // fullname = Get.arguments[1];
    getRootFolder();

    closeKeyboard();
    await loadInitialMessages();
    bindSocketEvents();
    monitorScrollPosition();
    monitorScrollPosition();
    isInCurrentChat = true;
    // scrollController.addListener(_scrollListener);
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
        itemScrollController.jumpTo(index: lastIndex);
      }
    }
  }

  void bindReceiverUserStream(int userId) {
    receiverUserSubscription = getReceiverStream(userId).listen((user) {
      if (user != null) {
        receiverUserData = user;
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
        if (message.senderId == receiverUserData?.group?.id &&
            socketService.isConnected &&
            (message.state == MessageState.sent ||
                message.state == MessageState.unsent ||
                message.state == MessageState.delivered) &&
            message.messageId != null) {
          socketService.sendMessageSeen(message.messageId!);
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
          if (receiverUserData!.group?.id == i.senderId &&
              socketService.isConnected) {
            socketService.sendMessageSeen(i.messageId!);
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
            if (message.senderId != receiverUserData?.group?.id) {
              socketService.emitMessageDelete(
                messageId: message.messageId!,
                isDeleteFromEveryOne: false,
              );
            }
          } else {
            if (message.senderId != receiverUserData?.group?.id) {
              await MessageTable().markForDeletion(
                messageId: message.messageId!,
                isDeleteFromEveryone: false,
              );
            }
          }
          if (isLast) {
            final newLast = await MessageTable().getLatestMessageForUser(
              message.recipientId!,
              message.senderId!,
            );
            if (newLast != null) {
              final isFromMe = newLast.senderId == senderuserData?.userId;
              final contactUid = isFromMe
                  ? newLast.recipientId.toString()
                  : newLast.senderId.toString();
              await chatConectTable.updateContact(
                lastMessageId: newLast.messageId,
                uid: contactUid,
                isGroup: 1,
                lastMessage: newLast.message,
                timeSent: newLast.messageSentFromDeviceTime,
              );
            } else {
              // If no new message, still determine correct uid for contact
              final isFromMe = message.senderId == senderuserData?.userId;
              final contactUid = isFromMe
                  ? message.recipientId.toString()
                  : message.senderId.toString();
              // Optional: reset chat contact if all messages deleted
              await chatConectTable.updateContact(
                lastMessageId: 0,
                uid: contactUid,
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

  void selectFile(String fileType) async {
    File? selectedFile;

    if (fileType == MessageType.image.value) {
      selectedFile = await pickImage();
    } else if (fileType == MessageType.video.value) {
      // selectedFile = await pickVideo();
    } else if (fileType == MessageType.audio.value) {
      // selectedFile = await pickAudio();
    } else if (fileType == MessageType.document.value) {
      // selectedFile = await pickDocument();
    }

    if (selectedFile != null) {
      // sendFileMessage(file: selectedFile, messageEnum: fileType.toEnum());
    }
  }

  Future<String> saveFileLocally(
    File file,
    String fileType,
    String fileExtension,
  ) async {
    final subFolderName = fileType.toTitleCase;
    final fileName =
        "GENCHAT_$fileType-${senderuserData!.userId.toString()}-${DateTime.now().millisecondsSinceEpoch}.$fileExtension";
    final filePath = await folderCreation.saveFileFromFile(
      sourceFile: file,
      fileName: fileName,
      subFolder: subFolderName,
    );
    // print("FileName for saving locally:----------------> $fileName");
    // print("FilePath for saving locally:----------------> $filePath");
    return '$subFolderName/$fileName';
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
  }) {
    messageReply = MessageReply(
      messageId: messageId,
      message: message,
      isMe: isMe,
      messageType: messageType,
      isReplied: isReplied,
      senderName: senderName,
      recipientUserId:recipientUserId,
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
