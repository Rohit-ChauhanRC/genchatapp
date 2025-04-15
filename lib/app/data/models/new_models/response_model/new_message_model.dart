

import '../../../../constants/message_enum.dart';

class NewMessageModel {
  final int? messageId;
  final String clientSystemMessageId;
  final int senderId;
  final int recipientId;
  final String message;
  final MessageState state;
  final String messageSentFromDeviceTime;
  final String createdAt;
  final SyncStatus syncStatus;

  NewMessageModel({
    this.messageId,
    required this.clientSystemMessageId,
    required this.senderId,
    required this.recipientId,
    required this.message,
    this.state = MessageState.sent,
    required this.messageSentFromDeviceTime,
    required this.createdAt,
    this.syncStatus = SyncStatus.pending,
  });

  factory NewMessageModel.fromMap(Map<String, dynamic> map) {
    return NewMessageModel(
      messageId: map['messageId'],
      clientSystemMessageId: map['clientSystemMessageId'],
      senderId: map['senderId'],
      recipientId: map['recipientId'],
      message: map['message'],
      state: MessageStateExtension.fromValue(map['state']),
      messageSentFromDeviceTime: map['messageSentFromDeviceTime'],
      createdAt: map['createdAt'],
      syncStatus: SyncStatusExtension.fromValue(map['syncStatus']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'clientSystemMessageId': clientSystemMessageId,
      'senderId': senderId,
      'recipientId': recipientId,
      'message': message,
      'state': state.value,
      'messageSentFromDeviceTime': messageSentFromDeviceTime,
      'createdAt': createdAt,
      'syncStatus': syncStatus.value,
    };
  }
}
