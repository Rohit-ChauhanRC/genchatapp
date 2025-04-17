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

  Future<void> initSocket(String userId) async {
    _socket = IO.io(
      'http://app.maklife.in:10000',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setQuery({'userId': userId})
          .build(),
    );

    _socket.connect();

    _socket.onConnect((_) {
      print('✅ Socket connected');
      _isConnected.value = true;
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
          state: MessageState.delivered));

      saveChatContacts(NewMessageModel(
          message: data["message"],
          senderId: data["recipientId"],
          messageId: data["messageId"],
          recipientId: data["senderId"],
          messageSentFromDeviceTime: data["messageSentFromDeviceTime"],
          state: MessageState.delivered));
    });

    _socket.on('message-acknowledgement', (data) async {
      print('✅ Message Ack: $data');
      if (data["state"] == 1) {
        NewMessageModel? newModel = await messageTable
            .getMessageByClientID(data["clientSystemMessageId"].toString());
        if (newModel != null) {
          newModel = newModel.copyWith(
              state: MessageState.sent, messageId: data["messageId"]);
          messageTable.updateAckMessage(
              data["clientSystemMessageId"].toString(), newModel);
        }
      } else if (data["state"] == 2) {
        NewMessageModel? newModel =
            await messageTable.getMessageById(data["messageId"]);
        if (newModel != null) {
          messageTable.updateMessage(newModel.copyWith(
              state: MessageState.delivered, messageId: data["messageId"]));
        }
      } else if (data["state"] == 3) {
        NewMessageModel? newModel =
            await messageTable.getMessageById(data["messageId"]);
        if (newModel != null) {
          newModel.copyWith(
              state: MessageState.read, messageId: data["messageId"]);

          messageTable.updateMessage(newModel);
        }
      }
      // TODO: Update message status in DB
    });

    _socket.on('group-message-acknowledgement', (data) {
      print('✅ Group Message Ack: $data');
      // TODO: Update message status in DB
    });

    _socket.on('user-connection-status', (data) async {
      print('✅ user connection status: $data');
      final int userId = int.parse(data['userId']);
      final int isOnline = data['isOnline'] ? 1 : 0;

      // Update local DB
      await contactsTable.updateUserOnlineStatus(userId, isOnline);
    });

    _socket.on('typing', (data) {
      print('✅ user is typing: $data');
    });

    _socket.on('custom-error', (data) {
      print('🚫 Custom Error: $data');
    });
  }

  void sendMessage(NewMessageModel data) async {
    saveChatContacts(data);

    _socket.emit('message-event', data.toMap());
  }

  void sendMessageSeen(int messageId) {
    _socket.emit('message-seen', {
      "messageId": messageId,
    });
  }

  void checkUserOnline(Map<String, dynamic> data) {
    _socket.emit('user-connection-status', data);
  }

  void disposeSocket() {
    _socket.dispose();
  }

  void saveChatContacts(
    NewMessageModel data,
  ) async {
    final user = await contactsTable.getUserById(data.recipientId!);
    final chatUser =
        await chatConectTable.fetchById(uid: user!.userId.toString());
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
        timeSent: DateTime.parse(data.messageSentFromDeviceTime.toString()),
        uid: user.userId.toString(),
      ));
    }
  }
}
