import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../utils/utils.dart';
import '../controllers/single_chat_controller.dart';

void showContactPreviewSheet(
    BuildContext context, {
      required String name,
      required String phone,
    }) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 36,
                child: Icon(Icons.person, size: 36),
              ),
              const SizedBox(height: 12),

              Text(
                name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),

              Text(
                phone,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _contactAction(
                    icon: Icons.call,
                    label: "Call",
                    onTap: () => _callNumber(phone),
                  ),
                  _contactAction(
                    icon: Icons.person_add,
                    label: "Save",
                    onTap: () async {
                      final success = await saveContact(
                        name: name,
                        phone: phone,
                      );

                      if (success) {
                        // 1️⃣ Close bottom sheet first
                        Get.back();

                        // 2️⃣ Wait for bottom sheet animation to finish
                        await Future.delayed(const Duration(milliseconds: 300));

                        // 3️⃣ Show snackbar
                        Get.snackbar(
                          "Contact Saved",
                          "Contact saved as $name",
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                          margin: const EdgeInsets.all(12),
                          borderRadius: 12,
                          icon: const Icon(Icons.check_circle, color: Colors.white),
                          duration: const Duration(seconds: 2),
                        );
                      } else {
                        Get.snackbar(
                          "Failed",
                          "Unable to save contact",
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      }
                    },

                  ),

                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
Widget _contactAction({
  required IconData icon,
  required String label,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Column(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: Colors.blue.withOpacity(0.1),
          child: Icon(icon, color: Colors.blue),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    ),
  );
}

Future<void> _callNumber(String phone) async {
  final uri = Uri.parse("tel:$phone");
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  }
}

Future<void> _smsNumber(String phone) async {
  final uri = Uri.parse("sms:$phone");
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  }
}
