import 'dart:convert';

import 'package:equatable/equatable.dart';

class ChatConntactModel extends Equatable {
  final String name;
  final String profilePic;
  final String contactId;
  final dynamic timeSent;
  final String lastMessage;
  final String uid;
  // final UserModel? user;

  const ChatConntactModel({
    required this.name,
    required this.profilePic,
    required this.contactId,
    required this.timeSent,
    required this.lastMessage,
    required this.uid,
    // this.user,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'profilePic': profilePic,
      'contactId': contactId,
      'timeSent': timeSent.millisecondsSinceEpoch,
      'lastMessage': lastMessage,
      'uid': uid,
    };
  }

  factory ChatConntactModel.fromMap(Map<String, dynamic> map) {
    return ChatConntactModel(
      name: map['name'] as String,
      profilePic: map['profilePic'] as String,
      contactId: map['contactId'] as String,
      timeSent: DateTime.fromMillisecondsSinceEpoch(map['timeSent'] as int),
      lastMessage: map['lastMessage'] as String,
      uid: map['uid'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory ChatConntactModel.fromJson(String source) =>
      ChatConntactModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  List<Object?> get props =>
      [name, profilePic, contactId, timeSent, lastMessage, uid];
}
