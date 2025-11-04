import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:genchatapp/app/data/models/status_model.dart';

class StatusTile extends StatelessWidget {
  final StatusModel status;
  final VoidCallback onTap;

  const StatusTile({super.key, required this.status, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: status.viewed ? Colors.grey : Colors.green,
        child: CachedNetworkImage(
          imageUrl: status.ProfilePic,
          imageBuilder: (context, imageProvider) =>
              CircleAvatar(backgroundImage: imageProvider, radius: 25),
          placeholder: (context, url) => const CircleAvatar(
            radius: 25,
            child: CircularProgressIndicator(),
          ),
          errorWidget: (context, url, error) =>
              const CircleAvatar(radius: 25, child: Icon(Icons.error)),
        ),
      ),
      title: Text(status.name),
      subtitle: Text(status.time),
      onTap: onTap,
    );
  }
}
