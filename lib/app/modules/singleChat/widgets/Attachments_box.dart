import 'package:flutter/material.dart';
import '../../../constants/message_enum.dart';
import '../controllers/single_chat_controller.dart'; // your controller import
// import '../models/message_type.dart'; // uncomment if MessageType is in another file

void showAttachmentSheet(BuildContext context, SingleChatController singleChatController) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) {
      return
        SafeArea(child:

        Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildAttachmentItem(
                  icon: Icons.image,
                  label: "Image",
                  color: Colors.purple,
                  onTap: () {
                    Navigator.pop(context);
                    singleChatController.selectFile(MessageType.image.value);
                  },
                ),
                _buildAttachmentItem(
                  icon: Icons.videocam,
                  label: "Video",
                  color: Colors.red,
                  onTap: () {
                    Navigator.pop(context);
                    singleChatController.selectFile(MessageType.video.value);
                  },
                ),
                _buildAttachmentItem(
                  icon: Icons.audiotrack,
                  label: "Audio",
                  color: Colors.green,
                  onTap: () {
                    Navigator.pop(context);
                    singleChatController.selectFile(MessageType.audio.value);
                  },
                ),
                _buildAttachmentItem(
                  icon: Icons.description,
                  label: "Document",
                  color: Colors.blue,
                  onTap: () {
                    Navigator.pop(context);
                    singleChatController.selectFile(MessageType.document.value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
        ));
    },
  );

}

Widget _buildAttachmentItem({
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
