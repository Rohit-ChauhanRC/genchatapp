import 'dart:convert';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:genchatapp/app/constants/constants.dart';

import 'package:get/get.dart';

import 'app/config/services/notification_service.dart';
import 'app/config/theme/app_theme.dart';
import 'app/data/repositories/status/status_repository.dart';
import 'app/network/app_config.dart';
import 'app/routes/app_pages.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app/constants/get_di.dart' as di;
import 'app/services/shared_preference_service.dart';

// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   await dotenv.load(fileName: ".env");
//   AppConfig.setEnvironment(AppEnvironment.prod);
//   await di.init();
//   final encryptionService = Get.find<EncryptionService>();
//   final contactsTable = ContactsTable();
//
//   print("🔥 Background Notification Received:");
//   print("Title: ${message.notification?.title}");
//   print("Body: ${message.notification?.body}");
//   print("Data: ${message.data}");
//   await NotificationService.showNotification(message, encryptionService, contactsTable);
// }

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("🔔 [BG] Background FCM Received");
  print("🔔 [BG] Title: ${message.notification?.title}");
  print("🔔 [BG] Body: ${message.notification?.body}");
  print("🔔 [BG] Raw Data: ${message.data}");

  await Firebase.initializeApp();
  await dotenv.load(fileName: ".env");
  await di.init();
  // Extract messageId for logging
  final rawData = message.data['data'];
  print("🔍 [BG] rawData field: $rawData");

  if (rawData != null) {
    try {
      final decoded = Map<String, dynamic>.from(jsonDecode(rawData));
      final messageId = decoded['messageId']?.toString();
      print("🆔 [BG] Decoded messageId: $messageId");
      if (messageId != null && messageId.isNotEmpty) {
        // 🚨 Add this line to prevent repeat
        await NotificationService.addShownMessageId(messageId);
      }
    } catch (e) {
      print("❌ [BG] Error decoding messageId: $e");
    }
  }
  // await NotificationService.init();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp();
  await di.init();

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  await NotificationService.init();

  NotificationSettings settings = await FirebaseMessaging.instance
      .requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: true,
        criticalAlert: true,
        provisional: true,
        sound: true,
      );
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true, // Required to display a heads up notification
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('Notification permission granted');
  } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
    print(' Notification permission denied');
  } else {
    print('Notification permission not determined');
  }

  AppConfig.setEnvironment(AppEnvironment.dev);

  runApp(const App());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      title: appName,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      theme: AppTheme.theme,
    );
  }
}

///AwesomeNotification
// AwesomeNotifications().initialize(
//   null,
//   [
//     NotificationChannel(
//       channelKey: NotificationService.chatChannelKey,
//       channelName: 'Chats',
//       channelDescription: 'Chat messages',
//       importance: NotificationImportance.High,
//       channelShowBadge: true,
//       groupKey: NotificationService.groupKey,
//     ),
//     NotificationChannel(
//       channelKey: NotificationService.summaryChannelKey,
//       channelName: 'Summary',
//       channelDescription: 'Message summaries',
//       importance: NotificationImportance.High,
//       channelShowBadge: false,
//       locked: true,
//     ),
//   ],
//   debug: true,
// );

// AwesomeNotifications().setListeners(
//   onActionReceivedMethod: NotificationService.onActionReceived,
// );
//
// bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
// if (!isAllowed) {
//   isAllowed = await AwesomeNotifications().requestPermissionToSendNotifications();
//   print("🔔 AwesomeNotification permission granted: $isAllowed");
// }
// await NotificationService.loadShownIdsOnce();
// FirebaseMessaging.onMessage.listen((RemoteMessage msg) async {
//   print("🔔 Foreground FCM Received Title: ${msg.notification?.title}");
//   print("🔔 Foreground FCM Received Body: ${msg.notification?.body}");
//   print("🔔 Foreground FCM Received Data: ${msg.data}");
//
//   // await NotificationService.loadShownIdsOnce(force: true);
//   // final rawData = msg.data['data'];
//   // if (rawData == null) return;
//   //
//   // final data = rawData is String ? jsonDecode(rawData) : rawData;
//   // final id = data['messageId'];
//   // if (id == null) return;
//   //
//   // await NotificationService.loadShownIdsOnce();
//   // if (NotificationService.isDuplicate(id)) {
//   //   print("⚠️ Foreground: Skipping duplicate $id");
//   //   return;
//   // }
//   //
//   // print("✅ Showing notification $id in foreground");
//   // await NotificationService.showAwesomeNotification(msg);
// });
///
// await NotificationService.initialize((String? payload) {
//   if (payload != null) {
//     final data = jsonDecode(payload);
//     final chatId = data['chatId'];
//     NotificationService.messageCache.remove(chatId);
//     NotificationService.activeThreads.remove(chatId);
//     NotificationService.removeShownMessagesForChat(chatId);
//
//     if (chatId.startsWith("user_")) {
//       final id = int.parse(chatId.replaceFirst("user_", ""));
//       print("User Tap on Message with Id:----> $id");
//       // navigatorKey.currentState?.pushNamed("/chat", arguments: {"userId": id});
//     } else if (chatId.startsWith("group_")) {
//       final id = int.parse(chatId.replaceFirst("group_", ""));
//       print("User Tap on Group Message with Id:----> $id");
//       // navigatorKey.currentState?.pushNamed("/groupChat", arguments: {"groupId": id});
//     }
//   }
// });

// FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//   print("🔔 Foreground Notification Received:");
//   print("Title: ${message.notification?.title}");
//   print("Body: ${message.notification?.body}");
//   print("Data: ${message.data}");
//   final data = jsonDecode(message.data['data']);
//   final messageId = data['messageId'];
//
//   // ✅ Prevent duplicate notification when app resumes
//   if (NotificationService.hasAlreadyShown(messageId)) {
//     print("⚠️ Skipping duplicate foreground message: $messageId");
//     return;
//   }
//
//   final encryptionService = Get.find<EncryptionService>();
//   final contactsTable = ContactsTable();
//   NotificationService.showNotification(message, encryptionService, contactsTable);
// });
