import 'package:flutter/material.dart';

String formatStatusTime(BuildContext context, String? createdAt) {
  if (createdAt == null || createdAt.isEmpty) return "";

  DateTime? date;

  try {
    date = DateTime.parse(createdAt);
  } catch (_) {
    return "";
  }

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final dateOnly = DateTime(date.year, date.month, date.day);

  final time = TimeOfDay.fromDateTime(date).format(context);

  if (dateOnly == today) {
    return "Today · $time";
  } else if (dateOnly == yesterday) {
    return "Yesterday · $time";
  } else {
    return "${date.day} ${_monthName(date.month)} ${date.year} · $time";
  }
}

String _monthName(int month) {
  const months = [
    "Jan","Feb","Mar","Apr","May","Jun",
    "Jul","Aug","Sep","Oct","Nov","Dec"
  ];
  return months[month - 1];
}
