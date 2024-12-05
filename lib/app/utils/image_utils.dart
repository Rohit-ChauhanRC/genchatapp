import 'dart:io';

import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';

Widget displayLocalImage(String localPath) {
  return Image.file(File(localPath));
}

Widget displayFile(String fileUrl) {
  return CachedNetworkImage(
    imageUrl: fileUrl,
    placeholder: (context, url) => const CircularProgressIndicator(),
    errorWidget: (context, url, error) => const Icon(Icons.error),
  );
}
