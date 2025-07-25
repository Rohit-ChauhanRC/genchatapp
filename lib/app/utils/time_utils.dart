import 'package:intl/intl.dart';

String lastSeenFormatted(String lastSeen) {
  if (lastSeen.isNotEmpty) {
    try {
      DateTime lastSeenDateTime = DateTime.parse(lastSeen);
      return formatLastSeen(lastSeenDateTime);
    } catch (e) {
      return ""; // In case the string can't be parsed
    }
  } else {
    return "";
  }
}

String formatLastSeen(DateTime dateTime) {
  DateTime now = DateTime.now();
  if (dateTime.year == now.year &&
      dateTime.month == now.month &&
      dateTime.day == now.day) {
    return 'Today at ${DateFormat.jm().format(dateTime)}';
  } else {
    return DateFormat('MMM d, yyyy').format(dateTime);
  }
}

String formatLastMessageTime(String dateString) {
  if (dateString.isEmpty) return '';

  try {
    final DateTime messageTime = DateTime.parse(dateString);
    final DateTime now = DateTime.now();

    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime yesterday = today.subtract(const Duration(days: 1));
    final DateTime messageDate = DateTime(
      messageTime.year,
      messageTime.month,
      messageTime.day,
    );

    if (messageDate == today) {
      return DateFormat.jm().format(messageTime); // e.g., 7:42 AM
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('d/M/yy').format(messageTime); // e.g., 15/3/25
    }
  } catch (e) {
    return '';
  }
}

String formatDateTime(String? utcString) {
  if (utcString == null || utcString.trim().isEmpty) return 'N/A';
  try {
    final dateTime = DateTime.parse(utcString); // Convert to local
    final formatter = DateFormat('d/M/yyyy, h:mm a');
    return formatter.format(dateTime);
  } catch (e) {
    return 'Invalid date';
  }
}

String formatMessageTime(String dateString) {
  if (dateString.isEmpty) return '';

  try {
    final DateTime messageTime = DateTime.parse(dateString);
    final DateTime now = DateTime.now();

    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime yesterday = today.subtract(const Duration(days: 1));
    final DateTime messageDate = DateTime(
      messageTime.year,
      messageTime.month,
      messageTime.day,
    );

    if (messageDate == today) {
      return "Today"; // e.g., 7:42 AM
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('d/M/yy').format(messageTime); // e.g., 15/3/25
    }
  } catch (e) {
    return '';
  }
}
