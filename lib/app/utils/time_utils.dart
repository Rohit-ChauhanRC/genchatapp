import 'package:intl/intl.dart';

String lastSeenFormatted(String lastSeen) {
  if (lastSeen.isNotEmpty) {
    int microseconds = int.parse(lastSeen);
    DateTime lastSeenDateTime =
        DateTime.fromMicrosecondsSinceEpoch(microseconds);
    return formatLastSeen(lastSeenDateTime);
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
