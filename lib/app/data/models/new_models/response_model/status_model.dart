class Statusmodel {
  int id;
  int userId;
  int isAsset; // 0=text, 1=media
  String? statusText;
  String? assetUrl;
  String? statusAssetType; // image | video | text
  String? createdAt;
  int? isDeleted;

  Statusmodel({
    required this.id,
    required this.userId,
    required this.isAsset,
    required this.statusText,
    required this.assetUrl,
    required this.statusAssetType,
    required this.createdAt,
    required this.isDeleted,
  });

  factory Statusmodel.fromJson(Map<String, dynamic> json) {
    final type = json["statusAssetType"]?.toString().toLowerCase() ?? "";

    final isTextStatus = type.isEmpty || json["assetUrl"] == null || (json["assetUrl"] as String).trim().isEmpty;

    return Statusmodel(
      id: json["id"],
      userId: json["userId"],
      isAsset: isTextStatus ? 0 : 1,
      statusText: json["statusText"],
      assetUrl: json["assetUrl"],
      statusAssetType: type,
      createdAt: json["createdAt"],
      isDeleted: json["isDeleted"] == true ? 1 : 0,
    );
  }

  List<Map<String, dynamic>> get media {
    // TEXT STATUS
    if (isAsset == 0) {
      if ((statusText ?? '').trim().isEmpty) return [];
      return [
        {
          "type": "text",
          "text": statusText!,
          "bgColor": "#000000",
          "textColor": "#FFFFFF",
        },
      ];
    }

    if (assetUrl == null || assetUrl!.trim().isEmpty) return [];

    return [
      {
        "type": statusAssetType == "video" ? "video" : "image",
        "url": assetUrl!,
      },
    ];
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "userId": userId,
      "isAsset": isAsset,
      "statusText": statusText,
      "assetUrl": assetUrl,
      "statusAssetType": statusAssetType,
      "createdAt": createdAt,
      "isDeleted": isDeleted,
    };
  }
}
