import 'package:genchatapp/app/constants/message_enum.dart';

class MessageReply {
  late final String? message;
  late final bool? isMe;
  late final MessageType? messageType;
  late final int? messageId;
  late final bool? isReplied;

  MessageReply({
    this.message,
    this.isMe,
    this.messageType,
    this.messageId,
    this.isReplied,
  });
}
