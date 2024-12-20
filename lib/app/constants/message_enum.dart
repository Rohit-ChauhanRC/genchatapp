enum MessageEnum {
  text('text'),
  image('image'),
  audio('audio'),
  video('video'),
  gif('gif'),
  deleted('deleted'),
  document('document');

  const MessageEnum(this.type);
  final String type;
}

// Using an extension
// Enhanced enums

extension ConvertMessage on String {
  MessageEnum toEnum() {
    switch (this) {
      case 'audio':
        return MessageEnum.audio;
      case 'image':
        return MessageEnum.image;
      case 'text':
        return MessageEnum.text;
      case 'gif':
        return MessageEnum.gif;
      case 'video':
        return MessageEnum.video;
      case 'document':
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
