// // To parse this JSON data, do
// //
// //     final userModel = userModelFromJson(jsonString);

// import 'package:equatable/equatable.dart';
// import 'package:meta/meta.dart';
// import 'dart:convert';

// UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

// String userModelToJson(UserModel data) => json.encode(data.toJson());

// class UserModel extends Equatable {
//   String? name;
//   String? uid;
//   String? profilePic;
//   bool? isOnline;
//   String? phoneNumber;
//   List<dynamic>? groupId;
//   String? email;
//   String? lastSeen;
//   String? fcmToken;

//   UserModel({
//     this.name,
//     this.uid,
//     this.profilePic,
//     this.isOnline,
//     this.phoneNumber,
//     this.groupId,
//     this.email,
//     this.lastSeen,
//     this.fcmToken,
//   });

//   factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
//         name: json["name"],
//         uid: json["uid"],
//         profilePic: json["profilePic"],
//         isOnline: json["isOnline"],
//         phoneNumber: json["phoneNumber"],
//         groupId: List<dynamic>.from(json["groupId"].map((x) => x)),
//         email: json["email"],
//         lastSeen: json["lastSeen"],
//         fcmToken: json["fcmToken"],
//       );

//   Map<String, dynamic> toJson() => {
//         "name": name,
//         "uid": uid,
//         "profilePic": profilePic,
//         "isOnline": isOnline,
//         "phoneNumber": phoneNumber,
//         "groupId": List<dynamic>.from(groupId!.map((x) => x)),
//         "email": email,
//         "lastSeen": lastSeen,
//         "fcmToken": fcmToken,
//       };

//   @override
//   List<Object?> get props => [
//         name,
//         uid,
//         profilePic,
//         isOnline,
//         phoneNumber,
//         groupId,
//         email,
//         lastSeen,
//         fcmToken
//       ];
// }
