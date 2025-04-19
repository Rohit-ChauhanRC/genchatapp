import '../../../../constants/message_enum.dart';

class NewMessageModel {
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
    final int? messageId,
    final String? clientSystemMessageId,
    final int? senderId,
    final int? recipientId,
    final String? message,
    final MessageState? state,
    final String? messageSentFromDeviceTime,
    final String? createdAt,
    final SyncStatus? syncStatus,
    final String? senderPhoneNumber,
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
}
