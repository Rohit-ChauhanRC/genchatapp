import 'package:flutter/material.dart';
import 'package:genchatapp/app/modules/call/views/call_view.dart';
import 'package:genchatapp/app/modules/chats/views/chats_view.dart';
import 'package:genchatapp/app/modules/settings/views/settings_view.dart';
import 'package:genchatapp/app/modules/updates/controllers/updates_controller.dart';
import 'package:genchatapp/app/modules/updates/views/updates_view.dart';

import 'package:get/get.dart';

import '../../../constants/colors.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
            navigationBarTheme: NavigationBarThemeData(
              backgroundColor: textBarColor,
              indicatorColor: transparentColor.withOpacity(0.50),
              labelTextStyle: MaterialStateProperty.all(
                const TextStyle(
                  color: Colors.white, // Label color
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          child: NavigationBar(
            onDestinationSelected: (int index) {
              controller.currentPageIndex = index;
            },
            selectedIndex: controller.currentPageIndex,
            destinations: <Widget>[
              const NavigationDestination(
                selectedIcon: ImageIcon(
                  AssetImage("assets/images/chatsIcon.png"),
                  color: highLightColor,
                ),
                icon: ImageIcon(
                  AssetImage("assets/images/chatsIcon.png"),
                  color: whiteColor,
                ),
                label: 'Chats',
              ),
              NavigationDestination(
                selectedIcon: const ImageIcon(
                  AssetImage("assets/images/statusIcon.png"),
                  color: highLightColor,
                ),
                icon: InkWell(
                  onTap: () async {
                    final UpdatesController update = Get.put<UpdatesController>(
                      UpdatesController(),
                    );
                    if (controller.connectivityService.isConnected.value) {
                      await update.getContacts();
                      await update.getStatus();
                    }
                  },
                  child: const ImageIcon(
                    AssetImage("assets/images/statusIcon.png"),
                    color: whiteColor,
                  ),
                ),
                label: 'Updates',
              ),
              const NavigationDestination(
                selectedIcon: ImageIcon(
                  AssetImage("assets/images/callIcon.png"),
                  color: highLightColor,
                ),
                icon: ImageIcon(
                  AssetImage("assets/images/callIcon.png"),
                  color: whiteColor,
                ),
                label: 'Call',
              ),
              const NavigationDestination(
                selectedIcon: Icon(Icons.settings, color: highLightColor),
                icon: Icon(Icons.settings, color: Colors.white),
                label: 'Settings',
              ),
            ],
          ),
        ),
        body: [
          const ChatsView(),
          const UpdatesView(),
          const CallView(),
          const SettingsView(),
        ][controller.currentPageIndex],
      ),
    );
  }
}
