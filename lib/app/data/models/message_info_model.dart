// To parse this JSON data, do
//
//     final messageInfoModel = messageInfoModelFromJson(jsonString);

import 'dart:convert';

MessageInfoModel messageInfoModelFromJson(String str) =>
    MessageInfoModel.fromJson(json.decode(str));

String messageInfoModelToJson(MessageInfoModel data) =>
    json.encode(data.toJson());

class MessageInfoModel {
  int id;
  int messageId;
  int eventRecipientId;
  String eventName;
  bool eventEmitted;
  String createdAt;
  String sentAt;

  MessageInfoModel({
    required this.id,
    required this.messageId,
    required this.eventRecipientId,
    required this.eventName,
    required this.eventEmitted,
    required this.createdAt,
    required this.sentAt,
  });

  factory MessageInfoModel.fromJson(Map<String, dynamic> json) =>
      MessageInfoModel(
        id: json["id"],
        messageId: json["messageId"],
        eventRecipientId: json["eventRecipientId"],
        eventName: json["eventName"],
        eventEmitted: json["eventEmitted"] == 1 || json["eventEmitted"] == true,
        createdAt: json["createdAt"],
        sentAt: json["sentAt"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "messageId": messageId,
    "eventRecipientId": eventRecipientId,
    "eventName": eventName,
    "eventEmitted": eventEmitted == true ? 1 : 0,
    "createdAt": createdAt.toString(),
    "sentAt": sentAt.toString(),
  };
}
