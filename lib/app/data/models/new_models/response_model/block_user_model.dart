import 'package:equatable/equatable.dart';

// {blockedBy: 3, isBlock: true}

class BlockUserModel extends Equatable {
  final int? blockedBy;

  final bool? isBlock;

  const BlockUserModel({this.blockedBy, this.isBlock});

  factory BlockUserModel.fromMap(Map<String, dynamic> map) {
    // assert(map['messageId'] != null, "messageId cannot be null");
    // assert(map['senderId'] != null, "senderId cannot be null");
    // assert(map['recipientId'] != null, "recipientId cannot be null");
    return BlockUserModel(blockedBy: map['blockedBy'], isBlock: map['isBlock']);
  }

  Map<String, dynamic> toMap() {
    return {'blockedBy': blockedBy, 'isBlock': isBlock};
  }

  BlockUserModel copyWith({int? blockedBy, bool? isBlock}) {
    return BlockUserModel(
      blockedBy: blockedBy ?? this.blockedBy,
      isBlock: isBlock ?? this.isBlock,
    );
  }

  @override
  List<Object?> get props => [isBlock, blockedBy];
}
