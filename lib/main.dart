import 'dart:convert';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
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

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await dotenv.load(fileName: ".env");
  await di.init();
  // Extract messageId for logging
  final rawData = message.data['data'];

  if (rawData != null) {
    try {
      final decoded = Map<String, dynamic>.from(jsonDecode(rawData));
      final messageId = decoded['messageId']?.toString();
      if (kDebugMode) {}
      if (messageId != null && messageId.isNotEmpty) {
        // 🚨 Add this line to prevent repeat
        await NotificationService.addShownMessageId(messageId);
      }
    } catch (e) {
      if (kDebugMode) {}
    }
  }
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
    if (kDebugMode) {}
  } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
    if (kDebugMode) {}
  } else {
    if (kDebugMode) {}
  }

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
