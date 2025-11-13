// To parse this JSON data, do
//
//     final statusmodel = statusmodelFromJson(jsonString);

import 'dart:convert';

List<Statusmodel> statusmodelFromJson(String str) =>
    List<Statusmodel>.from(json.decode(str)["data"].map((x) => Statusmodel.fromJson(x)));

String statusmodelToJson(List<Statusmodel> data) =>
    json.encode({"data": List<dynamic>.from(data.map((x) => x.toJson()))});

class Statusmodel {
  int id;
  int userId;
  bool isAsset;
  String? statusText;
  String? assetUrl;
  String? statusAssetType;
  String? createdAt;

  Statusmodel({
    required this.id,
    required this.userId,
    required this.isAsset,
    required this.statusText,
    required this.assetUrl,
    required this.statusAssetType,
    required this.createdAt,
  });

  factory Statusmodel.fromJson(Map<String, dynamic> json) => Statusmodel(
    id: json["id"],
    userId: json["userId"],
    isAsset: json["isAsset"],
    statusText: json["statusText"],
    assetUrl: json["assetUrl"],
    statusAssetType: json["statusAssetType"],
    createdAt: json["createdAt"],
  );

  List<Map<String, dynamic>> get media {
    if (!isAsset) {
      return [
        {
          "type": "text",
          "text": statusText ?? "",
          "bgColor": "#000000",
          "textColor": "#FFFFFF"
        }
      ];
    }

    return [
      {
        "type": (statusAssetType == "video") ? "video" : "image",
        "url": assetUrl ?? "",
      }
    ];
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "userId": userId,
    "isAsset": isAsset,
    "statusText": statusText,
    "assetUrl": assetUrl,
    "statusAssetType": statusAssetType,
    "createdAt": createdAt,
  };
}
