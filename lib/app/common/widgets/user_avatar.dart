import 'package:flutter/material.dart';
import 'package:genchatapp/app/constants/colors.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: greyColor.withOpacity(0.4),
      radius: 64,
      child: const Icon(Icons.add_a_photo, size: 80.0, color: greyColor),
    );
  }
}
