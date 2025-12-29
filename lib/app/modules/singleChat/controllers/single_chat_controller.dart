import 'dart:async';
import 'dart:io';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
// import 'package:flutter_contacts_service/flutter_contacts_service.dart';
import 'package:genchatapp/app/config/services/connectivity_service.dart';
import 'package:genchatapp/app/config/services/encryption_service.dart';
import 'package:genchatapp/app/constants/message_enum.dart';
import 'package:genchatapp/app/data/local_database/chatconnect_table.dart';
import 'package:genchatapp/app/data/models/chat_conntact_model.dart';
import 'package:genchatapp/app/data/models/message_reply.dart';
import 'package:genchatapp/app/data/models/new_models/response_model/block_user_model.dart';
import 'package:genchatapp/app/data/models/new_models/response_model/contact_response_model.dart';
import 'package:genchatapp/app/data/models/new_models/response_model/new_message_model.dart';
import 'package:genchatapp/app/data/models/new_models/response_model/upload_file_model.dart';
import 'package:genchatapp/app/data/models/new_models/response_model/verify_otp_response_model.dart';
import 'package:genchatapp/app/data/repositories/chat/chat_repository.dart';
import 'package:genchatapp/app/data/repositories/profile/profile_repository.dart';
import 'package:genchatapp/app/data/repositories/select_contacts/select_contact_repository.dart';
import 'package:genchatapp/app/modules/Single_Profile/views/single_profile.dart';
import 'package:genchatapp/app/modules/chats/controllers/chats_controller.dart';
import 'package:genchatapp/app/modules/select_contacts/controllers/select_contacts_controller.dart';
import 'package:genchatapp/app/routes/app_pages.dart';
import 'package:genchatapp/app/services/shared_preference_service.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:gif/gif.dart';

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:tenor_flutter/tenor_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../config/services/filePickerService.dart';
import '../../../config/services/folder_creation.dart';
import '../../../config/services/socket_service.dart';
import '../../../constants/constants.dart';
import '../../../data/local_database/contacts_table.dart';
import '../../../data/local_database/message_table.dart';
import '../../../data/models/new_models/response_model/message_ack_model.dart';
import '../../../data/repositories/status/status_repository.dart';
import '../../../utils/DocumentPickerScreen.dart';
import '../../../utils/DocumentViewer.dart';
import '../../../utils/alert_popup_utils.dart';
import '../../../utils/utils.dart';
import 'package:audio_waveforms/audio_waveforms.dart';

import '../../Documents/View/DocumentsScreen.dart';
import '../../Documents/bindings/documentsBinding.dart';
import '../mediaPickerFiles/media_preview_screen.dart';
import '../widgets/image_preview.dart';

class SingleChatController extends GetxController
    with WidgetsBindingObserver, GetSingleTickerProviderStateMixin {
  //

  final connectivityService = Get.find<ConnectivityService>();
  final sharedPreferenceService = Get.find<SharedPreferenceService>();
  final FolderCreation folderCreation = Get.find<FolderCreation>();
  final ContactsTable contactsTable = ContactsTable();
  final socketService = Get.find<SocketService>();

  final ProfileRepository profileRepository = Get.find<ProfileRepository>();

  final ChatRepository chatRepository = Get.put<ChatRepository>(
    ChatRepository(apiClient: Get.find()),
  );

  final ChatConectTable chatConectTable = ChatConectTable();

  final EncryptionService encryptionService = Get.find();

  final selectedContactController = Get.find<SelectContactsController>();

  // final ChatsController chatsController = Get.find();

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

  // final RxBool _isRecording = false.obs;
  // bool get isRecording => _isRecording.value;
  // set isRecording(bool b) => _isRecording.value = b;

  final RxBool _isPause = false.obs;

  bool get isPause => _isPause.value;

  set isPause(bool b) => _isPause.value = b;

  final RxBool _isRecorderInit = false.obs;

  bool get isRecorderInit => _isRecorderInit.value;

  set isRecorderInit(bool b) => _isRecorderInit.value = b;

  final RxBool _isReceiverTyping = false.obs;

  bool get isReceiverTyping => _isReceiverTyping.value;

  set isReceiverTyping(bool b) => _isReceiverTyping.value = b;

  final RxBool _isLoading = true.obs;

  bool get isLoading => _isLoading.value;

  set isLoading(bool b) => _isLoading.value = b;

  // blocked
  final RxBool blocked = true.obs;

  // bool get blocked => _blocked.value;
  // set blocked(bool b) => _blocked.value = b;

  // blockedByMe

  final RxnInt blockedByMe = RxnInt();

  // int get blockedByMe => _blockedByMe.value;
  // set blockedByMe(int b) => _blockedByMe.value = b;

  final RxList<NewMessageModel> messageList = <NewMessageModel>[].obs;

  FocusNode focusNode = FocusNode();

  final Rx<UserData?> _senderuserData = UserData().obs;

  UserData? get senderuserData => _senderuserData.value;

  set senderuserData(UserData? userData) => _senderuserData.value = (userData);

  final Rx<UserList?> _receiverUserData = Rx<UserList?>(null);

  UserList? get receiverUserData => _receiverUserData.value;

  set receiverUserData(UserList? userData) {
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

  late StreamSubscription<UserList?> receiverUserSubscription;
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

  // late AnimationController animationController;
  late GifController gifController;

  final RecorderController recorderController = RecorderController();

  final PlayerController playerController = PlayerController();

  RxDouble audioDuration = 0.0.obs; // Store the audio duration in seconds

  RxBool isRecording = false.obs;
  RxBool isPreviewing = false.obs;
  RxString recordedPath = ''.obs;
  RxBool playAudio = false.obs;

  RxInt durationInSeconds = 0.obs;
  Timer? timer;

  Rx<Duration> currentDuration = Duration.zero.obs;
  Rx<Duration> totalDuration = Duration.zero.obs;
  Rx<String> audioTime = "".obs;
  RxDouble percent = 0.0.obs;

  final IContactRepository contactRepository = Get.find<IContactRepository>();

  RxBool userExist = false.obs;

  @override
  void onInit() async {
    super.onInit();

    FocusManager.instance.primaryFocus?.unfocus();

    SystemChannels.textInput.invokeMethod('TextInput.hide');

    WidgetsBinding.instance.addObserver(this);

    gifController = GifController(vsync: this);

    senderuserData = sharedPreferenceService.getUserData();

    UserList? user = Get.arguments;
    if (user != null) {
      checkUserOnline(user);
      receiverUserData = user;
      bindReceiverUserStream(user.userId ?? 0);
    }

    await findUserBlock();

    // animationController = AnimationController(
    //   vsync: this,
    //   duration: const Duration(seconds: 1),
    // );
    socketService.monitorReceiverTyping(receiverUserData!.userId.toString(), (
      isTyping,
    ) {
      if (blocked.value == false) {
        _isReceiverTyping.value = isTyping;
      }
    });

    // print(
    //     "reciverName:----> ${receiverUserData?.localName}\nreceiverUserId:----> ${receiverUserData?.userId}");
    // fullname = Get.arguments[1];
    getRootFolder();

    closeKeyboard();
    // _startLoadingTimer();
    // bindMessageStream();
    await loadInitialMessages();
    bindSocketEvents();
    monitorScrollPosition();
    isInCurrentChat = true;
    // scrollController.addListener(_scrollListener);
    hasScrolledInitially.value = false;
    await clearFilePickerCache();

    await initRecorder();
    await checkUserExistOrNot();
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

    gifController.dispose();

    // recorderController.checkPermission();
    recorderController.dispose();

    // animationController.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        print('💬 SingleChatController resumed.');
        if (connectivityService.isConnected.value) {
          socketService.runWhenConnected(() {
            checkUserOnline(receiverUserData);
            findUserBlock();
          });
        }

        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.paused:
        break;
      default:
    }
  }

  // user/block-contact
  //   {
  //     "blockContactUserId": 2,
  //     "isBlock":false
  // }
  // void openUserProfile() {
  //   if (receiverUserData == null) return;
  //   Get.to(() => SingleUserProfileView(user: receiverUserData!));
  // }
  void openUserProfile() {
    if (receiverUserData == null) return;
    Get.to(() => SingleUserProfileView(user: receiverUserData!));
  }

  Future<void> blockUser() async {
    final response = await chatRepository.userBlock(
      receiverUserData!.userId!,
      true,
    );

    if (response != null && response.statusCode == 200) {
      final serverUsers = await contactRepository.fetchAppUsersFromContacts([
        receiverUserData!.phoneNumber.toString(),
      ]);

      print(serverUsers);

      // serverUsers.first.blockedByMe;
      blocked.value = serverUsers.first.isBlocked!;

      blockedByMe.value = serverUsers.first.blockedByMe;

      await contactsTable.updateUserBlockUnblock(
        receiverUserData!.userId!,
        serverUsers.first.isBlocked! ? 1 : 0,
        serverUsers.first.blockedByMe,
      );

      // final (blockedI, blockedByMeI) = (await contactsTable.isUserBlocked(
      //   receiverUserData!.userId!,
      // ));

      // if (blockedByMeI == null) {
      //   blockedByMe.value = 1;
      //   await contactsTable.updateUserBlockUnblock(
      //     receiverUserData!.userId!,
      //     1,
      //     1,
      //   );
      // } else if (blockedByMeI == 0 && blockedI == true) {
      //   blockedByMe.value = 2;
      //   await contactsTable.updateUserBlockUnblock(
      //     receiverUserData!.userId!,
      //     1,
      //     2,
      //   );
      // }
      await chatConectTable.updateUserBlockUnblock(
        receiverUserData!.userId!.toString(),
        serverUsers.first.isBlocked! ? 1 : 0,
      );
      // blockedByMe.value = 1;

      // await findUserBlock();

      // await selectedContactController.syncContactsWithServer();
      // "contact blocked successfully"
    }
  }

  Future<void> unblockUser() async {
    final response = await chatRepository.userBlock(
      receiverUserData!.userId!,
      false,
    );

    if (response != null && response.statusCode == 200) {
      final serverUsers = await contactRepository.fetchAppUsersFromContacts([
        receiverUserData!.phoneNumber.toString(),
      ]);

      // blocked.value = false;
      blockedByMe.value = serverUsers.first.blockedByMe;

      blocked.value = serverUsers.first.isBlocked!;

      await contactsTable.updateUserBlockUnblock(
        receiverUserData!.userId!,
        serverUsers.first.isBlocked! ? 1 : 0,
        serverUsers.first.blockedByMe,
      );

      await chatConectTable.updateUserBlockUnblock(
        receiverUserData!.userId!.toString(),
        serverUsers.first.isBlocked! ? 1 : 0,
      );
      // blockedByMe.value = 0;

      // final (blockedI, blockedByMeI) = (await contactsTable.isUserBlocked(
      //   receiverUserData!.userId!,
      // ));

      // if (blockedByMeI == 1 && blockedI == true) {
      //   blockedByMe.value = null;
      //   await contactsTable.updateUserBlockUnblock(
      //     receiverUserData!.userId!,
      //     0,
      //     null,
      //   );
      //   await chatConectTable.updateUserBlockUnblock(
      //     receiverUserData!.userId!.toString(),
      //     0,
      //   );
      // } else if (blockedByMeI == 2 && blockedI == true) {
      //   blockedByMe.value = null;
      //   await contactsTable.updateUserBlockUnblock(
      //     receiverUserData!.userId!,
      //     1,
      //     0,
      //   );
      //   await chatConectTable.updateUserBlockUnblock(
      //     receiverUserData!.userId!.toString(),
      //     1,
      //   );
      // }

      // await findUserBlock();

      await selectedContactController.syncContactsWithServer();

      // "contact blocked successfully"
    }
  }

  Future<void> findUserBlock() async {
    final (blockedI, blockedByMeI) = (await contactsTable.isUserBlocked(
      receiverUserData!.userId!,
    ));
    if (blockedByMeI != null) {
      blocked.value = blockedI!;
      blockedByMe.value = blockedByMeI;
    } else {
      if (kDebugMode) {
        print("ℹ️ User not found in DB");
      }
    }
  }

  Future<List<Contact>> getDeviceContacts() async {
    final permission = await FlutterContacts.requestPermission();

    if (!permission) {
      Get.snackbar(
        "Permission Required",
        "Please allow contacts permission",
        snackPosition: SnackPosition.BOTTOM,
      );
      return [];
    }

    final contacts = await FlutterContacts.getContacts(withProperties: true);

    return contacts;
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

  //  Future<void> checkMessageInList(int repliedId) async {
  //     bool messageFound = false;
  //     int localOffset = currentOffset;

  //     while (!messageFound) {
  //       final messages = await MessageTable().fetchMessagesPaginated(
  //         receiverId: receiverUserData?.userId ?? 0,
  //         senderId: senderuserData?.userId ?? 0,
  //         offset: localOffset,
  //         limit: pageSize,
  //       );

  //       if (messages.isEmpty) {
  //         print("Reached end of messages. Message not found.");
  //         break;
  //       }

  //       final index = messages.indexWhere((e) => e.messageId == repliedId);
  //       if (index != -1) {
  //         final foundMessage = messages[index];
  //         print("Found message: ${foundMessage.messageText}");

  //         // Optionally add this to message list
  //         messageList.insertAll(0, messages); // or a smarter merge logic

  //         // Update index map and scroll
  //         updateMessageIdToIndex(); // Make sure you have this method to rebuild map

  //         scrollToOriginalMessage(repliedId);
  //         messageFound = true;
  //       } else {
  //         localOffset += messages.length;
  //         messageList.insertAll(
  //             0, messages); // Prepend as new messages load upward
  //       }
  //     }

  //     currentOffset = localOffset; // Maintain progress
  //   }

  void checkUserOnline(UserList? user) async {
    if (user == null) return;
    var params = {"recipientId": user.userId};
    if (socketService.isConnected && blocked == false) {
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
      final messages = await MessageTable().fetchMessagesPaginated(
        receiverId: receiverUserData?.userId ?? 0,
        senderId: senderuserData?.userId ?? 0,
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

  void scrollToBottom({Duration duration = const Duration(milliseconds: 260)}) {
    if (!itemScrollController.isAttached) return;

    final lastIndex = messageList.length - 1;

    itemScrollController.scrollTo(
      index: lastIndex,
      duration: duration,
      curve: Curves.easeOut, // WhatsApp-like feel
    );
  }

  // void scrollToBottom({bool animated = false}) {
  //   if (itemScrollController.isAttached) {
  //     final lastIndex = messageList.length - 1;
  //     if (animated) {
  //       itemScrollController.scrollTo(
  //         index: lastIndex,
  //         duration: const Duration(milliseconds: 300),
  //         curve: Curves.easeInOut,
  //       );
  //     } else {
  //       itemScrollController.jumpTo(index: lastIndex);
  //     }
  //   }
  // }

  void bindReceiverUserStream(int userId) {
    receiverUserSubscription = getReceiverStream(userId).listen((user) {
      if (user != null) {
        receiverUserData = user;
      }
    });
  }

  Stream<UserList?> getReceiverStream(int userId) async* {
    yield* Stream.periodic(const Duration(seconds: 1), (_) async {
      return await contactsTable.getUserById(userId);
    }).asyncMap((event) async => await event);
  }

  void bindSocketEvents() {
    ever(socketService.incomingMessage, (NewMessageModel? message) {
      if (!isInCurrentChat) return;
      bool isFromCurrentChat(NewMessageModel msg) {
        return (msg.senderId == receiverUserData?.userId &&
                msg.recipientId == senderuserData?.userId) ||
            (msg.senderId == receiverUserData?.userId &&
                msg.recipientId == senderuserData?.userId);
      }

      if (message != null && isFromCurrentChat(message)) {
        messageList.add(message);
        if (!showScrollToBottom.value) {
          Future.delayed(const Duration(milliseconds: 60), () {
            scrollToBottom();
          });
        }

        // Acknowledge seen if message is incoming and not already seen
        if (message.senderId == receiverUserData?.userId &&
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
        if (del.isDeleteFromEveryone && blocked == false) {
          final updated = messageList[index].copyWith(
            message: "This message was deleted",
            messageType: MessageType.deleted,
          );
          messageList[index] = updated;
        } else {
          messageList.removeAt(index);
        }
        messageList.refresh();
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

    ever(socketService.incomBlockUser, (BlockUserModel? userBlock) async {
      // userBlock

      final (blockedI, blockedByMeI) = (await contactsTable.isUserBlocked(
        userBlock!.blockedBy!,
      ));

      if (userBlock.isBlock == true &&
          (blockedByMeI == null || blockedByMeI == 0)) {
        await contactsTable.updateUserBlockUnblock(
          userBlock.blockedBy!,
          userBlock.isBlock == true ? 1 : 0,
          0,
        );
        await chatConectTable.updateUserBlockUnblock(
          userBlock.blockedBy!.toString(),
          userBlock.isBlock == true ? 1 : 0,
        );

        blocked.value = userBlock.isBlock!;

        blockedByMe.value = 0;
      } else if (userBlock.isBlock == true && (blockedByMeI == 1)) {
        await contactsTable.updateUserBlockUnblock(
          userBlock.blockedBy!,
          userBlock.isBlock == true ? 1 : 0,
          2,
        );
        await chatConectTable.updateUserBlockUnblock(
          userBlock.blockedBy!.toString(),
          userBlock.isBlock == true ? 1 : 0,
        );
        blocked.value = userBlock.isBlock!;

        blockedByMe.value = 2;
      }
      // unblock
      else if (userBlock.isBlock == false && (blockedByMeI == 0)) {
        await contactsTable.updateUserBlockUnblock(
          userBlock.blockedBy!,
          userBlock.isBlock == true ? 1 : 0,
          null,
        );
        await chatConectTable.updateUserBlockUnblock(
          userBlock.blockedBy!.toString(),
          userBlock.isBlock == true ? 1 : 0,
        );
        blocked.value = userBlock.isBlock!;

        blockedByMe.value = null;
      } else if (userBlock.isBlock == false && (blockedByMeI == 2)) {
        await contactsTable.updateUserBlockUnblock(userBlock.blockedBy!, 1, 1);
        await chatConectTable.updateUserBlockUnblock(
          userBlock.blockedBy!.toString(),
          1,
        );
        blocked.value = !userBlock.isBlock!;

        blockedByMe.value = 1;
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
    final messages = await MessageTable().fetchMessagesPaginated(
      receiverId: receiverUserData?.userId ?? 0,
      senderId: senderuserData?.userId ?? 0,
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

      for (var i in messages) {
        if ((i.state == MessageState.sent ||
                i.state == MessageState.unsent ||
                i.state == MessageState.delivered) &&
            i.messageId != null) {
          if (receiverUserData!.userId == i.senderId &&
              socketService.isConnected) {
            socketService.sendMessageSeen(i.messageId!);
          }
        } else if (senderuserData!.userId == i.senderId &&
            i.syncStatus == SyncStatus.pending &&
            i.messageId == null &&
            i.isAsset == false) {
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

  Future<void> sendTextMessage({bool isContact = false}) async {
    final message = messageController.text.trim();
    if (message.isEmpty) return;
    if (message.length > 800) {
      showAlertMessage("This message is too long, Please shorter the message.");
      return;
    }

    final clientSystemMessageId = const Uuid().v1();
    final timeSent = DateTime.now();

    final newMessage = NewMessageModel(
      senderId: senderuserData?.userId,
      recipientId: receiverUserData?.userId,
      message: encryptionService.encryptText(message),
      messageSentFromDeviceTime: timeSent.toString(),
      clientSystemMessageId: clientSystemMessageId,
      state: MessageState.unsent,
      syncStatus: SyncStatus.pending,
      createdAt: timeSent.toString(),
      senderPhoneNumber: senderuserData?.phoneNumber,
      receiverPhoneNumber: receiverUserData?.phoneNumber,
      messageType: isContact ? MessageType.contact : MessageType.text,
      isForwarded: false,
      isGroupMessage: false,
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
      isAsset: false,
      assetThumbnail: "",
      assetOriginalName: "",
      assetServerName: "",
      assetUrl: "",
      messageRepliedUserId: messageReply.message == null
          ? 0
          : messageReply.isMe == true
          ? senderuserData?.userId
          : receiverUserData?.userId,
    );
    print("Message All details Request: ${newMessage.toMap()}");

    messageList.add(newMessage);
    await MessageTable().insertMessage(newMessage).then((onValue) async {
      Future.delayed(Durations.medium4);
      final user = await contactsTable.getUserById(newMessage.recipientId!);
      if (user != null) {
        if (socketService.isConnected) {
          _sendingMessageIds.add(clientSystemMessageId);
          // encryptionService.encryptText();

          socketService.sendMessage(newMessage);
        } else {
          socketService.saveChatContacts(newMessage);
        }
      } else {
        await contactsTable.insertPlaceholderUser(
          userId: receiverUserData?.userId ?? 0,
          isOnline: receiverUserData?.isOnline == true ? 1 : 0,
          phoneNumber: receiverUserData?.phoneNumber ?? "",
          localName: "",
          countryCode: receiverUserData?.countryCode ?? 0,
          name: receiverUserData?.name ?? '',
          email: receiverUserData?.email ?? '',
          userDescription: receiverUserData?.userDescription ?? '',
          displayPicture: receiverUserData?.displayPicture ?? '',
          displayPictureUrl: receiverUserData?.displayPictureUrl ?? '',
          lastSeen: receiverUserData?.lastSeenTime ?? '',
          isBlocked: receiverUserData?.isBlocked == true ? 1 : 0,
          blockedByMe: senderuserData!.userId!,
        );
        if (socketService.isConnected) {
          _sendingMessageIds.add(clientSystemMessageId);
          // encryptionService.encryptText();

          socketService.sendMessage(newMessage);
        } else {
          socketService.saveChatContacts(newMessage);
        }
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 100), () {
          scrollToBottom();
        });
      });
    });

    messageController.clear();
    isShowSendButton = false;
    isPreviewing.value = false;
    var receiverUserId = receiverUserData?.userId.toString() ?? '';
    socketService.emitTypingStatus(
      recipientId: receiverUserId,
      isTyping: false,
    );
    typingTimer?.cancel();
    await cancelReply();
  }

  void onTextChanged(String text) {
    final receiverId = receiverUserData?.userId.toString() ?? "";

    if (text.isNotEmpty) {
      isShowSendButton = true;
      isPreviewing.value = false;

      // Emit isTyping: true
      if (blocked == false) {
        socketService.emitTypingStatus(recipientId: receiverId, isTyping: true);
      }

      // Debounce logic for isTyping: false
      typingTimer?.cancel();
      typingTimer = Timer(const Duration(seconds: 2), () {
        socketService.emitTypingStatus(
          recipientId: receiverId,
          isTyping: false,
        );
      });
    } else {
      isShowSendButton = false;
      isPreviewing.value = false;

      // Immediately emit false if field is cleared
      socketService.emitTypingStatus(recipientId: receiverId, isTyping: false);
      typingTimer?.cancel();
    }

    // messageController.text = text;
  }

  void toggleMessageSelection(NewMessageModel message) {
    if (selectedMessages.contains(message)) {
      selectedMessages.remove(message);
      if (kDebugMode) {
        print("Message removed from list:------> $message");
      }
    } else {
      selectedMessages.add(message);
      if (kDebugMode) {
        print("Message added to list:------> $message");
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
        if (deleteForEveryone && blocked == false) {
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
              isGroup: 0,
              lastMessage: "This message was deleted",
              timeSent: message.messageSentFromDeviceTime,
            );
          }
        } else {
          await MessageTable().deleteMessage(message.messageId!);
          // Remove from messageList
          messageList.removeWhere((m) => m.messageId == message.messageId);
          if (isOnline) {
            if (message.senderId != receiverUserData?.userId) {
              socketService.emitMessageDelete(
                messageId: message.messageId!,
                isDeleteFromEveryOne: false,
              );
            }
          } else {
            if (message.senderId != receiverUserData?.userId) {
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
                isGroup: 0,
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
                isGroup: 0,
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
    print("🔥 FILE TYPE RECEIVED: $fileType");
    if (fileType == MessageType.image.value) {
      final files = await FilePickerService().pickImagesFromGalleryWithCrop();

      if (files.isEmpty) return;

      final fileTypeValue = getMessageType(files.first).value;

      Get.to(
        () => MediaPreviewScreen(
          files: files,
          fileType: fileTypeValue,
          onSend: (List<File> selectedFiles) async {
            for (final f in selectedFiles) {
              await sendFileMessage(file: f, messageEnum: getMessageType(f));
            }
            cancelReply();
          },
        ),
      );
    } else if (fileType == MessageType.video.value) {
      final selectedFiles = await pickVideos();
      for (File file in selectedFiles) {
        await sendFileMessage(file: file, messageEnum: getMessageType(file));
        cancelReply();
      }
    } else if (fileType == MessageType.camera.value) {
      // pickFromCamera returns List<File> (may be single file)
      final files = await FilePickerService().pickFromCamera(Get.context!);
      if (files.isEmpty) return;

      final fileTypeValue = getMessageType(files.first).value;

      Get.to(
        () => MediaPreviewScreen(
          files: files,
          fileType: fileTypeValue,
          onSend: (List<File> selectedFiles) async {
            for (final f in selectedFiles) {
              await sendFileMessage(file: f, messageEnum: getMessageType(f));
            }
            cancelReply();
          },
        ),
      );
    } else if (fileType == MessageType.audio.value) {
      //  final selectedFile = await pickAudio();
      // pickAndSendAudios
      await pickAndSendAudios((selectedFiles) async {
        for (File file in selectedFiles) {
          print("Yes Getting back all files:---> $file");
          await sendFileMessage(file: file, messageEnum: getMessageType(file));
        }
      });
      cancelReply();
    } else if (fileType == MessageType.document.value && Platform.isAndroid) {
      Get.to(
        () => DocumentPickerScreen(
          onSend: (selectedFiles) async {
            for (File file in selectedFiles) {
              await sendFileMessage(
                file: file,
                messageEnum: getMessageType(file),
              );
            }
            cancelReply();

            print("calling cancel reply ${cancelReply()}");
          },
          chatController: Get.find<SingleChatController>(),
        ),
        binding: DocumentsBinding(),
      );
      final files = await DocumentScannerService.scanDocuments();
      if (files.isEmpty) {
        showSnackBar(context: Get.context!, content: "No documents found");
        return;
      }
    } else if (fileType == MessageType.document.value && Platform.isIOS) {
      final files = await FilePickerService().pickDocuments();

      final completer = Completer<bool>();

      // ((selectedFiles) async {
      // showAlertMessageWithAction(
      //   message: "Do you want to send ${files.length} document(s)?",
      //   confirmText: "Send",
      //   cancelText: "Cancel",
      //   onCancel: () {
      //     // Get.back(); // close dialog
      //     completer.complete(false); // complete with false
      //   },
      //   onConfirm: () {
      //     // Get.back(); // close dialog
      //     completer.complete(true); // complete with true
      //   },
      //   showCancel: true,
      //   title: 'Genchat',
      //   context: Get.context!,
      // );
      for (File file in files) {
        print("Yes Getting back all files:---> $file");
        await sendFileMessage(file: file, messageEnum: getMessageType(file));
      }
      // });
      cancelReply();
    } else if (fileType == MessageType.browseDocx.value) {
      await pickAndSendDocuments((selectedFiles) async {
        for (File file in selectedFiles) {
          print("Yes Getting back all files:---> $file");
          await sendFileMessage(file: file, messageEnum: getMessageType(file));
        }
      });
      cancelReply();
    }
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

  Future<List<File>> pickVideos() async {
    Completer<List<File>> completer = Completer<List<File>>();
    await showVideoPickerBottomSheet(
      onSendFiles: (img, fileType) {
        completer.complete(img);
      },
    );

    return completer.future;
  }

  Future<List<File>> pickDocuments() async {
    return await DocumentScannerService.scanDocuments();
  }

  // Future<String> saveFileLocally(
  //     File file, String fileType, String fileExtension) async {
  //   String newExtension = fileExtension.toLowerCase();

  //   print("Original file size: ${await getReadableFileSize(file)}");
  //   final subFolderName = fileType.toTitleCase;

  //   File processedFile = file;

  //   // Map<String, File?> f = await compressFiles(file, fileExtension);
  //   final fileName =
  //       "genchat_message_${senderuserData!.userId}_${DateTime.now().millisecondsSinceEpoch}.${file.path}";

  //   final filePath = await folderCreation.saveFileFromFile(
  //     sourceFile: file,
  //     fileName: fileName,
  //     subFolder: subFolderName,
  //   );

  //   print(
  //       "processedFile file size: ${await getReadableFileSize(processedFile)}");

  //   return fileName;
  // }

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

      Map<String, File?> f = messageEnum == MessageType.video
          ? {fileExtension: file}
          : await compressFiles(file, fileExtension);

      final localFilePath = await saveFileLocally(
        f.values.first!,
        fileType,
        f.keys.first,
        fileName,
      );
      final String? assetThumnail =
          f.keys.first == "mp4" ||
              f.keys.first == "mov" ||
              f.keys.first == 'avi' ||
              f.keys.first == "mkv"
          ? await getThumbnail(File(localFilePath))
          : "";

      final fileWithExtensions = "$fileName.${f.keys.first}";
      print(
        "[SingleChat] sendFileMessage -> local saved: $localFilePath, name: $fileWithExtensions, type: ${messageEnum.value}",
      );

      // Create message immediately so it appears in UI with local media
      final newMessage = NewMessageModel(
        senderId: senderuserData?.userId,
        recipientId: receiverUserData?.userId,
        message: '',
        messageSentFromDeviceTime: timeSent.toString(),
        clientSystemMessageId: clientSystemMessageId,
        state: MessageState.unsent,
        syncStatus: SyncStatus.pending,
        createdAt: timeSent.toString(),
        senderPhoneNumber: senderuserData?.phoneNumber,
        messageType: messageEnum,
        isForwarded: false,
        isGroupMessage: false,
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
        assetOriginalName: "",
        assetServerName: fileWithExtensions,
        assetUrl: "",
        messageRepliedUserId: messageReply.message == null
            ? 0
            : messageReply.isMe == true
            ? senderuserData?.userId
            : receiverUserData?.userId,
        isUploading: true.obs,
        uploadProgress: 0.0.obs,
      );
      print(
        "[SingleChat] sendFileMessage -> created local message: ${newMessage.toMap()}",
      );
      await MessageTable().insertMessage(newMessage);
      messageList.add(newMessage);

      print("[SingleChat] sendFileMessage -> starting upload to server");
      final fileData = await uploadFileToServer(f.values.first!);

      if (fileData != null &&
          fileData.statusCode == 200 &&
          fileData.status == true) {
        print(
          "[SingleChat] sendFileMessage -> upload success: ${fileData.data?.url}",
        );
        final updatedMessage = newMessage.copyWith(
          assetOriginalName: fileData.data?.originalName,
          assetUrl: fileData.data?.url,
          syncStatus: SyncStatus.synced,
        );
        await MessageTable().updateMessageByClientId(updatedMessage);
        final index = messageList.indexWhere(
          (m) => m.clientSystemMessageId == clientSystemMessageId,
        );
        if (index != -1) {
          messageList[index] = updatedMessage;
          messageList.refresh();
        }
        if (socketService.isConnected) {
          socketService.sendMessage(updatedMessage);
        } else {
          socketService.saveChatContacts(updatedMessage);
        }
      } else {
        print("[SingleChat] sendFileMessage -> upload failed or null response");
        // Keep syncStatus as pending so it can be retried later
        socketService.saveChatContacts(newMessage);
      }
    } catch (e) {
      if (kDebugMode) {
        print("[SingleChat] Error sending file message: $e");
      }
    }
  }

  Future<void> clearFilePickerCache() async {
    try {
      Directory appDir = await getApplicationDocumentsDirectory();

      final tempDir = Platform.isAndroid
          ? Directory("/data/user/0/com.genmak.genchat/cache/file_picker/")
          : Directory('${appDir.path}/picked_images');
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
        print("Temp directory cleared.");
      }
    } catch (e) {
      print("Failed to clear temp directory: $e");
    }
  }

  Future<UploadFileModel?> uploadFileToServer(File imageFile) async {
    try {
      final response = await profileRepository.uploadMessageFiles(
        imageFile,
        onProgress: (sent, total) {
          percent.value = (sent / total) * 100;
          print("📤 Upload progress: ${percent.value.toStringAsFixed(0)}%");
          if (percent.value == 100) {
            percent.value = 0.0;
          }
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
        recipientId: receiverUserData?.userId,
        message: '',
        messageSentFromDeviceTime: timeSent.toString(),
        clientSystemMessageId: clientSystemMessageId,
        state: MessageState.unsent,
        syncStatus: SyncStatus.pending,
        createdAt: timeSent.toString(),
        senderPhoneNumber: senderuserData?.phoneNumber,
        messageType: messageEnum,
        isForwarded: false,
        isGroupMessage: false,
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
            : receiverUserData?.userId,
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
    required String assetsThumbnail,
  }) {
    messageReply = MessageReply(
      messageId: messageId,
      message: message,
      isMe: isMe,
      messageType: messageType,
      isReplied: isReplied,
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
      receiverId: receiverUserData!.userId,
      senderId: senderuserData?.userId,
    );

    //  'deleted'
    MessageTable().deleteMessageText(
      messageType: 'deleted',
      receiverId: receiverUserData!.userId,
      senderId: senderuserData?.userId,
    );
    MessageTable().deleteMessageText(
      messageType: "image",
      receiverId: receiverUserData!.userId,
      senderId: senderuserData?.userId,
    );
    MessageTable().deleteMessageText(
      messageType: "video",
      receiverId: receiverUserData!.userId,
      senderId: senderuserData?.userId,
    );

    MessageTable().deleteMessageAll(
      receiverId: receiverUserData!.userId,
      senderId: senderuserData?.userId,
    );

    messageList.clear();

    await chatConectTable.updateContact(
      uid: receiverUserData!.userId.toString(),
      isGroup: 0,
      lastMessage: "",
      timeSent: "",
    );
  }

  Future<void> deleteMedia() async {
    await folderCreation.clearMediaFiles();
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
      final filePath = await FolderCreation().checkAndHandleFile(
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

  String getFilePath(MessageType type, String fileName) {
    return '$rootPath${getFolderName(type)}/$fileName';
  }

  String getThumbnailFilePath(MessageType type, String fileName) {
    return '$rootPath${getFolderName(type)}/$fileName';
  }

  // Initialize the recorder
  Future<void> initRecorder() async {
    recorderController
      ..androidEncoder = AndroidEncoder.aac
      ..androidOutputFormat = AndroidOutputFormat.mpeg4
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
      ..sampleRate = 44100;
  }

  Future<void> startRecordingAudioWaveform() async {
    try {
      isRecording.value = true;
      final fileName =
          "genchat_audio_${senderuserData!.userId.toString()}_${DateTime.now().millisecondsSinceEpoch}";

      final Directory thumDir;
      if (Platform.isAndroid) {
        thumDir = Directory("/storage/emulated/0/Android/media");
      } else {
        thumDir = await getApplicationDocumentsDirectory();
      }

      final String rootFolderPath =
          '${thumDir.path}/$appPackageName/GenChat/Audio';

      final Directory dirThum = Directory(rootFolderPath);
      if (!await dirThum.exists()) {
        await dirThum.create(recursive: true);
      } else {
        if (kDebugMode) {
          print(dirThum.path);
        }
      }
      final thumbnailPath = dirThum.path;

      final hasPermission = await Permission.microphone.request();
      if (!hasPermission.isGranted) {
        await Permission.microphone.request();
        return;
      }
      recordedPath.value = '$thumbnailPath/$fileName.m4a';
      await recorderController.record(path: recordedPath.value);

      isPreviewing.value = true;
    } catch (e) {
      print("Error starting recorder: $e");
    }
  }

  Future<void> stopRecordingAudioWaveform() async {
    try {
      // recorderController.reset();
      await recorderController.stop();
      isRecording.value = false;
    } catch (e) {
      print("Error stopping recorder: $e");
    }
  }

  Future<void> pauseRecordingAudioWaveform() async {
    try {
      isPause = true;

      // recorderController.refresh();
      // await recorderController.record(path: recordedPath.value);
      await recorderController.pause();

      isPreviewing.value = true;
    } catch (e) {
      print("Error stopping recorder: $e");
    }
  }

  Future<void> restartRecordingAudioWaveform() async {
    try {
      // await recorderController.stop(false);
      await recorderController.record(path: recordedPath.value);

      isPause = false;

      isPreviewing.value = true;
    } catch (e) {
      print("Error stopping recorder: $e");
    }
  }

  Future<void> cancelRecordingAudioWaveform() async {
    try {
      isRecording.value = false;
      isPreviewing.value = false;
      isPause = false;
      isRecording.value = false;
      recorderController.reset();
      recorderController.stop();

      File(recordedPath.value).delete();
      recordedPath.value = '';

      stopPlayback();
    } catch (e) {
      print("Error canceling recorder: $e");
    }
  }

  Future<void> playRecordingAudioWaveform() async {
    if (recordedPath.value.isNotEmpty) {
      playAudio.value = true;
      await Permission.audio.request();
      final req = await Permission.microphone.request();

      if (req.isGranted) {
        final file = File(recordedPath.value);
        if (!file.existsSync() || file.lengthSync() < 1000) {
          print("Audio file too short or corrupted");
          return;
        }
        await Future.delayed(const Duration(milliseconds: 500));

        try {
          await playerController.preparePlayer(path: recordedPath.value);
          await playerController.startPlayer();

          playerController.onCompletion.listen((_) {
            playAudio.value = false;
            print("Playback completed");
          });
        } catch (e) {
          print("Playback error: $e");
        }

        // });
      }

      // await playerController.startPlayer();
    }
  }

  Future<void> stopPlayback() async {
    await playerController.stopPlayer();
    playAudio.value = true;
  }

  // pause playing audio
  Future<void> pausePlayback() async {
    await playerController.pausePlayer();

    playAudio.value = false;

    // await soundPlayer.value.pausePlayer();
    // await player.pause();
  }

  Future<void> formatDuration() async {
    final durationMillis = await playerController.getDuration();
    Duration duration = Duration(milliseconds: durationMillis);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    audioTime.value = "$minutes:$seconds";
  }

  // send audio
  Future<void> sendAudioMessage() async {
    final clientSystemMessageId = const Uuid().v1();
    final timeSent = DateTime.now();
    final fileType = MessageType.audio.value.split('.').last;
    try {
      await stopRecordingAudioWaveform();
      // stopPlayback();

      isPreviewing.value = false;
      isRecording.value = false;
      playAudio.value = false;
      isPause = false;
      final serverName = recordedPath.value.toString().split(
        "/",
      )[recordedPath.value.toString().split("/").length - 1];

      print(serverName);

      final fileData = await uploadFileToServer(
        File(recordedPath.value.toString()),
      );
      final newMessage = NewMessageModel(
        senderId: senderuserData?.userId,
        recipientId: receiverUserData?.userId,
        message: recorderController.recordedDuration.toHHMMSS(),
        messageSentFromDeviceTime: timeSent.toString(),
        clientSystemMessageId: clientSystemMessageId,
        state: MessageState.unsent,
        syncStatus: SyncStatus.pending,
        createdAt: timeSent.toString(),
        senderPhoneNumber: senderuserData?.phoneNumber,
        messageType: MessageType.audio,
        isForwarded: false,
        isGroupMessage: false,
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
        assetThumbnail: serverName,
        assetOriginalName: fileData == null ? "" : fileData.data?.originalName,
        assetServerName: serverName,
        assetUrl: fileData == null ? "" : fileData.data?.url,
        messageRepliedUserId: messageReply.message == null
            ? 0
            : messageReply.isMe == true
            ? senderuserData?.userId
            : receiverUserData?.userId,
      );
      print("Message All details Request: ${newMessage.toMap()}");
      await MessageTable().insertMessage(newMessage);
      messageList.add(newMessage);
      recordedPath.value = "";

      if (fileData?.statusCode == 200 && fileData?.status == true) {
        if (socketService.isConnected) {
          socketService.sendMessage(newMessage);
          isPreviewing.value = false;
        }
      } else {
        socketService.saveChatContacts(newMessage);
        isPreviewing.value = false;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error sending file message: $e");
      }
    }
    cancelReply();
  }

  String getDisplayName() {
    if (receiverUserData == null) return "";

    // 1. localName (if exists & not empty)
    if (receiverUserData!.localName != null &&
        receiverUserData!.localName!.trim().isNotEmpty) {
      return receiverUserData!.localName!.trim();
    }

    // 2. phoneNumber (if exists & not empty)
    if (receiverUserData!.phoneNumber != null &&
        receiverUserData!.phoneNumber!.trim().isNotEmpty) {
      return receiverUserData!.phoneNumber!.trim();
    }

    // 3. name as fallback (never null usually)
    return receiverUserData!.name ?? "";
  }

  // save contact
  Future<void> saveContact({
    required String name,
    required String phone,
  }) async {
    if (!await FlutterContacts.requestPermission()) {
      return;
    }

    final contact = Contact()
      ..name.first = name
      ..phones = [Phone(phone)];

    await contact.insert();
  }

  void showSaveContactDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController mobileController = TextEditingController(
      text: receiverUserData!.phoneNumber,
    );
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    final focusNode = FocusNode();

    // Delay focus AFTER dialog is built
    Future.delayed(const Duration(milliseconds: 200), () {
      if (context.mounted) {
        FocusScope.of(context).requestFocus(focusNode);
      }
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text("Save Contact"),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Name Field
                TextFormField(
                  // autofocus: true,
                  controller: nameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: "Name",
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Enter name";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Mobile Number Field
                TextFormField(
                  controller: mobileController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  decoration: const InputDecoration(
                    labelText: "Mobile Number",
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                    counterText: "",
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Enter mobile number";
                    }
                    if (value.length != 10) {
                      return "Enter valid 10-digit number";
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final name = nameController.text.trim();
                  final mobile = mobileController.text.trim();

                  // TODO: Save contact logic
                  print("Name: $name, Mobile: $mobile");

                  saveContact(
                    name: nameController.text,
                    phone: mobileController.text,
                  );

                  await chatConectTable.insertOrUpdateGroupChat(
                    ChatConntactModel(
                      uid: receiverUserData!.userId.toString(),
                      isGroup: 1,
                      profilePic: receiverUserData?.displayPictureUrl ?? '',
                      timeSent: receiverUserData?.lastSeenTime ?? "",
                      name: nameController.text,
                      contactId: receiverUserData!.userId.toString(),
                      lastMessage: "",
                      lastMessageId: 0,
                      unreadCount: 0,
                    ),
                  );
                  receiverUserData = receiverUserData!.copyWith(
                    name: nameController.text,
                    phoneNumber: mobileController.text.isEmpty
                        ? mobile
                        : mobileController.text,
                  );
                  if (connectivityService.isConnected.value) {
                    selectedContactController.syncContactsWithServer();
                  }
                  userExist.value = true;
                  Get.back();
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Future<void> checkUserExistOrNot() async {
    // RxBool userExist = false.obs;
    if (receiverUserData!.localName!.isNumericOnly) {
      userExist.value = true;
    }
  }
}
