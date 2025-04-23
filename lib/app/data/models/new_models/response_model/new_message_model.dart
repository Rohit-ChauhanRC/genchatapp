import 'package:equatable/equatable.dart';

import '../../../../constants/message_enum.dart';

class NewMessageModel extends Equatable{
  final int? messageId;
  final String? clientSystemMessageId;
  final int? senderId;
  final int? recipientId;
  final String? message;
  final MessageState? state;
  final String? messageSentFromDeviceTime;
  final String? createdAt;
  final SyncStatus? syncStatus;
  final String? senderPhoneNumber;

  NewMessageModel({
    this.messageId,
    this.clientSystemMessageId,
    this.senderId,
    this.recipientId,
    this.message,
    this.state = MessageState.sent,
    this.messageSentFromDeviceTime,
    this.createdAt,
    this.syncStatus = SyncStatus.pending,
    this.senderPhoneNumber,
  });

  factory NewMessageModel.fromMap(Map<String, dynamic> map) {
    assert(map['messageId'] != null, "messageId cannot be null");
    assert(map['senderId'] != null, "senderId cannot be null");
    assert(map['recipientId'] != null, "recipientId cannot be null");
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
      senderPhoneNumber: map['senderPhoneNumber'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'clientSystemMessageId': clientSystemMessageId,
      'senderId': senderId,
      'recipientId': recipientId,
      'message': message,
      'state': state!.value,
      'messageSentFromDeviceTime': messageSentFromDeviceTime,
      'createdAt': createdAt,
      'syncStatus': syncStatus!.value,
      'senderPhoneNumber': senderPhoneNumber,
    };
  }

  NewMessageModel copyWith({
    int? messageId,
    String? clientSystemMessageId,
    int? senderId,
    int? recipientId,
    String? message,
    MessageState? state,
    String? messageSentFromDeviceTime,
    String? createdAt,
    SyncStatus? syncStatus,
    String? senderPhoneNumber,
  }) {
    return NewMessageModel(
      clientSystemMessageId:
          clientSystemMessageId ?? this.clientSystemMessageId,
      message: message ?? this.message,
      messageId: messageId ?? this.messageId,
      senderId: senderId ?? this.senderId,
      recipientId: recipientId ?? this.recipientId,
      state: state ?? this.state,
      messageSentFromDeviceTime:
          messageSentFromDeviceTime ?? this.messageSentFromDeviceTime,
      createdAt: createdAt ?? this.createdAt,
      syncStatus: syncStatus ?? this.syncStatus,
      senderPhoneNumber: senderPhoneNumber ?? this.senderPhoneNumber,
    );
  }
  @override
  List<Object?> get props => [messageId];
}
