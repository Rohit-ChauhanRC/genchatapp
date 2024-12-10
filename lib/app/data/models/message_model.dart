import 'package:genchatapp/app/constants/message_enum.dart';

class MessageModel {
  
  final String senderId;
  final String receiverId;
  final String text;
  final MessageEnum type;
  final DateTime timeSent;
  final String messageId;
  
  final MessageStatus status;
  final String repliedMessage;
  final String repliedTo;
  final MessageEnum repliedMessageType;
  late final String syncStatus;

  MessageModel({
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.type,
    required this.timeSent,
    required this.messageId,
 
    required this.repliedMessage,
    required this.repliedTo,
    required this.repliedMessageType,
    required this.status,
    this.syncStatus = 'pending',
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'type': type.type,
      'timeSent': timeSent.millisecondsSinceEpoch,
      'messageId': messageId,
      'status': status.type,
      'repliedMessage': repliedMessage,
      'repliedTo': repliedTo,
      'repliedMessageType': repliedMessageType.type,
      'syncStatus': syncStatus,
    };
  }
  // Add the copyWith method
  MessageModel copyWith({
    String? senderId,
    String? receiverId,
    String? text,
    MessageEnum? type,
    DateTime? timeSent,
    String? messageId,
    MessageStatus? status,
    String? repliedMessage,
    String? repliedTo,
    MessageEnum? repliedMessageType,
    String? syncStatus,
  }) {
    return MessageModel(
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      text: text ?? this.text,
      type: type ?? this.type,
      timeSent: timeSent ?? this.timeSent,
      messageId: messageId ?? this.messageId,
      status: status ?? this.status,
      repliedMessage: repliedMessage ?? this.repliedMessage,
      repliedTo: repliedTo ?? this.repliedTo,
      repliedMessageType: repliedMessageType ?? this.repliedMessageType,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }


  factory MessageModel.fromMap(Map<String, dynamic> map) {
    assert(map['messageId'] != null, "messageId cannot be null");
    assert(map['senderId'] != null, "senderId cannot be null");
    assert(map['receiverId'] != null, "receiverId cannot be null");

    // Debugging: Log the map
    print("Converting map to MessageModel: $map");
    return MessageModel(
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      text: map['text'] ?? '',
      type: (map['type'] as String).toEnum(),
      timeSent: DateTime.fromMillisecondsSinceEpoch(map['timeSent']),
      messageId: map['messageId'] ?? '',
      status:( map['status']  as String).toStatusEnum() ,
      repliedMessage: map['repliedMessage'] ?? '',
      repliedTo: map['repliedTo'] ?? '',
      repliedMessageType: (map['repliedMessageType'] as String).toEnum(),
      syncStatus: map['syncStatus'] ?? 'pending',
    );
  }
}
