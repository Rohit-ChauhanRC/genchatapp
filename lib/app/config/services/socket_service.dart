import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService extends GetxService {
  late IO.Socket _socket;
  IO.Socket get socket => _socket;

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

    _socket.on('custom-error', (data) {
      print('🚫 Custom Error: $data');
    });
  }

  void sendMessage(Map<String, dynamic> data) {
    _socket.emit('message-event', data);
  }

  void disposeSocket() {
    _socket.dispose();
  }
}
