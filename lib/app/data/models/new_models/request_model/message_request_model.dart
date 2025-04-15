import 'package:genchatapp/app/constants/message_enum.dart';

class MessageRequestModel {
  String? recipientId;
  String? message;
  String? clientSystemMessageId;
  String? messageSentFromDeviceTime;
  SyncStatus? syncStatus;

  MessageRequestModel({
    this.recipientId,
    this.message,
    this.clientSystemMessageId,
    this.messageSentFromDeviceTime,
    this.syncStatus = SyncStatus.pending,
  });

  MessageRequestModel copyWith({
    String? recipientId,
    String? message,
    String? clientSystemMessageId,
    String? messageSentFromDeviceTime,
    SyncStatus? syncStatus,
  }) =>
      MessageRequestModel(
        recipientId: recipientId ?? this.recipientId,
        message: message ?? this.message,
        clientSystemMessageId:
            clientSystemMessageId ?? this.clientSystemMessageId,
        messageSentFromDeviceTime:
            messageSentFromDeviceTime ?? this.messageSentFromDeviceTime,
        syncStatus: syncStatus ?? this.syncStatus,
      );
}
