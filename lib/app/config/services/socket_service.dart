import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../data/local_database/contacts_table.dart';
import '../../modules/singleChat/controllers/single_chat_controller.dart';

class SocketService extends GetxService {
  late IO.Socket _socket;
  IO.Socket get socket => _socket;

  final ContactsTable contactsTable = ContactsTable();

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
      // TODO: Insert to local SQLite DB
    });

    _socket.on('message-acknowledgement', (data) {
      print('✅ Message Ack: $data');
      // TODO: Update message status in DB
    });

    _socket.on('group-message-acknowledgement', (data) {
      print('✅ Group Message Ack: $data');
      // TODO: Update message status in DB
    });

    _socket.on('user-connection-status', (data) async{
      print('✅ user connection status: $data');
      final int userId = int.parse(data['userId']) ;
      final int isOnline = data['isOnline'] ? 1 : 0;

      // Update local DB
      await contactsTable.updateUserOnlineStatus(userId, isOnline);
    });

    _socket.on('typing', (data){
      print('✅ user is typing: $data');
    });

    _socket.on('custom-error', (data) {
      print('🚫 Custom Error: $data');
    });
  }

  void sendMessage(Map<String, dynamic> data) {
    _socket.emit('message-event', data);
  }

  void checkUserOnline(Map<String, dynamic> data){
    _socket.emit('user-connection-status', data);
  }

  void disposeSocket() {
    _socket.dispose();
  }
}
