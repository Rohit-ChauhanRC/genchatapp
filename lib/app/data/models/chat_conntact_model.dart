import 'dart:convert';

import 'package:equatable/equatable.dart';

class ChatConntactModel extends Equatable {
  final String? name;
  final String? profilePic;
  final String? contactId;
  final String? timeSent;
  final String? lastMessage;
  final String? uid;
  final int? unreadCount;

  const ChatConntactModel({
    this.name,
    this.profilePic,
    this.contactId,
    this.timeSent,
    this.lastMessage,
    this.uid,
    this.unreadCount = 0,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'profilePic': profilePic,
      'contactId': contactId,
      'timeSent': timeSent,
      'lastMessage': lastMessage,
      'uid': uid,
      "unreadCount": unreadCount,
    };
  }

  factory ChatConntactModel.fromMap(Map<String, dynamic> map) {
    return ChatConntactModel(
        name: map['name'],
        profilePic: map['profilePic'] as String,
        contactId: map['contactId'] as String,
        timeSent: map['timeSent'],
        lastMessage: map['lastMessage'] as String,
        uid: map['uid'] as String,
        unreadCount: map["unreadCount"]);
  }

  String toJson() => json.encode(toMap());

  factory ChatConntactModel.fromJson(String source) =>
      ChatConntactModel.fromMap(json.decode(source) as Map<String, dynamic>);

  ChatConntactModel copyWith({
    final String? name,
    final String? profilePic,
    final String? contactId,
    final String? timeSent,
    final String? lastMessage,
    final String? uid,
    final int? unreadCount,
  }) {
    return ChatConntactModel(
      contactId: contactId ?? this.contactId,
      profilePic: profilePic ?? this.profilePic,
      name: name ?? this.name,
      timeSent: timeSent ?? this.timeSent,
      lastMessage: lastMessage ?? this.lastMessage,
      uid: uid ?? this.uid,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  @override
  List<Object?> get props =>
      [name, profilePic, contactId, timeSent, lastMessage, uid, unreadCount];
}
