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
