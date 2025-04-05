// To parse this JSON data, do
//
//     final contactResponseModel = contactResponseModelFromJson(jsonString);

import 'dart:convert';

ContactResponseModel contactResponseModelFromJson(String str) => ContactResponseModel.fromJson(json.decode(str));

String contactResponseModelToJson(ContactResponseModel data) => json.encode(data.toJson());

class ContactResponseModel {
  bool? status;
  String? message;
  int? statusCode;
  List<UserList>? data;

  ContactResponseModel({
    this.status,
    this.message,
    this.statusCode,
    this.data,
  });

  factory ContactResponseModel.fromJson(Map<String, dynamic> json) => ContactResponseModel(
    status: json["status"],
    message: json["message"],
    statusCode: json["statusCode"],
    data: json["data"] == null ? [] : List<UserList>.from(json["data"]!.map((x) => UserList.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "statusCode": statusCode,
    "data": data == null ? [] : List<UserList>.from(data!.map((x) => x.toJson())),
  };
}

class UserList {
  int? userId;
  int? countryCode;
  String? phoneNumber;
  String? name;
  String? email;
  String? userDescription;
  int? isOnline;
  String? displayPicture;
  String? displayPictureUrl;
  int? isBlocked;

  UserList({
    this.userId,
    this.countryCode,
    this.phoneNumber,
    this.name,
    this.email,
    this.userDescription,
    this.isOnline,
    this.displayPicture,
    this.displayPictureUrl,
    this.isBlocked,
  });

  factory UserList.fromJson(Map<String, dynamic> json) => UserList(
    userId: json["userId"],
    countryCode: json["countryCode"],
    phoneNumber: json["phoneNumber"],
    name: json["name"],
    email: json["email"],
    userDescription: json["userDescription"],
    isOnline: json["isOnline"],
    displayPicture: json["displayPicture"],
    displayPictureUrl: json["displayPictureUrl"],
    isBlocked: json["isBlocked"],
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
    "isBlocked": isBlocked,
  };

  UserList copyWith({
    int? userId,
    int? countryCode,
    String? phoneNumber,
    String? name,
    String? email,
    String? userDescription,
    int? isOnline,
    String? displayPicture,
    String? displayPictureUrl,
    int? isBlocked,
  }) {
    return UserList(
      userId: userId ?? this.userId,
      countryCode: countryCode ?? this.countryCode,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      name: name ?? this.name,
      email: email ?? this.email,
      userDescription: userDescription ?? this.userDescription,
      isOnline: isOnline ?? this.isOnline,
      displayPicture: displayPicture ?? this.displayPicture,
      displayPictureUrl: displayPictureUrl ?? this.displayPictureUrl,
      isBlocked: isBlocked ?? this.isBlocked,
    );
  }
}
