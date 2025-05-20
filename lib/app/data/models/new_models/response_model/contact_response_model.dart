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
  String? localName;
  String? email;
  String? userDescription;
  bool? isOnline;
  String? displayPicture;
  String? displayPictureUrl;
  bool? isBlocked;
  String? lastSeenTime;

  UserList({
    this.userId,
    this.countryCode,
    this.phoneNumber,
    this.name,
    this.localName,
    this.email,
    this.userDescription,
    this.isOnline,
    this.displayPicture,
    this.displayPictureUrl,
    this.isBlocked,
    this.lastSeenTime,
  });

  factory UserList.fromJson(Map<String, dynamic> json) => UserList(
    userId: json["userId"],
    countryCode: json["countryCode"],
    phoneNumber: json["phoneNumber"],
    name: json["name"],
    localName: json["localName"],
    email: json["email"],
    userDescription: json["userDescription"],
    isOnline: json["isOnline"],
    displayPicture: json["displayPicture"],
    displayPictureUrl: json["displayPictureUrl"],
    isBlocked: json["isBlocked"],
    lastSeenTime: json["lastSeenTime"],
  );

  Map<String, dynamic> toJson() => {
    "userId": userId,
    "countryCode": countryCode,
    "phoneNumber": phoneNumber,
    "name": name,
    "localName": localName,
    "email": email,
    "userDescription": userDescription,
    "isOnline": isOnline,
    "displayPicture": displayPicture,
    "displayPictureUrl": displayPictureUrl,
    "isBlocked": isBlocked,
    "lastSeenTime": lastSeenTime,
  };

  factory UserList.fromMap(Map<String, dynamic> map) {
    return UserList(
      userId: map["userId"],
      countryCode: map["countryCode"],
      phoneNumber: map["phoneNumber"],
      name: map["name"],
      localName: map["localName"],
      email: map["email"],
      userDescription: map["userDescription"],
      isOnline: map["isOnline"] == 1,
      displayPicture: map["displayPicture"],
      displayPictureUrl: map["displayPictureUrl"],
      isBlocked: map["isBlocked"] == 1,
      lastSeenTime: map["lastSeenTime"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "userId": userId,
      "countryCode": countryCode,
      "phoneNumber": phoneNumber,
      "name": name,
      "localName": localName,
      "email": email,
      "userDescription": userDescription,
      "isOnline": isOnline == true ? 1 : 0,
      "displayPicture": displayPicture,
      "displayPictureUrl": displayPictureUrl,
      "isBlocked": isBlocked == true ? 1 : 0,
      "lastSeenTime": lastSeenTime,
    };
  }

  UserList copyWith({
    int? userId,
    int? countryCode,
    String? phoneNumber,
    String? name,
    String? localName,
    String? email,
    String? userDescription,
    bool? isOnline,
    String? displayPicture,
    String? displayPictureUrl,
    bool? isBlocked,
    String? lastSeenTime,
  }) {
    return UserList(
      userId: userId ?? this.userId,
      countryCode: countryCode ?? this.countryCode,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      name: name ?? this.name,
      localName: localName ?? this.localName,
      email: email ?? this.email,
      userDescription: userDescription ?? this.userDescription,
      isOnline: isOnline ?? this.isOnline,
      displayPicture: displayPicture ?? this.displayPicture,
      displayPictureUrl: displayPictureUrl ?? this.displayPictureUrl,
      isBlocked: isBlocked ?? this.isBlocked,
      lastSeenTime: lastSeenTime ?? this.lastSeenTime,
    );
  }
}
