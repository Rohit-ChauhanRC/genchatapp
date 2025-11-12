import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class StatusTile extends StatelessWidget {
  final String userPic;
  final String name;
  final String statusTime;

  final VoidCallback onTap;

  const StatusTile({
    super.key,
    required this.userPic,
    required this.onTap,
    required this.name,
    required this.statusTime,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 28,
        // backgroundColor: status.viewed ? Colors.grey : Colors.green,
        child: CachedNetworkImage(
          imageUrl: userPic,
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
      title: Text(name),
      subtitle: Text(statusTime),
      onTap: onTap,
    );
  }
}
