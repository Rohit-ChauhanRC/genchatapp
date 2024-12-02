import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'app/config/theme/app_theme.dart';
import 'app/routes/app_pages.dart';
import 'app/services/shared_preference_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferenceService = SharedPreferenceService();
  await sharedPreferenceService.init();
  Get.put<SharedPreferenceService>(sharedPreferenceService);
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "GenChat App",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      theme: AppTheme.theme,
    );
  }
}
