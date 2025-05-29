class CreateGroupModel {
  bool? status;
  String? message;
  int? statusCode;
  GroupData? data;

  CreateGroupModel({this.status, this.message, this.statusCode, this.data});

  CreateGroupModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    statusCode = json['statusCode'];
    data = json['data'] != null ? GroupData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    data['statusCode'] = statusCode;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class GroupData {
  int? id;
  String? name;
  String? displayPicture;
  String? groupDescription;
  int? creatorId;
  String? createdAt;
  String? updatedAt;
  int? isActive;
  List<Users>? users;

  GroupData(
      {this.id,
      this.name,
      this.displayPicture,
      this.groupDescription,
      this.creatorId,
      this.createdAt,
      this.updatedAt,
      this.isActive,
      this.users});

  GroupData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    displayPicture = json['displayPicture'];
    groupDescription = json['groupDescription'];
    creatorId = json['creatorId'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    isActive = json['isActive'] == true ? 1: 0;
    if (json['users'] != null) {
      users = <Users>[];
      json['users'].forEach((v) {
        users!.add(Users.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['displayPicture'] = displayPicture;
    data['groupDescription'] = groupDescription;
    data['creatorId'] = creatorId;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['isActive'] = isActive;
    if (users != null) {
      data['users'] = users!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Users {
  UserInfo? userInfo;
  UserGroupInfo? userGroupInfo;

  Users({this.userInfo, this.userGroupInfo});

  Users.fromJson(Map<String, dynamic> json) {
    userInfo =
        json['userInfo'] != null ? UserInfo.fromJson(json['userInfo']) : null;
    userGroupInfo = json['userGroupInfo'] != null
        ? UserGroupInfo.fromJson(json['userGroupInfo'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (userInfo != null) {
      data['userInfo'] = userInfo!.toJson();
    }
    if (userGroupInfo != null) {
      data['userGroupInfo'] = userGroupInfo!.toJson();
    }
    return data;
  }
}

class UserInfo {
  int? userId;
  int? countryCode;
  String? phoneNumber;
  String? name;
  String? email;
  String? userDescription;
  int? isOnline;
  String? displayPicture;
  String? displayPictureUrl;

  UserInfo(
      {this.userId,
      this.countryCode,
      this.phoneNumber,
      this.name,
      this.email,
      this.userDescription,
      this.isOnline,
      this.displayPicture,
      this.displayPictureUrl});

  UserInfo.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    countryCode = json['countryCode'];
    phoneNumber = json['phoneNumber'];
    name = json['name'];
    email = json['email'];
    userDescription = json['userDescription'];
    isOnline = json['isOnline'] == true? 1:0;
    displayPicture = json['displayPicture'];
    displayPictureUrl = json['displayPictureUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userId'] = userId;
    data['countryCode'] = countryCode;
    data['phoneNumber'] = phoneNumber;
    data['name'] = name;
    data['email'] = email;
    data['userDescription'] = userDescription;
    data['isOnline'] = isOnline;
    data['displayPicture'] = displayPicture;
    data['displayPictureUrl'] = displayPictureUrl;
    return data;
  }
}

class UserGroupInfo {
  int? groupId;
  int? userId;
  int? isAdmin;
  int? updaterId;
  String? createdAt;
  String? updatedAt;

  UserGroupInfo(
      {this.groupId,
      this.userId,
      this.isAdmin,
      this.updaterId,
      this.createdAt,
      this.updatedAt});

  UserGroupInfo.fromJson(Map<String, dynamic> json) {
    groupId = json['groupId'];
    userId = json['userId'];
    isAdmin = json['isAdmin'] == true? 1: 0;
    updaterId = json['updaterId'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['groupId'] = groupId;
    data['userId'] = userId;
    data['isAdmin'] = isAdmin;
    data['updaterId'] = updaterId;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}
