class MessageAckModel {
  final String clientSystemMessageId;
  final int state;
  final int messageId;

  MessageAckModel({
    required this.clientSystemMessageId,
    required this.state,
    required this.messageId,
  });
}


class DeletedMessageModel {
  final int messageId;
  final bool isDeleteFromEveryone;

  DeletedMessageModel({
    required this.messageId,
    required this.isDeleteFromEveryone,
  });
}