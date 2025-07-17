import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:genchatapp/app/constants/constants.dart';

import 'package:get/get.dart';

import 'app/config/services/notification_service.dart';
import 'app/config/theme/app_theme.dart';
import 'app/network/app_config.dart';
import 'app/routes/app_pages.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app/constants/get_di.dart' as di;

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
  await Firebase.initializeApp();
  await dotenv.load(fileName: ".env");
  await di.init();
  // await NotificationService.loadShownIdsOnce(force: true);
  // await NotificationService.showAwesomeNotification(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp();

  await di.init();

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

  NotificationSettings settings = await FirebaseMessaging.instance
      .requestPermission(alert: true, badge: true, sound: true);

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('✅ Notification permission granted');
  } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
    print('❌ Notification permission denied');
  } else {
    print('⚠️ Notification permission not determined');
  }
  // await NotificationService.loadShownIdsOnce();
  FirebaseMessaging.onMessage.listen((msg) async {
    print("🔔 Foreground FCM Received Title: ${msg.notification?.title}");
    print("🔔 Foreground FCM Received Body: ${msg.notification?.body}");
    print("🔔 Foreground FCM Received Data: ${msg.data}");

    // await NotificationService.loadShownIdsOnce(force: true);
    // final rawData = msg.data['data'];
    // if (rawData == null) return;
    //
    // final data = rawData is String ? jsonDecode(rawData) : rawData;
    // final id = data['messageId'];
    // if (id == null) return;
    //
    // // await NotificationService.loadShownIdsOnce();
    // if (NotificationService.isDuplicate(id)) {
    //   print("⚠️ Foreground: Skipping duplicate $id");
    //   return;
    // }
    //
    // print("✅ Showing notification $id in foreground");
    // await NotificationService.showAwesomeNotification(msg);
  });

  AppConfig.setEnvironment(AppEnvironment.prod);

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
