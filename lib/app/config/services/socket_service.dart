import 'package:genchatapp/app/constants/message_enum.dart';
import 'package:genchatapp/app/data/local_database/chatconnect_table.dart';
import 'package:genchatapp/app/data/local_database/message_table.dart';
import 'package:genchatapp/app/data/models/chat_conntact_model.dart';
import 'package:genchatapp/app/data/models/new_models/response_model/new_message_model.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../data/local_database/contacts_table.dart';
import '../../modules/singleChat/controllers/single_chat_controller.dart';

class SocketService extends GetxService {
  late IO.Socket _socket;
  IO.Socket get socket => _socket;

  final ContactsTable contactsTable = ContactsTable();

  final ChatConectTable chatConectTable = ChatConectTable();

  final MessageTable messageTable = MessageTable();

  final RxBool _isConnected = false.obs;
  bool get isConnected => _isConnected.value;

  final RxMap<String, bool> typingStatusMap = <String, bool>{}.obs;

  Future<void> initSocket(String userId,{Function()? onConnected}) async {
    _socket = IO.io(
      'http://app.maklife.in:10000',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .setQuery({'userId': userId})
          .build(),
    );

    _socket.connect();

    _socket.onConnect((_) {
      print('✅ Socket connected');
      _isConnected.value = true;
      onConnected?.call();
    });

    _socket.onDisconnect((_) {
      print('❌ Socket disconnected');
      _isConnected.value = false;
    });

    _socket.onError((data) {
      print('⚠️ Socket error: $data');
    });

    // Add your custom events here
    _socket.on('message-event', (data) {
      print('📩 Message received: $data');
      //
      messageTable.insertMessage(NewMessageModel(
          message: data["message"],
          senderId: data["senderId"],
          messageId: data["messageId"],
          recipientId: data["recipientId"],
          messageSentFromDeviceTime: data["messageSentFromDeviceTime"],
          state: MessageState.sent,
        senderPhoneNumber: data["senderPhoneNumber"]

      ));

      saveChatContacts(NewMessageModel(
          message: data["message"],
          senderId: data["recipientId"],
          messageId: data["messageId"],
          recipientId: data["senderId"],
          messageSentFromDeviceTime: data["messageSentFromDeviceTime"],
          state: MessageState.sent,
        senderPhoneNumber: data["senderPhoneNumber"]
      ));
    });

    _socket.on('message-acknowledgement', (data) async {
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
      //
    });

    _socket.on('group-message-acknowledgement', (data) {
      print('✅ Group Message Ack: $data');
      // TODO: Update message status in DB
    });

    _socket.on('user-connection-status', (data) async {
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

      print(success ? "✅ User status updated successfully: UserID: $userId Is Online: $isOnline Last Seen Time: $lastSeenTime"
          : "⚠️ No user found with that ID to update: UserID: $userId Is Online: $isOnline Last Seen Time: $lastSeenTime");

    });

    _socket.on('typing', (data) {
      print('✅ user is typing: $data');
      print('📝 Typing event received: $data');

      final String senderId = data["userId"].toString();
      final bool isTyping = data["isTyping"] == true;

      // 👇 Save typing state in map for the current chat
      typingStatusMap[senderId] = isTyping;
    });

    _socket.on('message-delete', (data){
      print('✅ Message Deleted: $data');
      final int messageId = data['messageId'];
      final bool isDeleteFromEveryOne = data['deleteState'];
      
    });

    _socket.on('custom-error', (data) {
      print('🚫 Custom Error: $data');
    });
  }

  void sendMessage(NewMessageModel data) async {
    saveChatContacts(data);

    _socket.emit('message-event', data.toMap());
  }

  void sendMessageSync(NewMessageModel data) async {
    _socket.emit('message-event', data.toMap());
  }

  void sendMessageSeen(int messageId) {
    messageTable.updateAckStateMessage(
      messageId: messageId.toString(),
      state: 3,
    );
    _socket.emit('message-seen', {
      "messageId": messageId,
    });
  }

  void checkUserOnline(Map<String, dynamic> data) {
    _socket.emit('user-connection-status', data);
  }

  void emitTypingStatus({required String recipientId, required bool isTyping}) {
    _socket.emit('typing', {
      "recipientId": recipientId,
      "isTyping": isTyping,
    });
  }

  void monitorReceiverTyping(
      String receiverUserId, void Function(bool isTyping) onTypingStatusChanged) {
    ever(typingStatusMap, (_) {
      if (typingStatusMap.containsKey(receiverUserId)) {
        onTypingStatusChanged(typingStatusMap[receiverUserId] == true);
      }
    });
  }

  void emitMessageDelete({required int messageId, required bool isDeleteFromEveryOne}) {
    _socket.emit('message-delete', {
      "messageId": messageId,
      "deleteState": isDeleteFromEveryOne,
    });
  }

  void disposeSocket() {
    _socket.dispose();
  }

  void saveChatContacts(NewMessageModel data) async {
    // Try to get user from local contacts
    final user = await contactsTable.getUserById(data.recipientId!);
    // print('🔍 [saveChatContacts] Found user from contactsTable: ${user?.toMap()}');

    // If user is found, proceed as usual
    if (user != null) {
      final chatUser = await chatConectTable.fetchById(uid: user.userId.toString());

      if (chatUser != null) {
        await chatConectTable.updateContact(
          uid: user.userId.toString(),
          lastMessage: data.message,
          timeSent: data.messageSentFromDeviceTime,
          profilePic: user.displayPictureUrl,
          name: user.localName,
        );
      } else {
        await chatConectTable.insert(
          contact: ChatConntactModel(
            contactId: user.userId.toString(),
            lastMessage: data.message,
            name: user.localName,
            profilePic: user.displayPictureUrl,
            timeSent: data.messageSentFromDeviceTime,
            uid: user.userId.toString(),
          ),
        );
      }
    } else {
      // Handle unknown contact (not in your contacts table)
      final fallbackName = data.senderPhoneNumber ?? "Unknown"; // You must pass senderPhoneNumber in NewMessageModel
      final fallbackUid = data.recipientId ?? "0";

      final chatUser = await chatConectTable.fetchById(uid: fallbackUid.toString());

      if (chatUser != null) {
        await chatConectTable.updateContact(
          uid: fallbackUid.toString(),
          lastMessage: data.message,
          timeSent: data.messageSentFromDeviceTime,
          profilePic: '', // or a default avatar
          name: fallbackName,
        );
      } else {
        await chatConectTable.insert(
          contact: ChatConntactModel(
            contactId: fallbackUid.toString(),
            lastMessage: data.message,
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
            localName: fallbackName
        );
      }
    }
  }

}
