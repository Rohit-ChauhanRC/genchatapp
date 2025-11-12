// To parse this JSON data, do
//
//     final statusmodel = statusmodelFromJson(jsonString);

import 'dart:convert';

Statusmodel statusmodelFromJson(String str) =>
    Statusmodel.fromJson(json.decode(str));

String statusmodelToJson(Statusmodel data) => json.encode(data.toJson());

class Statusmodel {
  int id;
  int userId;
  int isAsset;
  String? statusText;
  String? statusAssetUrl;
  int isDeleted;
  String? createdAt;

  Statusmodel({
    required this.id,
    required this.userId,
    required this.isAsset,
    required this.statusText,
    required this.statusAssetUrl,
    required this.isDeleted,
    required this.createdAt,
  });

  factory Statusmodel.fromJson(Map<String, dynamic> json) => Statusmodel(
    id: json["id"],
    userId: json["userId"],
    isAsset: json["isAsset"] == true ? 1 : 0,
    statusText: json["statusText"],
    statusAssetUrl: json["statusAssetUrl"],
    isDeleted: json["isDeleted"] == true ? 1 : 0,
    createdAt: json["createdAt"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "userId": userId,
    "isAsset": isAsset,
    "statusText": statusText,
    "statusAssetUrl": statusAssetUrl,
    "isDeleted": isDeleted,
    "createdAt": createdAt,
  };
}
