// To parse this JSON data, do
//
//     final verifyOtpResponseModel = verifyOtpResponseModelFromJson(jsonString);

import 'dart:convert';

import 'package:equatable/equatable.dart';

VerifyOtpResponseModel verifyOtpResponseModelFromJson(String str) => VerifyOtpResponseModel.fromJson(json.decode(str));

String verifyOtpResponseModelToJson(VerifyOtpResponseModel data) => json.encode(data.toJson());

class VerifyOtpResponseModel {
  bool? status;
  String? message;
  int? statusCode;
  Data? data;

  VerifyOtpResponseModel({
    this.status,
    this.message,
    this.statusCode,
    this.data,
  });

  factory VerifyOtpResponseModel.fromJson(Map<String, dynamic> json) => VerifyOtpResponseModel(
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
  String? refreshToken;
  String? accessToken;
  UserData? userData;

  Data({
    this.refreshToken,
    this.accessToken,
    this.userData,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    refreshToken: json["refreshToken"],
    accessToken: json["accessToken"],
    userData: json["userData"] == null ? null : UserData.fromJson(json["userData"]),
  );

  Map<String, dynamic> toJson() => {
    "refreshToken": refreshToken,
    "accessToken": accessToken,
    "userData": userData?.toJson(),
  };
}

UserData userDataFromJson(String str) => UserData.fromJson(json.decode(str));

String userDataToJson(UserData data) => json.encode(data.toJson());
class UserData extends Equatable{
  int? userId;
  int? countryCode;
  String? phoneNumber;
  String? name;
  dynamic email;
  dynamic userDescription;
  bool? isOnline;
  String? displayPicture;
  String? displayPictureUrl;
  String? lastSeenTime;

  UserData({
    this.userId,
    this.countryCode,
    this.phoneNumber,
    this.name,
    this.email,
    this.userDescription,
    this.isOnline,
    this.displayPicture,
    this.displayPictureUrl,
    this.lastSeenTime,
  });

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
    userId: json["userId"],
    countryCode: json["countryCode"],
    phoneNumber: json["phoneNumber"],
    name: json["name"],
    email: json["email"],
    userDescription: json["userDescription"],
    isOnline: json["isOnline"],
    displayPicture: json["displayPicture"],
    displayPictureUrl: json["displayPictureUrl"],
    lastSeenTime: json["lastSeenTime"],
  );

  Map<String, dynamic> toJson() => {
    "userId": userId,
    "countryCode": countryCode,
    "phoneNumber": phoneNumber,
    "name": name,
    "email": email,
    "userDescription": userDescription,
    "isOnline": isOnline,
    "displayPicture": displayPicture,
    "displayPictureUrl": displayPictureUrl,
    "lastSeenTime": lastSeenTime,
  };

  @override
  // TODO: implement props
  List<Object?> get props => [
    userId,
    countryCode,
    phoneNumber,
    name,
    email,
    userDescription,
    isOnline,
    displayPicture,
    displayPictureUrl,
    lastSeenTime
  ];
}
