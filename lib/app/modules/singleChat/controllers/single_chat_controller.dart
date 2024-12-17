import 'dart:async';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:genchatapp/app/config/services/connectivity_service.dart';
import 'package:genchatapp/app/config/services/firebase_controller.dart';
import 'package:genchatapp/app/constants/message_enum.dart';
import 'package:genchatapp/app/data/models/chat_conntact_model.dart';
import 'package:genchatapp/app/data/models/message_model.dart';
import 'package:genchatapp/app/data/models/message_reply.dart';
import 'package:genchatapp/app/data/models/user_model.dart';
import 'package:genchatapp/app/services/shared_preference_service.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../data/local_database/message_table.dart';

class SingleChatController extends GetxController with WidgetsBindingObserver {
  //

  final connectivityService = Get.find<ConnectivityService>();
  final firebaseController = Get.put(FirebaseController());
  final sharedPreferenceService = Get.find<SharedPreferenceService>();

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

  final RxList<MessageModel> messageList = <MessageModel>[].obs;

  final Rx<FlutterSoundRecorder> soundRecorder = FlutterSoundRecorder().obs;

  FocusNode focusNode = FocusNode();

  final Rx<UserModel> _senderuserData = UserModel().obs;
  UserModel get senderuserData => _senderuserData.value;
  set senderuserData(UserModel userData) => _senderuserData.value = (userData);

  final RxString _id = "".obs;
  String get id => _id.value;
  set id(String str) => _id.value = str;

  final RxString _fullname = "".obs;
  String get fullname => _fullname.value;
  set fullname(String str) => _fullname.value = str;

  Rx<UserModel> receiveruserDataModel = UserModel(
    isOnline: false,
  ).obs;

  final RxList<MessageModel> selectedMessages = <MessageModel>[].obs;
  late Stream<List<MessageModel>> messageStream;
  late StreamSubscription<List<MessageModel>> messageSubscription;

  @override
  void onInit() {
    super.onInit();
    senderuserData = sharedPreferenceService.getUserDetails()!;

    id = Get.arguments[0];
    fullname = Get.arguments[1];
  }

  @override
  void onReady() {
    bindStream();

    bindMessageStream();
    startListeningForConnectivityChanges();
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
    selectedMessages.clear();
    messageSubscription.cancel();
  }

  void bindMessageStream() {
    messageStream = getMessageStream();
    messageSubscription = messageStream.listen((messages) {
      messageList.assignAll(messages);
    });
  }

  Stream<List<MessageModel>> getMessageStream() async* {
    if (connectivityService.isConnected.value) {
      retryPendingMessages();
      yield* firebaseController
          .listenToMessages(
        currentUserId: senderuserData.uid!,
        receiverId: id.toString(),
      )
          .asyncMap((firebaseMessages) async {
        for (var message in firebaseMessages) {
          markMessagesAsSeen(message);
          await MessageTable().insertOrUpdateMessage(message);
        }
        return firebaseMessages;
      });
    } else {
      yield await MessageTable().fetchMessages(
        senderId: senderuserData.uid!,
        receiverId: id.toString(),
      );
    }
  }

  Future<void> syncFirebaseMessagesToLocal() async {
    try {
      final firebaseMessages = await firebaseController.fetchAllMessages(
        currentUserId: senderuserData.uid!,
        receiverId: id.toString(),
      );

      for (var message in firebaseMessages) {
        await MessageTable().insertOrUpdateMessage(message);
      }

      messageList.assignAll(firebaseMessages);
    } catch (e) {
      if (kDebugMode) {
        print("Error syncing Firebase messages to local: $e");
      }
    }
  }

  void startListeningForConnectivityChanges() {
    ever(connectivityService.isConnected, (bool isConnected) async {
      if (isConnected) {
        await syncFirebaseMessagesToLocal();
      }
    });
  }

  void bindStream() {
    receiveruserDataModel.bindStream(firebaseController.getUserData(id));
  }

  Future<void> sendTextMessage() async {
    if (messageController.text.trim().isEmpty) return;

    final messageId = const Uuid().v1();
    final timeSent = DateTime.now();

    final newMessage = MessageModel(
      senderId: senderuserData.uid!,
      receiverId: id.toString(),
      text: messageController.text.trim(),
      type: MessageEnum.text,
      timeSent: timeSent,
      messageId: messageId,
      status: MessageStatus.uploading,
      repliedMessage: '',
      repliedTo: '',
      repliedMessageType: MessageEnum.text,
      syncStatus: 'pending',
    );

    await MessageTable().insertMessage(newMessage);

    messageList.add(newMessage);
    messageController.clear();

    if (connectivityService.isConnected.value) {
      await _syncMessageToFirebase(newMessage);
    }
  }

  Future<void> _syncMessageToFirebase(MessageModel message) async {
    try {
      await _saveDataToContactsSubcollection(message);
      final sentMessage = message.copyWith(
          status: receiveruserDataModel.value.isOnline!
              ? MessageStatus.delivered
              : MessageStatus.sent,
          syncStatus: 'sent');

      await firebaseController.setUserMsg(
          currentUid: sentMessage.senderId,
          data: sentMessage,
          messageId: sentMessage.messageId,
          reciverId: sentMessage.receiverId);
      // Save message in the receiver's chat with 'delivered' status
      final deliveredMessage =
          message.copyWith(status: MessageStatus.delivered, syncStatus: 'sent');
      // users -> reciever id  -> sender id -> messages -> message id -> store message
      await firebaseController.setUserMsg(
          currentUid: deliveredMessage.receiverId,
          data: deliveredMessage,
          messageId: deliveredMessage.messageId,
          reciverId: deliveredMessage.senderId);

      // Update sync status in SQLite
      await MessageTable()
          .updateSyncStatus(message.messageId, 'sent', MessageStatus.delivered);
    } catch (e) {
      if (kDebugMode) {
        print("Error syncing message: $e");
      }
    }
  }

  void retryPendingMessages() async {
    final unsentMessages = await MessageTable().fetchUnsentMessages();

    for (var message in unsentMessages) {
      if (connectivityService.isConnected.value) {
        try {
          await _syncMessageToFirebase(message);
        } catch (e) {
          if (kDebugMode) {
            print("Error syncing message: $e");
          }
        }
      } else {
        if (kDebugMode) {
          print("Message has missing fields: ${message.toMap()}");
        }
        break;
      }
    }

    // Retry pending deletions
    final queuedDeletions = await MessageTable().getQueuedDeletions();
    for (var messageId in queuedDeletions) {
      if (connectivityService.isConnected.value) {
        try {
          await firebaseController.deleteMessage(
            currentUid: senderuserData.uid!,
            receiverId: id,
            messageId: messageId,
          );
          await MessageTable().removeQueuedDeletion(messageId);
        } catch (e) {
          print("Error syncing deletion: $e");
        }
      }
    }
  }

  void markMessagesAsSeen(MessageModel messages) async {
    final currentUserId = messages.receiverId;
    final senderId = messages.senderId.toString(); // ID of the chat partner

    // Update status only for messages not yet marked as 'seen'
    if (messages.status == MessageStatus.delivered &&
        messages.receiverId == senderuserData.uid) {
      await firebaseController.updateMessageStatus(
        currentUserId: senderuserData.uid!,
        senderId: senderId,
        messageId: messages.messageId,
        status: receiveruserDataModel.value.isOnline!
            ? MessageStatus.seen
            : messages.status,
      );
    }
  }

  Future<void> deleteMessages({required bool deleteForEveryone}) async {
    if (selectedMessages.isEmpty) return;

    try {
      for (var message in selectedMessages) {
        if (deleteForEveryone) {
          // Delete for everyone
          final placeholderMessage = message.copyWith(
            text: "This message was deleted",
            type: MessageEnum.deleted,
          );

          // Update the message for both sender and receiver in Firebase
          await firebaseController.setUserMsg(
            currentUid: message.senderId,
            data: placeholderMessage,
            messageId: message.messageId,
            reciverId: message.receiverId,
          );

          await firebaseController.setUserMsg(
            currentUid: message.receiverId,
            data: placeholderMessage,
            messageId: message.messageId,
            reciverId: message.senderId,
          );

          // Update the message content locally in SQLite
          await MessageTable().updateMessageContent(
            messageId: message.messageId,
            newText: "This message was deleted",
          );

          // Update the message in the UI
          final index = messageList
              .indexWhere((msg) => msg.messageId == message.messageId);
          if (index != -1) {
            messageList[index] = placeholderMessage;
            messageList.refresh();
          }
        } else {
          // Delete for me (local deletion only)
          await MessageTable().deleteMessage(message.messageId);
          messageList.removeWhere((msg) => msg.messageId == message.messageId);

          // Optionally, queue deletion for Firebase if offline
          if (connectivityService.isConnected.value) {
            await firebaseController.deleteMessage(
              currentUid: senderuserData.uid!,
              receiverId: id,
              messageId: message.messageId,
            );
          } else {
            await MessageTable().markForDeletion(message.messageId);
          }
        }
      }
      selectedMessages.clear();
    } catch (e) {
      if (kDebugMode) {
        print("Error deleting messages: $e");
      }
    }
  }

  void toggleMessageSelection(MessageModel message) {
    if (selectedMessages.contains(message)) {
      selectedMessages.remove(message);
      if (kDebugMode) {
        print("Message removed from list:------> $message");
      }
    } else {
      selectedMessages.add(message);
      if (kDebugMode) {
        print("Message added from list:------> $message");
      }
    }
    selectedMessages.refresh();
  }

  void clearSelectedMessages() {
    selectedMessages.clear();
  }

  _saveDataToContactsSubcollection(MessageModel message) async {
    // users -> reciever user id => chats -> current user id -> set data
    var recieverChatContact = ChatConntactModel(
      uid: message.senderId,
      name: senderuserData.name!,
      profilePic: senderuserData.profilePic!,
      contactId: message.senderId,
      timeSent: message.timeSent,
      lastMessage: message.text,
    );

    await firebaseController.sendUserMsg(
      currentUid: message.senderId,
      data: recieverChatContact,
      reciverId: message.receiverId,
    );
    // users -> current user id  => chats -> reciever user id -> set data
    var senderChatContact = ChatConntactModel(
      uid: message.receiverId,
      name: receiveruserDataModel.value.name!,
      profilePic: receiveruserDataModel.value.profilePic!,
      contactId: message.receiverId,
      timeSent: message.timeSent,
      lastMessage: message.text,
    );

    await firebaseController.sendUserMsg(
      currentUid: message.receiverId,
      data: senderChatContact,
      reciverId: message.senderId,
    );
  }

  Future<void> cancelReply() async {
    messageReply = MessageReply(
      isMe: false,
      message: null,
    );
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
    required MessageEnum messageEnum,
  }) {
    messageReply = MessageReply(
      message: message,
      isMe: isMe,
      messageEnum: messageEnum.type.toEnum(),
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
}
