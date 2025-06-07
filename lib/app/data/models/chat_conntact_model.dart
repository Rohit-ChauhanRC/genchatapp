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
  final int? lastMessageId;   
  final int? isGroup;


  const ChatConntactModel({
    this.name,
    this.profilePic,
    this.contactId,
    this.timeSent,
    this.lastMessage,
    this.lastMessageId,
    this.uid,
    this.unreadCount = 0,
    this.isGroup,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'profilePic': profilePic,
      'contactId': contactId,
      'timeSent': timeSent,
      'lastMessage': lastMessage,
      'lastMessageId': lastMessageId,
      'uid': uid,
      "unreadCount": unreadCount,
      'isGroup': isGroup,

    };
  }

  factory ChatConntactModel.fromMap(Map<String, dynamic> map) {
    return ChatConntactModel(
        name: map['name'],
        profilePic: map['profilePic'] as String,
        contactId: map['contactId'] as String,
        timeSent: map['timeSent'],
        lastMessage: map['lastMessage'] as String,
        lastMessageId: map['lastMessageId'],
        uid: map['uid'] as String,
        unreadCount: map["unreadCount"],
        isGroup: map["isGroup"]);
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
    final int? lastMessageId,
    final String? uid,
    final int? unreadCount,
    final int? isGroup,
  }) {
    return ChatConntactModel(
      contactId: contactId ?? this.contactId,
      profilePic: profilePic ?? this.profilePic,
      name: name ?? this.name,
      timeSent: timeSent ?? this.timeSent,
      lastMessage: lastMessage ?? this.lastMessage,
      uid: uid ?? this.uid,
      lastMessageId: lastMessageId ?? this.lastMessageId,
      unreadCount: unreadCount ?? this.unreadCount,
      isGroup: isGroup?? this.isGroup,
    );
  }

  @override
  List<Object?> get props =>
      [name, profilePic, contactId, timeSent, lastMessage, uid, unreadCount, lastMessageId, isGroup
      ];
}
