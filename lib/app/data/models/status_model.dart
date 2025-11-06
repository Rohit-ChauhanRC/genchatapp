class StatusModel {
  final String name;
  // final String imageUrl;
  final List<Map<String, String>> media;
  final String ProfilePic;
  final String time;

  bool viewed;

  StatusModel({
    required this.name,
    required this.media,
    required this.time,
    required this.ProfilePic,
    this.viewed = false,


  });
}
