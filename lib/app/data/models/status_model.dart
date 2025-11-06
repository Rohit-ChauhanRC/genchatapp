class StatusModel {
  final String name;
  // final String imageUrl;
  List<String>imageUrl;
  final String ProfilePic;
  final String time;
  final String? type;
  final String? text;
  bool viewed;
  final String? video;

  StatusModel({
    required this.name,
    required this.imageUrl,
    required this.time,
    required this.ProfilePic,
     this.type,
    this.viewed = false,
    this.text,
    this.video

  });
}
