import 'package:flutter/material.dart';
import 'package:genchatapp/app/config/services/firebase_controller.dart';
import 'package:genchatapp/app/constants/constants.dart';
import 'package:genchatapp/app/data/local_database/local_database.dart';

import 'package:get/get.dart';

import 'app/config/services/connectivity_service.dart';
import 'app/config/services/folder_creation.dart';
import 'app/config/theme/app_theme.dart';
import 'app/routes/app_pages.dart';
import 'app/services/shared_preference_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app/constants/get_di.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await di.init();

 await DataBaseService().database;
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: appName,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      theme: AppTheme.theme,
    );
  }
}
