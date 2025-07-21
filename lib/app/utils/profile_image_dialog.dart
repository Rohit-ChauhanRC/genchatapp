import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:genchatapp/app/config/theme/app_colors.dart';

class ProfileImageDialog extends StatelessWidget {
  final String? imageUrl;
  final String? userName;
  final bool isGroup;

  const ProfileImageDialog({
    super.key,
    required this.imageUrl,
    required this.userName,
    required this.isGroup,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent, // 🟢 Remove white background
      insetPadding: const EdgeInsets.all(32), // Padding from screen edge
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 🟦 Image Container
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: imageUrl != null && imageUrl!.isNotEmpty
                ? CachedNetworkImage(
              imageUrl: imageUrl!,
              width: 260,
              height: 260,
              fit: BoxFit.cover,
              placeholder: (context, url) =>
              const SizedBox(
                width: 260,
                height: 260,
                child: Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) =>
              const SizedBox(
                width: 260,
                height: 260,
                child: Icon(Icons.error, size: 60),
              ),
            )
                : Container(
              width: 260,
              height: 260,
              color: AppColors.textBarColor,
              child: Icon(
                isGroup ? Icons.group_rounded : Icons.person,
                size: 100,
                color: Colors.white,
              ),
            ),
          ),

          // 🟨 Full-width name overlay
          Positioned(
            top: 0,
            child: Container(
              width: 260, // same as image width
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16))
              ), // semi-transparent bg
              child: Text(
                userName ?? 'Unknown',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.left,
              ),
            ),
          ),

          // 🔴 Optional Close Button
          // Positioned(
          //   top: 4,
          //   right: 4,
          //   child: IconButton(
          //     icon: const Icon(Icons.close, color: Colors.white),
          //     onPressed: () => Navigator.of(context).pop(),
          //   ),
          // ),
        ],
      ),
    );
  }
}