import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:genchatapp/app/config/assets/app_images.dart';
import 'package:genchatapp/app/services/shared_preference_service.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import '../../common/user_defaults/user_defaults_keys.dart';
import '../../constants/constants.dart';
import '../../constants/message_enum.dart';
import '../../utils/message_id_storage.dart';
import 'encryption_service.dart';

@pragma('vm:entry-point')
Future<void> onNotificationBackgroundResponse(NotificationResponse response) async {
  debugPrint("📲 [BG Callback] Payload: ${response.payload}");

  if (response.payload != null && response.payload!.isNotEmpty) {
    await NotificationService.removeShownMessageId(response.payload!);
  }
}

class NotificationService{
  static final encryptionService = Get.find<EncryptionService>();
  static final prefs = Get.find<SharedPreferenceService>();

  static String shownMessageIdsKey = UserDefaultsKeys.shownMessageIdsKeys;

  static Future<List<String>> getShownMessageIds() async {
    final ids = await MessageIdStorage.load();
    debugPrint("📦 [Prefs] Cleaned shownMessageIds: $ids");
    return ids;
  }

  static Future<void> addShownMessageId(String id) async {
    await MessageIdStorage.add(id);
    debugPrint("✅ [Prefs] Added messageId to shown list: $id");
  }

  static Future<void> removeShownMessageId(String id) async {
    await MessageIdStorage.remove(id);
    debugPrint("🧹 Removed messageId: $id from shownIds");
  }

  static Future<void> clearAllShownMessageIds() async {
    await MessageIdStorage.clear();
  }

  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    print("🔧 NotificationService.init() called");
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
    InitializationSettings(android: androidSettings);

    await _localNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        debugPrint("📲 [Foreground Tap] Payload: ${response.payload}");
        _onNotificationTapOrDismiss(response);
      },
        onDidReceiveBackgroundNotificationResponse: onNotificationBackgroundResponse
    );

    // iOS is ignored because you only want Android foreground support
    FirebaseMessaging.onMessage.listen((msg) {
      debugPrint("📨 [onMessage.listen] Message received");
      _handleForegroundMessage(msg);
    });
  }

  static Future<void> _handleForegroundMessage(RemoteMessage msg) async {
    print("🟢 [Foreground] Handling FCM");
    print("🟢 Title: ${msg.notification?.title}");
    print("🟢 Body: ${msg.notification?.body}");
    print("🟢 Raw Data: ${msg.data}");

    final String? rawData = msg.data['data'];
    print("🔍 [FG] rawData: $rawData");

    Map<String, dynamic>? decoded;
    String messageId = msg.messageId ?? '';

    if (rawData != null) {
      try {
        decoded = Map<String, dynamic>.from(jsonDecode(rawData));
        messageId = decoded['messageId']?.toString() ?? messageId;
        print("🆔 [FG] Extracted messageId: $messageId");
      } catch (e) {
        print("❌ [FG] Error decoding rawData: $e");
      }
    }

    final shownIds = await getShownMessageIds();
    print("📦 [Dedup Check] Stored IDs: $shownIds");
    print("📦 [Dedup Check] Incoming ID: $messageId");
    if (shownIds.contains(messageId)) {
      debugPrint('⚠️ Duplicate notification ignored: $messageId');
      return;
    }
    print("🔔 [FG] Showing notification for messageId: $messageId");
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'foreground_channel_id',
      'Foreground Notifications',
      channelDescription: 'Used for showing foreground notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _localNotificationsPlugin.show(
      msg.hashCode,
      msg.notification?.title ?? '',
      msg.notification?.body ?? '',
      notificationDetails,
      payload: messageId,
    );
    await addShownMessageId(messageId);
  }

  static Future<void> _onNotificationTapOrDismiss(NotificationResponse response) async {
    final payload = response.payload;
    debugPrint('📲 [Tap/Dismiss] Type: ${response.notificationResponseType}');
    debugPrint('📲 [Tap/Dismiss] Payload: $payload');

    if (payload != null && payload.isNotEmpty) {
      await removeShownMessageId(payload);
    }
  }


  static Future<String> _resolveIconPath(String? dispPic) async {
    final dir = await getApplicationDocumentsDirectory();
    if (dispPic != null) {
      final file = File('${dir.path}/${dispPic.replaceAll(".jpg", ".png")}');
      if (await file.exists()) return file.path;
    }

    final def = File('${dir.path}/default_dp.png');
    if (!await def.exists()) {
      final data = await rootBundle.load(AppImages.dummyPersonImage);
      await def.writeAsBytes(data.buffer.asUint8List());
    }
    return def.path;
  }

  static String _mapTypeToEmoji(MessageType type) {
    return {
      MessageType.image: '📷 Photo',
      MessageType.video: '🎥 Video',
      MessageType.document: '📄 Document',
      MessageType.audio: '🔉 Audio',
      MessageType.gif: '🎁 GIF',
    }[type] ?? '';
  }

  static Future<void> subscribeToTopics(List<String> topics) async {
    List<String> cleanedTopics =
    topics.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    for (String topic in cleanedTopics) {
      await FirebaseMessaging.instance.subscribeToTopic(topic);
      print("✅ Subscribed to topic: $topic");
    }

    // Save subscribed topics in SharedPreferenceService, avoiding duplicates
    List<String>? existingTopics = prefs.getList(subscribedTopics) ?? [];
    Set<String> updatedTopics = {
      ...existingTopics,
      ...cleanedTopics
    }; // Merge sets to avoid duplicates
    await prefs.setList(subscribedTopics, updatedTopics.toList());
  }

  /// Unsubscribe from stored topics and clear from SharedPreferences
  static Future<void> unsubscribeFromTopics() async {
    List<String>? topics = prefs.getList(subscribedTopics);

    if (topics != null) {
      for (String topic in topics) {
        await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
        print("❌ Unsubscribed from topic: $topic");
      }
      await prefs.remove(subscribedTopics); // Clear stored topics
    }
  }
}

///Flutter AwesomeNotifications code
// class NotificationService {
//   static final encryptionService = Get.find<EncryptionService>();
//   static final prefs = Get.find<SharedPreferenceService>();
//   static bool _loaded = false;
//
//   static const chatChannelKey = 'chat_channel';
//   static const summaryChannelKey = 'summary_channel';
//   static const groupKey = 'genchat_group';
//
//   static final Map<String, List<NotificationContent>> _cache = {};
//   static final Set<int> shownIds = {};
//   static final Set<int> _runtimeHandledIds = {};
//
//
//   static Future<void> loadShownIdsOnce({bool force = false}) async {
//     if (_loaded && !force) return;
//     final ids = prefs.getList('shown_message_ids') ?? [];
//     shownIds
//       ..clear()
//       ..addAll(ids.map(int.parse));
//     _loaded = true;
//     print('📥 [loadShownIdsOnce] loaded IDs: $shownIds');
//   }
//
//   static Future<void> saveShownId(int id) async {
//     final ids = prefs.getList('shown_message_ids') ?? [];
//     if (!ids.contains(id.toString())) {
//       ids.add(id.toString());
//       await prefs.setList('shown_message_ids', ids);
//       print('💾 Saved messageId: $id to persistent storage.');
//     } else {
//       print('ℹ️ messageId: $id already exists in storage.');
//     }
//   }
//
//   static bool isDuplicate(int id) {
//     return shownIds.contains(id) || _runtimeHandledIds.contains(id);
//   }
//
//   static Future<void> showAwesomeNotification(RemoteMessage msg) async {
//     print("🔔 [showAwesomeNotification] Message: ${msg.data}");
//     // await loadShownIdsOnce();
//
//     final rawData = msg.data['data'];
//     if (rawData == null) return;
//
//     final data = jsonDecode(rawData);
//     final newMsg = NewMessageModel.fromMap(data);
//     final id = newMsg.messageId;
//     if (id == null) return;
//
//     if (isDuplicate(id)) {
//       print("⚠️ Duplicate messageId: $id");
//       return;
//     }
//
//     shownIds.add(id);
//     _runtimeHandledIds.add(id);
//
//     await saveShownId(id);
//
//     final isGroup = newMsg.isGroupMessage == true;
//     final chatId = isGroup ? 'group_${newMsg.recipientId}' : 'user_${newMsg.senderId}';
//
//     final user = await ContactsTable().getUserById(newMsg.senderId ?? 0);
//     final displayName = user?.localName ?? user?.phoneNumber ?? 'Unknown';
//     final iconPath = await _resolveIconPath(user?.displayPicture);
//
//     final body = newMsg.messageType != MessageType.text
//         ? _mapTypeToEmoji(newMsg.messageType!)
//         : encryptionService.decryptText(newMsg.message ?? '');
//
//     final content = NotificationContent(
//       id: id,
//       channelKey: chatChannelKey,
//       title: displayName,
//       body: body,
//       payload: {'chatId': chatId},
//       groupKey: groupKey,
//       notificationLayout: NotificationLayout.Messaging,
//       largeIcon: 'file://$iconPath',
//       roundedLargeIcon: true,
//     );
//
//     _cache.putIfAbsent(chatId, () => []).add(content);
//     if (_cache[chatId]!.length > 7) _cache[chatId]!.removeAt(0);
//
//     await AwesomeNotifications().createNotification(content: content);
//
//     if (_cache.length > 1) {
//       final total = _cache.values.expand((l) => l).length;
//       await AwesomeNotifications().createNotification(
//         content: NotificationContent(
//           id: 0,
//           channelKey: summaryChannelKey,
//           title: '${_cache.length} chats',
//           body: '$total new messages',
//           groupKey: groupKey,
//           notificationLayout: NotificationLayout.Inbox,
//           locked: true,
//         ),
//       );
//     }
//   }
//
//   static Future<String> _resolveIconPath(String? dispPic) async {
//     final dir = await getApplicationDocumentsDirectory();
//     if (dispPic != null) {
//       final file = File('${dir.path}/${dispPic.replaceAll(".jpg", ".png")}');
//       if (await file.exists()) return file.path;
//     }
//
//     final def = File('${dir.path}/default_dp.png');
//     if (!await def.exists()) {
//       final data = await rootBundle.load(AppImages.dummyPersonImage);
//       await def.writeAsBytes(data.buffer.asUint8List());
//     }
//     return def.path;
//   }
//
//   static String _mapTypeToEmoji(MessageType type) {
//     return {
//       MessageType.image: '📷 Photo',
//       MessageType.video: '🎥 Video',
//       MessageType.document: '📄 Document',
//       MessageType.audio: '🔉 Audio',
//       MessageType.gif: '🎁 GIF',
//     }[type] ?? '';
//   }
//
//   @pragma('vm:entry-point')
//   static Future<void> onActionReceived(ReceivedAction action) async {
//     final chatId = action.payload?['chatId'];
//     if (chatId != null) {
//       await clearChatNotification(chatId);
//     }
//   }
//
//
//   // Future<void> subscribeToUserTopic(String userId) async {
//   //   final topic = "genchat-message-$userId";
//   //   await FirebaseMessaging.instance.subscribeToTopic(topic);
//   // }
//   //
//   // Future<void> unSubscribeToUserTopic(String userId) async {
//   //   final topic = "genchat-message-$userId";
//   //   await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
//   // }
//
//   static Future<void> subscribeToTopics(List<String> topics) async {
//     List<String> cleanedTopics =
//     topics.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
//
//     for (String topic in cleanedTopics) {
//       await FirebaseMessaging.instance.subscribeToTopic(topic);
//       print("✅ Subscribed to topic: $topic");
//     }
//
//     // Save subscribed topics in SharedPreferenceService, avoiding duplicates
//     List<String>? existingTopics = prefs.getList(subscribedTopics) ?? [];
//     Set<String> updatedTopics = {
//       ...existingTopics,
//       ...cleanedTopics
//     }; // Merge sets to avoid duplicates
//     await prefs.setList(subscribedTopics, updatedTopics.toList());
//   }
//
//   /// Unsubscribe from stored topics and clear from SharedPreferences
//   static Future<void> unsubscribeFromTopics() async {
//     List<String>? topics = prefs.getList(subscribedTopics);
//
//     if (topics != null) {
//       for (String topic in topics) {
//         await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
//         print("❌ Unsubscribed from topic: $topic");
//       }
//       await prefs.remove(subscribedTopics); // Clear stored topics
//     }
//   }
//
//   static Future<void> clearChatNotification(String chatId) async {
//     _cache.remove(chatId); // remove message cache
//     await AwesomeNotifications().cancelNotificationsByGroupKey(groupKey);
//     // int id = int.parse(chatId);
//     // var chatIds = [id];
//     // await removeShownIds(chatIds);
//     // Also remove message IDs for this chat (optional)
//     // Keep this clean-up lightweight to avoid breaking shared cache logic
//   }
//
//   /// Remove selected messageIds from shownIds and runtimeHandledIds
//   /// ❗ NEW METHOD: Call this to clear shown IDs for displayed messages
//   static Future<void> removeShownIds(int id) async {
//     final ids = prefs.getList('shown_message_ids') ?? [];
//     if (ids.contains(id.toString())) {
//       final updatedIds = ids.where((element) => element != id.toString()).toList();
//       await prefs.setList('shown_message_ids', updatedIds);
//       print('🗑️ Removed messageId: $id from storage.');
//       shownIds.remove(id);
//     } else {
//       print('⚠️ Tried to remove messageId: $id, but it was not found.');
//     }
//   }
//
//
// }
///Flutter Local Notifications code
// @pragma('vm:entry-point')
// Future<void> onBackgroundNotificationTap(NotificationResponse response) async {
//   if (response.payload != null) {
//     final data = jsonDecode(response.payload!);
//     final chatId = data['chatId'];
//     NotificationService.messageCache.remove(chatId);
//     NotificationService.activeThreads.remove(chatId);
//     NotificationService.removeShownMessagesForChat(chatId);
//     // Cannot navigate here because it's background
//     // Instead, clear cache
//     final plugin = FlutterLocalNotificationsPlugin();
//     await plugin.cancel(chatId.hashCode); // removes that notification
//     await plugin.cancel(0); // removes summary if needed
//   }
// }
//
// class NotificationService {
//   static final FlutterLocalNotificationsPlugin _notificationsPlugin =
//   FlutterLocalNotificationsPlugin();
//
//   static final Set<int> _shownMessageIds = {};
//
//   static final Map<String, List<Message>> messageCache = {};
//   static final Set<String> activeThreads = {};
//
//   static Future<void> initialize(Function(String?) onNotificationTap) async {
//     const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
//
//     const iosSettings = DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//     );
//     const settings = InitializationSettings(
//       android: androidSettings,
//       iOS: iosSettings,
//     );
//
//     await _notificationsPlugin.initialize(
//       settings,
//       onDidReceiveNotificationResponse: (response) {
//         if (response.payload != null) {
//           onNotificationTap(response.payload);
//         }
//       },
//       onDidReceiveBackgroundNotificationResponse: onBackgroundNotificationTap, // ✅ here
//     );
//
//
//     const userChannel = AndroidNotificationChannel(
//       'chat_channel', 'Chats',
//       description: 'Notifications for 1-to-1 chats',
//       importance: Importance.high,
//     );
//
//     const groupChannel = AndroidNotificationChannel(
//       'group_channel', 'Group Chats',
//       description: 'Notifications for group chats',
//       importance: Importance.high,
//     );
//
//     await _notificationsPlugin
//         .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
//         ?.createNotificationChannel(userChannel);
//
//     await _notificationsPlugin
//         .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
//         ?.createNotificationChannel(groupChannel);
//   }
//
//   static Future<void> showNotification(
//       RemoteMessage message,
//       EncryptionService encryptionService,
//       ContactsTable contactsTable,
//       ) async {
//     try {
//       final data = jsonDecode(message.data['data']);
//       final NewMessageModel newMessage = NewMessageModel.fromMap(data);
//
//       // ✅ Prevent duplicate
//       if (_shownMessageIds.contains(newMessage.messageId)) {
//         print("⚠️ Skipping duplicate message: ${newMessage.messageId}");
//         return;
//       }
//       _shownMessageIds.add(newMessage.messageId!);
//
//       final bool isGroup = newMessage.isGroupMessage == true;
//
//       final String cacheKey = isGroup
//           ? "group_${newMessage.recipientId}"
//           : "user_${newMessage.senderId}";
//
//       final UserList? user = await contactsTable.getUserById(newMessage.senderId ?? 0);
//       final String senderName = user?.localName ?? user?.phoneNumber ?? 'Unknown';
//       final String? groupName = isGroup ? user?.userDescription : null;
//
//       final directory = await getApplicationDocumentsDirectory();
//       final String? localImagePath = user?.displayPicture != null
//           ? '${directory.path}/${user!.displayPicture!.replaceAll(".jpg", ".png")}'
//           : null;
//
//       String iconPath = localImagePath != null && await File(localImagePath).exists()
//           ? localImagePath
//           : await _getFallbackDp();
//
//       final displayContent = switch (newMessage.messageType) {
//         MessageType.image => '📷 Photo',
//         MessageType.video => '🎥 Video',
//         MessageType.document => '📄 Document',
//         MessageType.audio => '🔉 Audio',
//         MessageType.gif => '🎁 GIF',
//         _ => encryptionService.decryptText(newMessage.message ?? "")
//       };
//
//       final person = Person(
//         name: senderName,
//         key: cacheKey,
//         icon: BitmapFilePathAndroidIcon(iconPath),
//       );
//
//       // Add message to thread
//       messageCache.putIfAbsent(cacheKey, () => []);
//       messageCache[cacheKey]!.add(Message(displayContent, DateTime.now(), person));
//
//       // Trim to 7
//       if (messageCache[cacheKey]!.length > 7) {
//         messageCache[cacheKey] = messageCache[cacheKey]!.sublist(
//           messageCache[cacheKey]!.length - 7,
//         );
//       }
//
//       activeThreads.add(cacheKey);
//
//       final style = MessagingStyleInformation(
//         person,
//         groupConversation: isGroup,
//         conversationTitle: isGroup ? groupName : null,
//         messages: messageCache[cacheKey]!,
//       );
//
//       final androidDetails = AndroidNotificationDetails(
//         isGroup ? 'group_channel' : 'chat_channel',
//         isGroup ? 'Group Chats' : 'Chats',
//         importance: Importance.high,
//         priority: Priority.high,
//         styleInformation: style,
//         playSound: true,
//         enableVibration: true,
//         groupKey: 'genchat_group',
//         setAsGroupSummary: false,
//       );
//
//       final iosDetails = DarwinNotificationDetails(
//         threadIdentifier: cacheKey,
//         presentAlert: true,
//         presentBadge: true,
//         presentSound: true,
//       );
//
//       await _notificationsPlugin.show(
//         cacheKey.hashCode,
//         null,
//         null,
//         NotificationDetails(
//           android: androidDetails,
//           iOS: iosDetails,
//         ),
//         payload: jsonEncode({"chatId": cacheKey}),
//       );
//
//       // Group Summary (like WhatsApp)
//       if (Platform.isAndroid && activeThreads.length > 1) {
//         final summary = AndroidNotificationDetails(
//           'summary_channel',
//           'Message Summary',
//           groupKey: 'genchat_group',
//           setAsGroupSummary: true,
//           styleInformation: InboxStyleInformation(
//             [],
//             contentTitle: '${activeThreads.length} chats',
//             summaryText: '${_countTotalMessages()} messages from ${activeThreads.length} chats',
//           ),
//         );
//
//         await _notificationsPlugin.show(
//           0,
//           'GenChat',
//           '${_countTotalMessages()} messages from ${activeThreads.length} chats',
//           NotificationDetails(android: summary),
//         );
//       }
//     } catch (e) {
//       print("❌ Notification error: $e");
//     }
//   }
//
//   static Future<String> _getFallbackDp() async {
//     final dir = await getApplicationDocumentsDirectory();
//     final fallback = '${dir.path}/default_dp.png';
//     if (!await File(fallback).exists()) {
//       final bytes = await rootBundle.load(AppImages.dummyPersonImage);
//       await File(fallback).writeAsBytes(bytes.buffer.asUint8List());
//     }
//     return fallback;
//   }
//
//   static int _countTotalMessages() {
//     return messageCache.values.fold(0, (sum, list) => sum + list.length);
//   }
//
//   static void removeShownMessagesForChat(String chatId) {
//     final messages = messageCache[chatId];
//     if (messages != null) {
//       for (var m in messages) {
//         // Assuming `messageId` is stored, otherwise track differently
//         _shownMessageIds.removeWhere((id) => true); // or refine if needed
//       }
//     }
//   }
//   static bool hasAlreadyShown(int messageId) {
//     return _shownMessageIds.contains(messageId);
//   }
//
//
//
//   Future<void> subscribeToUserTopic(String userId) async {
//     final topic = "genchat-message-$userId";
//     await FirebaseMessaging.instance.subscribeToTopic(topic);
//     print("✅ Subscribed to topic: $topic");
//   }
//
//   Future<void> unSubscribeToUserTopic(String userId) async {
//     final topic = "genchat-message-$userId";
//     await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
//     print("✅ unSubscribed to topic: $topic");
//   }
//
// }
