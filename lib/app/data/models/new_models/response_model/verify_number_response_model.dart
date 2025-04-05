// To parse this JSON data, do
//
//     final verifyNumberResponseModel = verifyNumberResponseModelFromJson(jsonString);

import 'dart:convert';

VerifyNumberResponseModel verifyNumberResponseModelFromJson(String str) => VerifyNumberResponseModel.fromJson(json.decode(str));

String verifyNumberResponseModelToJson(VerifyNumberResponseModel data) => json.encode(data.toJson());

class VerifyNumberResponseModel {
  bool? status;
  String? message;
  int? statusCode;
  Data? data;

  VerifyNumberResponseModel({
    this.status,
    this.message,
    this.statusCode,
    this.data,
  });

  factory VerifyNumberResponseModel.fromJson(Map<String, dynamic> json) => VerifyNumberResponseModel(
    status: json["status"],
    message: json["message"],
    statusCode: json["statusCode"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "statusCode": statusCode,
    "data": data?.toJson(),
  };
}

class Data {
  String? phoneNumber;

  Data({
    this.phoneNumber,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    phoneNumber: json["phoneNumber"],
  );

  Map<String, dynamic> toJson() => {
    "phoneNumber": phoneNumber,
  };
}
