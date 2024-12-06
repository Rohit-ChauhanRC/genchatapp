import 'package:genchatapp/app/constants/message_enum.dart';

class MessageReply {
  late final String? message;
  late final bool? isMe;
  late final MessageEnum? messageEnum;
  late final String? messageId;

  MessageReply({
    this.message,
    this.isMe,
    this.messageEnum,
    this.messageId,
  });
}
