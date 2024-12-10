import 'package:genchatapp/app/modules/singleChat/controllers/single_chat_controller.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService extends GetxController {
  // RxBool to track connectivity status
  var isConnected = false.obs;
// final singleChatController = Get.find<SingleChatController>();
  // Instance of Connectivity
  final Connectivity _connectivity = Connectivity();

  @override
  void onInit() {
    super.onInit();
    _initConnectivity();
    _listenToConnectivityChanges();
  }

  // Check the current connectivity status
  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      print("Error checking connectivity: $e");
    }
  }

  // Listen to connectivity changes
  void _listenToConnectivityChanges() {
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  // Update the connection status based on the result
  void _updateConnectionStatus(List<ConnectivityResult> result) {
    isConnected.value = !result.contains(ConnectivityResult.none);
    // Retry unsent messages when connected
    if (isConnected.value) {
      SingleChatController().retryPendingMessages();
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}
