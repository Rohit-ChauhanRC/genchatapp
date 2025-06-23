import 'package:genchatapp/app/config/services/folder_creation.dart';
import 'package:genchatapp/app/constants/message_enum.dart';
import 'package:genchatapp/app/data/local_database/chatconnect_table.dart';
import 'package:genchatapp/app/data/local_database/message_table.dart';
import 'package:genchatapp/app/data/models/chat_conntact_model.dart';
import 'package:genchatapp/app/data/models/new_models/response_model/new_message_model.dart';
import 'package:genchatapp/app/data/models/new_models/response_model/verify_otp_response_model.dart';
import 'package:genchatapp/app/network/api_endpoints.dart';
import 'package:genchatapp/app/utils/utils.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../data/local_database/contacts_table.dart';
import '../../data/models/new_models/response_model/message_ack_model.dart';

class SocketService extends GetxService {
  IO.Socket? _socket;
  IO.Socket? get socket => _socket;

  final ContactsTable contactsTable = ContactsTable();

  final ChatConectTable chatConectTable = ChatConectTable();

  final MessageTable messageTable = MessageTable();
  final FolderCreation folderCreation = FolderCreation();

  // final EncryptionService encryptionService = Get.find();

  // final RxBool _isConnected = false.obs;
  // bool get isConnected => _isConnected.value;

  bool get isConnected => _socket?.connected == true;

  final RxMap<String, bool> typingStatusMap = <String, bool>{}.obs;
  final Rx<NewMessageModel?> incomingMessage = Rx<NewMessageModel?>(null);
  final Rxn<DeletedMessageModel> deletedMessage = Rxn<DeletedMessageModel>();
  final Rxn<MessageAckModel> messageAcknowledgement = Rxn<MessageAckModel>();
  final Rxn<UserData> updateContactUser = Rxn<UserData>();


  Future<void> initSocket(String userId, {Function()? onConnected}) async {
    if (_socket != null) {
      if (_socket!.connected) {
        print('⚠️ Socket already connected, skipping init.');
        return;
      } else {
        // Socket is present but disconnected — dispose and reconnect
        print('🔄 Disposing stale socket and reinitializing...');
        await disposeSocket();
      }
    }
    _socket = IO.io(
      ApiEndpoints.socketBaseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect() // prevent auto connect before setting everything
          .enableForceNew()
          .setQuery({'userId': userId})
          .build(),
    );
    _registerSocketListeners(onConnected, userId);
    _socket?.connect();
    print('🔌 Socket initialized');
  }

  void _registerSocketListeners(Function()? onConnected, String userId, ) {
    _socket?.onConnect((_) async {
      print('✅ Socket connected');
      // _isConnected.value = true;
      await retryPendingDeletions();
      await syncPendingMessages(loginUserId: int.parse(userId));
      onConnected?.call();
    });

    _socket?.onDisconnect((_) {
      print('❌ Socket disconnected');
      // _isConnected.value = false;
      _clearSocketListeners();
    });

    _socket?.onError((data) {
      print('⚠️ Socket error: $data');
      _clearSocketListeners();
    });

    _socket?.onReconnect((_) {
      print('Socket reconnection.');
      _clearSocketListeners();
      _registerSocketListeners(onConnected,userId);
    });

    // Add your custom events here
    _socket?.on('message-event', (data) async {
      print('📩 Message received: $data');
      int messageId = data["messageId"];
      bool existsLocally = await messageTable.messageExists(messageId);
      //

      if (!existsLocally) {
        print("message not found");
        final newMessage = NewMessageModel(
            message: data["message"],
            senderId: data["senderId"],
            messageId: data["messageId"],
            recipientId: data["recipientId"],
            messageSentFromDeviceTime: data["messageSentFromDeviceTime"],
            messageType: data['messageType'] != null
                ? MessageTypeExtension.fromValue(data['messageType'])
                : MessageType.text,
            // default if null
            state: MessageState.sent,
            senderPhoneNumber: data["senderPhoneNumber"],
            isRepliedMessage: data["isRepliedMessage"] ?? false,
            messageRepliedOnId: data["messageRepliedOnId"],
            messageRepliedOn: data["messageRepliedOn"] ?? '',
            messageRepliedOnType: data["messageRepliedOnType"] != null
                ? MessageTypeExtension.fromValue(data["messageRepliedOnType"])
                : null,
            isAsset: data["isAsset"] ?? false,
            assetThumbnail: data["assetThumbnail"] ?? '',
            assetOriginalName: data["assetOriginalName"] ?? '',
            assetServerName: data["assetServerName"] ?? '',
            assetUrl: data["assetUrl"] ?? '',
            isForwarded: data["isForwarded"] ?? false,
            showForwarded: data["showForwarded"] ?? false,
            forwardedMessageId: data['forwardedMessageId'] ?? 0,
            messageRepliedUserId: data["messageRepliedUserId"] ?? 0);
        messageTable.insertMessage(newMessage);
        incomingMessage.value = newMessage;

        final chatContactMessage = NewMessageModel(
          message: data["message"],
          senderId: data["recipientId"],
          messageId: data["messageId"],
          recipientId: data["senderId"],
          messageSentFromDeviceTime: data["messageSentFromDeviceTime"],
          messageType: data['messageType'] != null
              ? MessageTypeExtension.fromValue(data['messageType'])
              : MessageType.text,
          state: MessageState.sent,
          senderPhoneNumber: data["senderPhoneNumber"],
        );

        saveChatContacts(chatContactMessage);
      } else {
        print("⚠️ Message $messageId found in locally, Skipping reinserting.");
      }
    });

    _socket?.on('message-acknowledgement', (data) async {
      print('✅ Message Ack: $data');
      if (data["state"] == 1) {
        messageTable.updateAckMessage(
          clientSystemMessageId: data["clientSystemMessageId"].toString(),
          state: data["state"],
          messageId: data["messageId"],
          syncStatus: SyncStatus.synced,
        );
      } else if (data["state"] == 2 || data["state"] == 3) {
        messageTable.updateAckStateMessage(
          messageId: data["messageId"].toString(),
          state: data["state"],
        );
      }

      messageAcknowledgement.value = MessageAckModel(
        clientSystemMessageId: data["clientSystemMessageId"].toString(),
        state: data["state"],
        messageId: data["messageId"],
      );
      //
    });

    _socket?.on('group-message-acknowledgement', (data) {
      print('✅ Group Message Ack: $data');
      // TODO: Update message status in DB
    });

    _socket?.on('user-connection-status', (data) async {
      print('✅ user connection status: $data');
      final int userId = int.parse(data['userId']);
      final bool isOnlineBool = data['isOnline'];
      final int isOnline = isOnlineBool ? 1 : 0;

      String? lastSeenTime;

      // Update only when user goes offline
      if (!isOnlineBool) {
        lastSeenTime = data['lastSeen'];
      }

      bool success = await contactsTable.updateUserOnlineStatus(
        userId,
        isOnline,
        lastSeenTime ?? '', // Pass empty string if user is online
      );

      print(success
          ? "✅ User status updated successfully: UserID: $userId Is Online: $isOnline Last Seen Time: $lastSeenTime"
          : "⚠️ No user found with that ID to update: UserID: $userId Is Online: $isOnline Last Seen Time: $lastSeenTime");
    });

    _socket?.on('typing', (data) {
      print('✅ user is typing: $data');
      print('📝 Typing event received: $data');

      final String senderId = data["userId"].toString();
      final bool isTyping = data["isTyping"] == true;

      // 👇 Save typing state in map for the current chat
      typingStatusMap[senderId] = isTyping;
    });

    _socket?.on('message-delete', (data) async {
      print('✅ Message Deleted: $data');
      final int messageId = data['messageId'];
      final bool isDeleteFromEveryOne = data['deleteState'];

      bool existsLocally = await messageTable.messageExists(messageId);
      if (existsLocally) {
        final msg = await messageTable.getMessageById(messageId);
        final isLast = await messageTable.isLastMessage(
          messageId: messageId,
          senderId: msg?.senderId ?? 0,
          receiverId: msg?.recipientId ?? 0,
        );

        if (isDeleteFromEveryOne) {
          await messageTable.updateMessageContent(
            messageId: messageId,
            newText: "This message was deleted",
            newType: MessageType.deleted,
          );
        } else {
          await messageTable.deleteMessage(messageId);
        }

        // 🔔 Notify controller
        deletedMessage.value = DeletedMessageModel(
          messageId: messageId,
          isDeleteFromEveryone: isDeleteFromEveryOne,
        );

        // Optional: update chat contact if last message
        if (isLast) {
          if (isDeleteFromEveryOne) {
            await chatConectTable.updateContact(
              uid: msg!.senderId.toString(),
              lastMessageId: 0,
              lastMessage: "This message was deleted",
              timeSent: msg.messageSentFromDeviceTime,
            );
          } else {
            final newLast = await messageTable.getLatestMessageForUser(
              msg?.recipientId ?? 0,
              msg?.senderId ?? 0,
            );
            if (newLast != null) {
              await chatConectTable.updateContact(
                lastMessageId: newLast.messageId,
                uid: msg!.recipientId.toString(),
                lastMessage: newLast.message,
                timeSent: newLast.clientSystemMessageId,
              );
            } else {
              await chatConectTable.updateContact(
                lastMessageId: 0,
                uid: msg!.recipientId.toString(),
                lastMessage: '',
                timeSent: '',
              );
            }
          }
        }
      } else {
        print("⚠️ Message ID $messageId not found locally. Skipping deletion.");
      }
    });

    _socket?.on('user-update', (data) async{
      print('✅ User Details Update: $data');
      UserData userDetails = UserData.fromJson(data["userData"]);
      updateContactUser.value = userDetails;
      // print("userData after json to model: $userDetails");
      await chatConectTable.updateContact(
        uid: userDetails.userId.toString(),
        profilePic:userDetails.displayPictureUrl,
      );
      await contactsTable.updateUserFields(
        userId: userDetails.userId ?? 0,
        name: userDetails.name,
        phoneNumber: userDetails.phoneNumber,
        email: userDetails.email,
        userDescription: userDetails.userDescription,
        displayPicture: userDetails.displayPicture,
        displayPictureUrl: userDetails.displayPictureUrl,
      );
    });

    _socket?.on('custom-error', (data) {
      print('🚫 Custom Error: $data');
    });
  }

  void sendMessage(NewMessageModel data) async {
    saveChatContacts(data);

    _socket?.emit('message-event', data.toMap());
  }

  void sendMessageSync(NewMessageModel data) async {
    _socket?.emit('message-event', data.toMap());
  }

  void sendMessageSeen(int messageId) {
    messageTable.updateAckStateMessage(
      messageId: messageId.toString(),
      state: 3,
    );
    _socket?.emit('message-seen', {
      "messageId": messageId,
    });
  }

  void checkUserOnline(Map<String, dynamic> data) {
    _socket?.emit('user-connection-status', data);
  }

  void emitTypingStatus({required String recipientId, required bool isTyping}) {
    _socket?.emit('typing', {
      "recipientId": recipientId,
      "isTyping": isTyping,
    });
  }

  void monitorReceiverTyping(String receiverUserId,
      void Function(bool isTyping) onTypingStatusChanged) {
    ever(typingStatusMap, (_) {
      if (typingStatusMap.containsKey(receiverUserId)) {
        onTypingStatusChanged(typingStatusMap[receiverUserId] == true);
      }
    });
  }

  void emitMessageDelete(
      {required int messageId, required bool isDeleteFromEveryOne}) {
    _socket?.emit('message-delete', {
      "messageId": messageId,
      "deleteState": isDeleteFromEveryOne,
    });
  }

  Future<void> disposeSocket() async {
    if (_socket?.connected == true) {
      _socket?.disconnect();
    }
    _clearSocketListeners();
    _socket?.dispose();
    _socket = null;
    print('🔌 Socket disposed manually');
  }

  void saveChatContacts(NewMessageModel data) async {
    // Try to get user from local contacts
    final user = await contactsTable.getUserById(data.recipientId!);
    // print('🔍 [saveChatContacts] Found user from contactsTable: ${user?.toMap()}');

    // If user is found, proceed as usual
    if (user != null) {
      final chatUser =
          await chatConectTable.fetchById(uid: user.userId.toString());

      if (chatUser != null) {
        await chatConectTable.updateContact(
          uid: user.userId.toString(),
          lastMessage: data.messageType == MessageType.image ?MessageType.image.value
              :data.messageType == MessageType.video ?MessageType.video.value
              :data.messageType == MessageType.document ?MessageType.document.value:data.message,
          lastMessageId: data.messageId,
          timeSent: data.messageSentFromDeviceTime,
          profilePic: user.displayPictureUrl,
          name: user.localName,
        );
      } else {
        await chatConectTable.insert(
          contact: ChatConntactModel(
            lastMessageId:data.messageId,
            contactId: user.userId.toString(),
            lastMessage: data.messageType == MessageType.image ?MessageType.image.value
                :data.messageType == MessageType.video ?MessageType.video.value
                :data.messageType == MessageType.document ?MessageType.document.value:data.message,
            name: user.localName,
            profilePic: user.displayPictureUrl,
            timeSent: data.messageSentFromDeviceTime,
            uid: user.userId.toString(),
          ),
        );
      }
    } else {
      // Handle unknown contact (not in your contacts table)
      final fallbackName = data.senderPhoneNumber ??
          "Unknown"; // You must pass senderPhoneNumber in NewMessageModel
      final fallbackUid = data.recipientId ?? "0";

      final chatUser =
          await chatConectTable.fetchById(uid: fallbackUid.toString());

      if (chatUser != null) {
        await chatConectTable.updateContact(
          uid: fallbackUid.toString(),
          lastMessage: data.messageType == MessageType.image ?MessageType.image.value
              :data.messageType == MessageType.video ?MessageType.video.value
              :data.messageType == MessageType.document ?MessageType.document.value:data.message,
          lastMessageId: data.messageId,
          timeSent: data.messageSentFromDeviceTime,
          profilePic: '', // or a default avatar
          name: fallbackName,
        );
      } else {
        await chatConectTable.insert(
          contact: ChatConntactModel(
            contactId: fallbackUid.toString(),
            lastMessageId: data.messageId,
            lastMessage: data.messageType == MessageType.image ?MessageType.image.value
                :data.messageType == MessageType.video ?MessageType.video.value
                :data.messageType == MessageType.document ?MessageType.document.value:data.message,
            name: fallbackName,
            profilePic: '',
            timeSent: data.messageSentFromDeviceTime,
            uid: fallbackUid.toString(),
          ),
        );

        await contactsTable.insertPlaceholderUser(
            userId: int.parse(fallbackUid.toString()),
            isOnline: 1,
            phoneNumber: fallbackName,
            localName: fallbackName);
      }
    }
  }

  Future<void> retryPendingDeletions() async {
    final pendingDeletions = await messageTable.getQueuedDeletions();

    for (var entry in pendingDeletions) {
      final messageId = entry['messageId'];
      final isDeleteFromEveryone = entry['deleteState'] as bool;

      // Retry emitting
      emitMessageDelete(
        messageId: messageId,
        isDeleteFromEveryOne: isDeleteFromEveryone,
      );

      // After successful retry, remove from queue
      await messageTable.removeQueuedDeletion(messageId);
    }
  }

  Future<void> syncPendingMessages({required int loginUserId}) async{
    final dbMessages = await messageTable.fetchAllPendingMessages(loginUserId: loginUserId);
    for(final msg in dbMessages){
      if(msg.isAsset == false) {
        sendMessageSync(msg);
      }
    }
  }
  void _clearSocketListeners() {
    _socket?.clearListeners();
    // _socket?.off('message-event');
    // _socket?.off('message-acknowledgement');
    // _socket?.off('group-message-acknowledgement');
    // _socket?.off('user-connection-status');
    // _socket?.off('typing');
    // _socket?.off('message-delete');
    // _socket?.off('custom-error');
  }
}
