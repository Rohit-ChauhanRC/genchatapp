class StatusModel {
  final String name;
  final String imageUrl;
  final String time;
  bool viewed;

  StatusModel({
    required this.name,
    required this.imageUrl,
    required this.time,
    this.viewed = false,
  });
}
