import 'package:flutter/material.dart';
Widget _buildAttachmentItem({
  required IconData icon,
  required String label,
  required Color color,
  required Function() onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Column(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: color.withOpacity(0.15),
          child: Icon(
            icon,
            color: color,
            size: 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    ),
  );
}
