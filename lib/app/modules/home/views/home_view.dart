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
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          child:
          NavigationBar(
            onDestinationSelected: (index) {
              controller.currentPageIndex = index;

              if (index == 1) {
                final UpdatesController update = Get.put(UpdatesController());
                Future.microtask(() {
                  update.getContacts();
                  update.getStatus();
                });
              }
            },
            selectedIndex: controller.currentPageIndex,
            destinations: const <Widget>[
              NavigationDestination(
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
                selectedIcon: ImageIcon(
                  AssetImage("assets/images/statusIcon.png"),
                  color: highLightColor,
                ),
                // icon: InkWell(
                //   onTap: () async {
                //     final UpdatesController update = Get.put<UpdatesController>(
                //       UpdatesController(),
                //     );
                //     if (controller.connectivityService.isConnected.value) {
                //       await update.getContacts();
                //       await update.getStatus();
                //     }
                //   },
                //   child: const ImageIcon(
                //     AssetImage("assets/images/statusIcon.png"),
                //     color: whiteColor,
                //   ),
                // ),
                icon: ImageIcon(
                  AssetImage("assets/images/statusIcon.png"),
                  color: whiteColor,
                ),

                label: 'Updates',
              ),
              NavigationDestination(
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
              NavigationDestination(
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
