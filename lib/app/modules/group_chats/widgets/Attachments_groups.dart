import 'package:flutter/material.dart';
import 'package:genchatapp/app/data/models/contact_save_mode.dart';

import '../../../constants/message_enum.dart';
import '../controllers/group_chats_controller.dart';

void showAttachmentSheetGroup(BuildContext context,GroupChatsController GroupChatsController) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) {
      return SafeArea(child:


        Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildAttachmentItemGroup(
                  icon: Icons.image,
                  label: "Image",
                  color: Colors.purple,
                  onTap: () {
                    Navigator.pop(context);
                    GroupChatsController.selectFile(MessageType.image.value);
                  },
                ),
                _buildAttachmentItemGroup(
                  icon: Icons.videocam,
                  label: "Video",
                  color: Colors.red,
                  onTap: () {
                    Navigator.pop(context);
                    GroupChatsController.selectFile(MessageType.video.value);
                  },
                ),
                _buildAttachmentItemGroup(
                  icon: Icons.audiotrack,
                  label: "Audio",
                  color: Colors.green,
                  onTap: () {
                    Navigator.pop(context);
                    GroupChatsController.selectFile(MessageType.audio.value);
                  },
                ),
                _buildAttachmentItemGroup(
                  icon: Icons.description,
                  label: "Document",
                  color: Colors.blue,
                  onTap: () {
                    Navigator.pop(context);
                    GroupChatsController.selectFile(MessageType.document.value);
                  },
                ),
                _buildAttachmentItemGroup(
                  icon: Icons.contact_page_outlined,
                  label: "Contacts",
                  color: Colors.blue,
                  onTap: () {
                    Navigator.pop(context);
                    showContactsPicker(context, GroupChatsController);
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
        ) );
    },
  );
}
void showContactsPicker(
    BuildContext context,
     GroupChatsController GroupChatsController,
    ) async {
  final contacts = await GroupChatsController.getDeviceContacts();
  // ;

  if (contacts.isEmpty) return;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) {
      return SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            children: [
              const SizedBox(height: 12),
              const Text(
                "Select Contact",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(),

              Expanded(
                child: ListView.builder(
                  itemCount: contacts.length,
                  itemBuilder: (_, index) {
                    final contact = contacts[index];
                    final phone = contact.phones.isNotEmpty == true
                        ? contact.phones.first
                        : null;

                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          (contact.displayName ?? "?")
                              .substring(0, 1)
                              .toUpperCase(),
                        ),
                      ),
                      title: Text(contact.displayName ?? "Unknown"),
                      subtitle: phone != null ? Text(phone.number) : null,
                      onTap: () {
                        Navigator.pop(context);

                        final contactSend = ContactSaveModel(
                          contactNumber: phone!.number ?? "",
                          fullName: contact.displayName ?? "",
                        );

                        GroupChatsController.messageController.text =
                            contactSend.toJson();

                        GroupChatsController.sendTextMessage(isContact: true);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildAttachmentItemGroup({
  required IconData icon,
  required String label,
  required Color color,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Column(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: color.withOpacity(0.12),
          child: Icon(
            icon,
            color: color,
            size: 26,
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    ),
  );
}
