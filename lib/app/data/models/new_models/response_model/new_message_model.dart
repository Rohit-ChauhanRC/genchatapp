import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/route_manager.dart';

import '../../../../constants/message_enum.dart';

class NewMessageModel extends Equatable {
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
  final MessageType? messageType;
  final bool? isForwarded;
  final int? forwardedMessageId;
  final bool? isRepliedMessage;
  final int? messageRepliedOnId;
  final String? messageRepliedOn;
  final MessageType? messageRepliedOnType;
  final bool? isAsset;
  final String? assetOriginalName;
  final String? assetServerName;
  final String? assetUrl;
  final int? messageRepliedUserId;
  final BuildContext? context;
  final GlobalKey? keys;
  final bool? showForwarded;

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
    this.messageType,
    this.isForwarded,
    this.forwardedMessageId,
    this.isRepliedMessage,
    this.messageRepliedOnId,
    this.messageRepliedOn,
    this.messageRepliedOnType,
    this.isAsset,
    this.assetOriginalName,
    this.assetServerName,
    this.assetUrl,
    this.messageRepliedUserId,
    this.showForwarded,
  })  : context = Get.context,
        keys = GlobalKey();

  factory NewMessageModel.fromMap(Map<String, dynamic> map) {
    // assert(map['messageId'] != null, "messageId cannot be null");
    // assert(map['senderId'] != null, "senderId cannot be null");
    // assert(map['recipientId'] != null, "recipientId cannot be null");
    return NewMessageModel(
      messageId: map['messageId'],
      clientSystemMessageId: map['clientSystemMessageId'],
      senderId: map['senderId'],
      recipientId: map['recipientId'],
      message: map['message'],
      state: map['state'] != null
          ? MessageStateExtension.fromValue(map['state'])
          : MessageState.sent,
      messageSentFromDeviceTime: map['messageSentFromDeviceTime'],
      createdAt: map['createdAt'],
      syncStatus: map['syncStatus'] != null
          ? SyncStatusExtension.fromValue(map['syncStatus'])
          : SyncStatus.synced,
      senderPhoneNumber: map['senderPhoneNumber'] ?? '',
      messageType: map['messageType'] != null
          ? MessageTypeExtension.fromValue(map['messageType'])
          : MessageType.text,
      isForwarded: map['isForwarded'] == 1 || map['isForwarded'] == true,
      showForwarded: map['showForwarded'] == 1 || map['showForwarded'] == true,
      forwardedMessageId: map['forwardedMessageId'],
      isRepliedMessage:
          map['isRepliedMessage'] == 1 || map['isRepliedMessage'] == true,
      messageRepliedOnId: map['messageRepliedOnId'],
      messageRepliedOn: map['messageRepliedOn'] ?? '',
      messageRepliedOnType: map['messageRepliedOnType'] != null
          ? MessageTypeExtension.fromValue(map['messageRepliedOnType'])
          : null,
      isAsset: map['isAsset'] == 1 || map['isAsset'] == true,
      assetOriginalName: map['assetOriginalName'] ?? '',
      assetServerName: map['assetServerName'] ?? '',
      assetUrl: map['assetUrl'] ?? '',
      messageRepliedUserId: map['messageRepliedUserId'],
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
      'syncStatus': syncStatus?.value,
      'senderPhoneNumber': senderPhoneNumber,
      'messageType': messageType?.value,
      'isForwarded': isForwarded == true ? 1 : 0,
      'forwardedMessageId': forwardedMessageId,
      'isRepliedMessage': isRepliedMessage == true ? 1 : 0,
      'messageRepliedOnId': messageRepliedOnId ?? 0,
      'messageRepliedOn': messageRepliedOn ?? '',
      'messageRepliedOnType': messageRepliedOnType?.value ?? '',
      'isAsset': isAsset == true ? 1 : 0,
      'assetOriginalName': assetOriginalName,
      'assetServerName': assetServerName,
      'assetUrl': assetUrl,
      'messageRepliedUserId': messageRepliedUserId,
      'showForwarded': showForwarded == true ? 1 : 0,
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
    MessageType? messageType,
    bool? isForwarded,
    int? forwardedMessageId,
    bool? isRepliedMessage,
    int? messageRepliedOnId,
    String? messageRepliedOn,
    MessageType? messageRepliedOnType,
    bool? isAsset,
    String? assetOriginalName,
    String? assetServerName,
    String? assetUrl,
    int? messageRepliedUserId,
    bool? showForwarded,
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
      messageType: messageType ?? this.messageType,
      isForwarded: isForwarded ?? this.isForwarded,
      forwardedMessageId: forwardedMessageId ?? this.forwardedMessageId,
      isRepliedMessage: isRepliedMessage ?? this.isRepliedMessage,
      messageRepliedOnId: messageRepliedOnId ?? this.messageRepliedOnId,
      messageRepliedOn: messageRepliedOn ?? this.messageRepliedOn,
      messageRepliedOnType: messageRepliedOnType ?? this.messageRepliedOnType,
      isAsset: isAsset ?? this.isAsset,
      assetOriginalName: assetOriginalName ?? this.assetOriginalName,
      assetServerName: assetServerName ?? this.assetServerName,
      assetUrl: assetUrl ?? this.assetUrl,
      messageRepliedUserId: messageRepliedUserId ?? this.messageRepliedUserId,
      showForwarded: showForwarded ?? this.showForwarded,
    );
  }

  @override
  List<Object?> get props => [messageId ?? clientSystemMessageId];
}
