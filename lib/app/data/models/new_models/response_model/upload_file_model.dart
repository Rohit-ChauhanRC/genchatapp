// To parse this JSON data, do
//
//     final uploadFileModel = uploadFileModelFromJson(jsonString);

import 'dart:convert';

UploadFileModel uploadFileModelFromJson(String str) => UploadFileModel.fromJson(json.decode(str));

String uploadFileModelToJson(UploadFileModel data) => json.encode(data.toJson());

class UploadFileModel {
  bool? status;
  String? message;
  int? statusCode;
  Data? data;

  UploadFileModel({
    this.status,
    this.message,
    this.statusCode,
    this.data,
  });

  UploadFileModel copyWith({
    bool? status,
    String? message,
    int? statusCode,
    Data? data,
  }) =>
      UploadFileModel(
        status: status ?? this.status,
        message: message ?? this.message,
        statusCode: statusCode ?? this.statusCode,
        data: data ?? this.data,
      );

  factory UploadFileModel.fromJson(Map<String, dynamic> json) => UploadFileModel(
    status: json["status"],
    message: json["message"],
    statusCode: json["statusCode"],
    data: Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "statusCode": statusCode,
    "data": data?.toJson(),
  };
}

class Data {
  String? serverFileName;
  String? url;
  String? originalName;

  Data({
    this.serverFileName,
    this.url,
    this.originalName,
  });

  Data copyWith({
    String? serverFileName,
    String? url,
    String? originalName,
  }) =>
      Data(
        serverFileName: serverFileName ?? this.serverFileName,
        url: url ?? this.url,
        originalName: originalName ?? this.originalName,
      );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    serverFileName: json["serverFileName"],
    url: json["url"],
    originalName: json["originalName"],
  );

  Map<String, dynamic> toJson() => {
    "serverFileName": serverFileName,
    "url": url,
    "originalName": originalName,
  };
}
