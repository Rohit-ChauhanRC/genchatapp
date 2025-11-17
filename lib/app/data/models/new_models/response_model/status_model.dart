class Statusmodel {
  int id;
  int userId;
  int isAsset;
  String? statusText;
  String? assetUrl;
  String? statusAssetType;
  String? createdAt;
  int? isDeleted;

  String? localPath;

  Statusmodel({
    required this.id,
    required this.userId,
    required this.isAsset,
    required this.statusText,
    required this.assetUrl,
    required this.statusAssetType,
    required this.createdAt,
    required this.isDeleted,
    this.localPath,
  });

  factory Statusmodel.fromJson(Map<String, dynamic> json) {
    final type = (json["statusAssetType"] ?? "").toString().toLowerCase();

    final isTextStatus = type.isEmpty ||
        json["assetUrl"] == null ||
        (json["assetUrl"] as String).trim().isEmpty;

    return Statusmodel(
      id: json["id"],
      userId: json["userId"],
      isAsset: isTextStatus ? 0 : 1,
      statusText: json["statusText"],
      assetUrl: json["assetUrl"],
      statusAssetType: type,
      createdAt: json["createdAt"],
      isDeleted: json["isDeleted"] is bool
          ? (json["isDeleted"] == true ? 1 : 0)
          : json["isDeleted"],
      localPath: json["localPath"], // ⭐ Load localPath from DB
    );
  }

  // ⭐ Build media list with localPath
  List<Map<String, dynamic>> get media {
    // ---- TEXT STATUS ----
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

    // ---- IMAGE / VIDEO STATUS ----
    if (assetUrl == null || assetUrl!.trim().isEmpty) return [];

    return [
      {
        "type": statusAssetType == "video" ? "video" : "image",
        "url": assetUrl,
        "localPath": localPath, // ⭐ Important for offline view
      },
    ];
  }

  // ⭐ Save localPath also
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
      "localPath": localPath, // ⭐ Save for offline access
    };
  }
}
