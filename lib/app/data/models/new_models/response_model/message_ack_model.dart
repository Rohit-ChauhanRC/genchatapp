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

class ReadOnlyAdmin {
  final int groupId;
  final bool isReadOnly;

  ReadOnlyAdmin({required this.groupId, required this.isReadOnly});
}

class VanishModeAutoDelete {
  final int groupId;
  final int userId;
  final bool autoDeleteMessages;

  VanishModeAutoDelete({
    required this.groupId,
    required this.autoDeleteMessages,
    required this.userId,
  });
}
