// To parse this JSON data, do
//
//     final createGroupModel = createGroupModelFromJson(jsonString);

import 'dart:convert';

createGroupModelFromJson(String str) =>
    CreateGroupModel.fromJson(json.decode(str));

String createGroupModelToJson(CreateGroupModel data) =>
    json.encode(data.toJson());

class CreateGroupModel {
  bool? status;
  String? message;
  int? statusCode;
  GroupData? data;

  CreateGroupModel({
    this.status,
    this.message,
    this.statusCode,
    this.data,
  });

  factory CreateGroupModel.fromJson(Map<String, dynamic> json) =>
      CreateGroupModel(
        status: json["status"],
        message: json["message"],
        statusCode: json["statusCode"],
        data: json["data"] == null ? null : GroupData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "statusCode": statusCode,
        "data": data?.toJson(),
      };
}

class GroupData {
  Group? group;
  List<User>? users;

  GroupData({
    this.group,
    this.users,
  });

  factory GroupData.fromJson(Map<String, dynamic> json) => GroupData(
        group: json["group"] == null ? null : Group.fromJson(json["group"]),
        users: json["users"] == null
            ? []
            : List<User>.from(json["users"]!.map((x) => User.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "group": group?.toJson(),
        "users": users == null
            ? []
            : List<dynamic>.from(users!.map((x) => x.toJson())),
      };
}

class Group {
  int? id;
  String? name;
  String? displayPicture;
  String? groupDescription;
  int? creatorId;
  String? createdAt;
  String? updatedAt;
  bool? isActive;
  String? displayPictureUrl;

  Group({
    this.id,
    this.name,
    this.displayPicture,
    this.groupDescription,
    this.creatorId,
    this.createdAt,
    this.updatedAt,
    this.isActive,
    this.displayPictureUrl,
  });

  factory Group.fromJson(Map<String, dynamic> json) => Group(
        id: json["id"],
        name: json["name"],
        displayPicture: json["displayPicture"],
        groupDescription: json["groupDescription"],
        creatorId: json["creatorId"],
        createdAt: json["createdAt"],
        updatedAt: json["updatedAt"],
        isActive: json["isActive"] == 1 || json['isActive'],
        displayPictureUrl: json["displayPictureUrl"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "displayPicture": displayPicture,
        "groupDescription": groupDescription,
        "creatorId": creatorId,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
        "isActive": isActive == true ? 1 : 0,
        "displayPictureUrl": displayPictureUrl,
      };
}

class User {
  UserInfo? userInfo;
  UserGroupInfo? userGroupInfo;

  User({
    this.userInfo,
    this.userGroupInfo,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        userInfo: json["userInfo"] == null
            ? null
            : UserInfo.fromJson(json["userInfo"]),
        userGroupInfo: json["userGroupInfo"] == null
            ? null
            : UserGroupInfo.fromJson(json["userGroupInfo"]),
      );

  Map<String, dynamic> toJson() => {
        "userInfo": userInfo?.toJson(),
        "userGroupInfo": userGroupInfo?.toJson(),
      };
}

class UserInfo {
  int? userId;
  int? countryCode;
  String? phoneNumber;
  String? name;
  String? email;
  String? userDescription;
  bool? isOnline;
  String? displayPicture;
  String? displayPictureUrl;

  UserInfo({
    this.userId,
    this.countryCode,
    this.phoneNumber,
    this.name,
    this.email,
    this.userDescription,
    this.isOnline,
    this.displayPicture,
    this.displayPictureUrl,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) => UserInfo(
        userId: json["userId"],
        countryCode: json["countryCode"],
        phoneNumber: json["phoneNumber"],
        name: json["name"],
        email: json["email"],
        userDescription: json["userDescription"],
        isOnline: json["isOnline"] == 1 || json["isOnline"],
        displayPicture: json["displayPicture"],
        displayPictureUrl: json["displayPictureUrl"],
      );

  Map<String, dynamic> toJson() => {
        "userId": userId,
        "countryCode": countryCode,
        "phoneNumber": phoneNumber,
        "name": name,
        "email": email,
        "userDescription": userDescription,
        "isOnline": isOnline == true ? 1 : 0,
        "displayPicture": displayPicture,
        "displayPictureUrl": displayPictureUrl,
      };
}

class UserGroupInfo {
  int? groupId;
  int? userId;
  bool? isAdmin;
  int? updaterId;
  String? createdAt;
  String? updatedAt;
  bool? isRemoved;

  UserGroupInfo({
    this.groupId,
    this.userId,
    this.isAdmin,
    this.updaterId,
    this.createdAt,
    this.updatedAt,
    this.isRemoved,
  });

  factory UserGroupInfo.fromJson(Map<String, dynamic> json) => UserGroupInfo(
        groupId: json["groupId"],
        userId: json["userId"],
        isAdmin: json["isAdmin"] == 1 || json["isAdmin"],
        updaterId: json["updaterId"],
        createdAt: json["createdAt"],
        updatedAt: json["updatedAt"],
        isRemoved: json["isRemoved"] == 1 || json["isRemoved"],
      );

  Map<String, dynamic> toJson() => {
        "groupId": groupId,
        "userId": userId,
        "isAdmin": isAdmin == true ? 1 : 0,
        "updaterId": updaterId,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
        "isRemoved": isRemoved == true ? 1 : 0,
      };
}
