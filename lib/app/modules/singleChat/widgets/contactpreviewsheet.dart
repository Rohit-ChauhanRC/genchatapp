import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

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
                    icon: Icons.message,
                    label: "Message",
                    onTap: () => _smsNumber(phone),
                  ),
                  _contactAction(
                    icon: Icons.person_add,
                    label: "Save",
                    onTap: () async {
                      await Get.find<SingleChatController>().saveContact(
                        name: name,
                        phone: phone,
                      );
                      Get.back();
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
