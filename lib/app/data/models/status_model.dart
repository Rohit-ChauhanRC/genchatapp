class StatusModel {
  final String name;
  // final String imageUrl;
  List<String>imageUrl;
  final String ProfilePic;
  final String time;
  bool viewed;

  StatusModel({
    required this.name,
    required this.imageUrl,
    required this.time,
    required this.ProfilePic,
    this.viewed = false,
  });
}
