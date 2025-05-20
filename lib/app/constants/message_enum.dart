enum MessageEnum {
  text('text'),
  image('images'),
  audio('audios'),
  video('videos'),
  gif('gifs'),
  deleted('deleted'),
  document('documents');

  const MessageEnum(this.type);
  final String type;
}

// Using an extension
// Enhanced enums

extension ConvertMessage on String {
  MessageEnum toEnum() {
    switch (this) {
      case 'audios':
        return MessageEnum.audio;
      case 'images':
        return MessageEnum.image;
      case 'text':
        return MessageEnum.text;
      case 'gifs':
        return MessageEnum.gif;
      case 'videos':
        return MessageEnum.video;
      case 'documents':
        return MessageEnum.document;
      case 'deleted':
        return MessageEnum.deleted;
      default:
        return MessageEnum.text;
    }
  }

  MessageStatus toStatusEnum() {
    switch (this) {
      case "uploading":
        return MessageStatus.uploading;
      case "sent":
        return MessageStatus.sent;
      case "delivered":
        return MessageStatus.delivered;
      case "seen":
        return MessageStatus.seen;
      default:
        return MessageStatus.uploading;
    }
  }
}

enum MessageStatus {
  uploading("uploading"),
  sent("sent"),
  delivered("delivered"),
  seen("seen");

  const MessageStatus(this.type);
  final String type;
}

enum MessageState {
  unsent,     // 0
  sent,       // 1
  delivered,  // 2
  read        // 3
}

extension MessageStateExtension on MessageState {
  int get value {
    switch (this) {
      case MessageState.unsent:
        return 0;
      case MessageState.sent:
        return 1;
      case MessageState.delivered:
        return 2;
      case MessageState.read:
        return 3;
    }
  }

  static MessageState fromValue(int value) {
    switch (value) {
      case 1:
        return MessageState.sent;
      case 2:
        return MessageState.delivered;
      case 3:
        return MessageState.read;
      case 0:
      default:
        return MessageState.unsent;
    }
  }
}

enum SyncStatus {
  pending,
  synced
}

extension SyncStatusExtension on SyncStatus {
  String get value {
    switch (this) {
      case SyncStatus.pending:
        return 'pending';
      case SyncStatus.synced:
        return 'synced';
    }
  }

  static SyncStatus fromValue(String value) {
    switch (value) {
      case 'synced':
        return SyncStatus.synced;
      case 'pending':
      default:
        return SyncStatus.pending;
    }
  }
}

enum MessageType {
  text,
  image,
  audio,
  video,
  gif,
  deleted,
  document
}

extension MessageTypeExtension on MessageType{
  String get value {
    switch (this) {
      case MessageType.text:
        return 'text';
      case MessageType.image:
        return 'image';
      case MessageType.audio:
        return 'audio';
      case MessageType.video:
        return 'video';
      case MessageType.gif:
        return 'gif';
      case MessageType.deleted:
        return 'deleted';
      case MessageType.document:
        return 'document';
    }
  }

  static MessageType fromValue(String value) {
    switch (value) {
      case 'image':
        return MessageType.image;
      case 'video':
        return MessageType.video;
      case 'audio':
        return MessageType.audio;
      case 'gif':
        return MessageType.gif;
      case 'deleted':
        return MessageType.deleted;
      case 'document':
        return MessageType.document;
      case 'text':
      default:
        return MessageType.text;
    }
  }
}

