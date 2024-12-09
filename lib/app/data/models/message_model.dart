import 'package:genchatapp/app/constants/message_enum.dart';

class MessageModel {
  
  final String senderId;
  final String receieverid;
  final String text;
  final MessageEnum type;
  final dynamic timeSent;
  final String messageId;
  
  final MessageStatus status;
  final String repliedMessage;
  final String repliedTo;
  final MessageEnum repliedMessageType;

  MessageModel({
    required this.senderId,
    required this.receieverid,
    required this.text,
    required this.type,
    required this.timeSent,
    required this.messageId,
 
    required this.repliedMessage,
    required this.repliedTo,
    required this.repliedMessageType,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receieverid': receieverid,
      'text': text,
      'type': type.type,
      'timeSent': timeSent.millisecondsSinceEpoch,
      'messageId': messageId,
      'status': status.type,
      'repliedMessage': repliedMessage,
      'repliedTo': repliedTo,
      'repliedMessageType': repliedMessageType.type,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      senderId: map['senderId'] ?? '',
      receieverid: map['receieverid '] ?? '',
      text: map['text'] ?? '',
      type: (map['type'] as String).toEnum(),
      timeSent: DateTime.fromMillisecondsSinceEpoch(map['timeSent']),
      messageId: map['messageId'] ?? '',
      status:( map['status']  as String).toStatusEnum() ,
      repliedMessage: map['repliedMessage'] ?? '',
      repliedTo: map['repliedTo'] ?? '',
      repliedMessageType: (map['repliedMessageType'] as String).toEnum(),
    );
  }
}
