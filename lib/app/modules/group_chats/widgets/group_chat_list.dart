import 'dart:async';
import 'package:flutter/material.dart';
import 'package:genchatapp/app/config/theme/app_colors.dart';
import 'package:genchatapp/app/constants/message_enum.dart';
import 'package:genchatapp/app/modules/group_chats/controllers/group_chats_controller.dart';
import 'package:genchatapp/app/modules/singleChat/widgets/typping_bubble.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'group_my_message_card.dart';
import 'group_sender_message_card.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:genchatapp/app/config/theme/app_colors.dart';
import 'package:genchatapp/app/constants/message_enum.dart';
import 'package:genchatapp/app/modules/group_chats/controllers/group_chats_controller.dart';
import 'package:genchatapp/app/modules/singleChat/widgets/typping_bubble.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'group_my_message_card.dart';
import 'group_sender_message_card.dart';

///FOR DATE AT TOP

String getChatHeaderLabel(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final msgDate = DateTime(date.year, date.month, date.day);
  final diff = today.difference(msgDate).inDays;

  if (diff == 0) return "Today";
  if (diff == 1) return "Yesterday";

  return "${msgDate.day.toString().padLeft(2, '0')} "
      "${_monthName(msgDate.month)} "
      "${msgDate.year}";
}

String _monthName(int m) {
  const months = [
    "Jan","Feb","Mar","Apr","May","Jun",
    "Jul","Aug","Sep","Oct","Nov","Dec"
  ];
  return months[m - 1];
}


class GroupChatList extends StatelessWidget {
  const GroupChatList({
    super.key,
    required this.groupChatsController,
  });

  final GroupChatsController groupChatsController;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Obx(() {
          if (groupChatsController.messageList.isEmpty) {
            return const Center(
              child: Text(
                "No messages yet!",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final isTyping = groupChatsController.typingDisplayText.isNotEmpty;
          final messageCount = groupChatsController.messageList.length;

          return RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(const Duration(milliseconds: 500));
              await groupChatsController.loadMoreMessages();
            },
            child: ScrollablePositionedList.builder(
              itemScrollController: groupChatsController.itemScrollController,
              itemPositionsListener:
              groupChatsController.itemPositionsListener,
              itemCount: messageCount + (isTyping ? 1 : 0),
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                if (isTyping && index == messageCount) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: TypingBubble(),
                  );
                }

                var messages = groupChatsController.messageList[index];

                final id =
                (messages.messageId ?? messages.clientSystemMessageId)
                    .toString();

                groupChatsController.messageIdToIndex[id] = index;
///FOR DATE AT TOP

                bool showHeader = false;

                final msgDate = DateTime.tryParse(messages.messageSentFromDeviceTime ?? "") ??
                    DateTime.fromMillisecondsSinceEpoch(0);

                if (index == 0) {
                  showHeader = true;
                } else {
                  final prevMsg = groupChatsController.messageList[index - 1];

                  final prevDate = DateTime.tryParse(
                    prevMsg.messageSentFromDeviceTime ?? "",
                  ) ??
                      DateTime.fromMillisecondsSinceEpoch(0);

                  if (msgDate.year != prevDate.year ||
                      msgDate.month != prevDate.month ||
                      msgDate.day != prevDate.day) {
                    showHeader = true;
                  }
                }
                return Column(
                  children: [
                    if (showHeader)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 5,
                              horizontal: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              getChatHeaderLabel(msgDate),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ValueListenableBuilder<String?>(
                      valueListenable:
                      groupChatsController.highlightedMessageId,
                      builder: (context, highlightId, _) {
                        final isHighlighted =
                            highlightId == messages.messageId.toString();

                        return InkWell(
                          key: UniqueKey(),
                          onLongPress: () =>
                              groupChatsController.toggleMessageSelection(
                                  messages),
                          onTap: () {
                            groupChatsController.hideKeyboard();
                            if (groupChatsController
                                .selectedMessages.isNotEmpty) {
                              groupChatsController.toggleMessageSelection(
                                  messages);
                            }
                          },
                          child: Obx(() {
                            bool isMsgSelected = groupChatsController
                                .selectedMessages
                                .contains(messages);

                            final bgColor = isMsgSelected || isHighlighted
                                ? AppColors.mySideBgColor.withOpacity(0.3)
                                : Colors.transparent;

                            final isMine = messages.senderId ==
                                groupChatsController.senderuserData?.userId;

                            final messageSenderName =
                                groupChatsController.senderNamesCache[
                                messages.senderId ?? 0] ??
                                    "";

                            final replyMessageSenderName =
                                groupChatsController.senderNamesCache[
                                messages.messageRepliedUserId ?? 0] ??
                                    "";

                            return Container(
                              color: bgColor,
                              child: isMine
                                  ? GroupMyMessageCard(
                                audioMessage: messages.message ?? "",
                                message:
                                messages.messageType ==
                                    MessageType.text ||
                                    messages.messageType ==
                                        MessageType.deleted
                                    ? (messages.message ?? '')
                                    : (messages.assetServerName ?? ''),
                                date: DateFormat('hh:mm a').format(
                                  DateTime.parse(
                                    messages.messageSentFromDeviceTime ??
                                        '',
                                  ),
                                ),
                                type: messages.messageType ??
                                    MessageType.text,
                                status: messages.state ??
                                    MessageState.unsent,
                                syncStatus: messages.syncStatus ??
                                    SyncStatus.pending,
                                onLeftSwipe:
                                messages.messageType ==
                                    MessageType.deleted
                                    ? null
                                    : (v) {
                                  groupChatsController
                                      .onMessageSwipe(
                                    recipientUserId:
                                    groupChatsController
                                        .receiverUserData!
                                        .group!
                                        .id!,
                                    senderName: "",
                                    isMe: true,
                                    message: messages.message ??
                                        '',
                                    messageType:
                                    messages.messageType ??
                                        MessageType.text,
                                    isReplied: true,
                                    messageId:
                                    messages.messageId ?? 0,
                                    assetsThumbnail:
                                    messages.assetThumbnail ??
                                        "",
                                  );
                                },
                                repliedMessageType:
                                messages.messageRepliedOnType ??
                                    MessageType.text,
                                repliedText:
                                (messages.messageRepliedOn ?? '')
                                    .obs,
                                repliedUserId:
                                messages.messageRepliedUserId,
                                repliedUserName:
                                messages.messageRepliedUserId != 0
                                    ? messages.messageRepliedUserId ==
                                    groupChatsController
                                        .senderuserData!
                                        .userId
                                    ? "You"
                                    : replyMessageSenderName
                                    : "username",
                                repliedThumbnail: messages
                                    .messageRepliedOnAssetThumbnail,
                                repliedAssetServerName: messages
                                    .messageRepliedOnAssetServerName,
                                isAsset: messages.isAsset ?? false,
                                onReplyTap: () => groupChatsController
                                    .scrollToOriginalMessage(
                                  messages.messageRepliedOnId!,
                                ),
                                onRetryTap: () async {
                                  await groupChatsController
                                      .retryPendingMediaFile(messages);
                                },
                                isRetryUploadFile:
                                messages.isRetrying ?? false.obs,
                                isHighlighted: isHighlighted,
                                isForwarded: messages.isForwarded ?? false,
                                showForwarded:
                                messages.showForwarded ?? false,
                                url: messages.assetUrl,
                                assetThumbnail:
                                messages.assetThumbnail,
                              )
                                  : GroupSenderMessageCard(
                                message:
                                messages.messageType ==
                                    MessageType.text ||
                                    messages.messageType ==
                                        MessageType.deleted
                                    ? (messages.message ?? '')
                                    : (messages.assetServerName ?? ''),
                                date: DateFormat('hh:mm a').format(
                                  DateTime.parse(
                                    messages.messageSentFromDeviceTime ??
                                        '',
                                  ),
                                ),
                                type: messages.messageType ??
                                    MessageType.text,
                                onRightSwipe:
                                messages.messageType ==
                                    MessageType.deleted
                                    ? null
                                    : (v) {
                                  groupChatsController
                                      .onMessageSwipe(
                                    isMe: false,
                                    message:
                                    messages.message ?? '',
                                    messageType:
                                    messages.messageType ??
                                        MessageType.text,
                                    isReplied: true,
                                    messageId:
                                    messages.messageId ?? 0,
                                    senderName:
                                    messageSenderName,
                                    recipientUserId:
                                    messages.senderId ?? 0,
                                    assetsThumbnail:
                                    messages.assetThumbnail ??
                                        "",
                                  );
                                },
                                repliedMessageType:
                                messages.messageRepliedOnType ??
                                    MessageType.text,
                                repliedText:
                                (messages.messageRepliedOn ?? '')
                                    .obs,
                                repliedUserId:
                                messages.messageRepliedUserId,
                                repliedUserName:
                                messages.messageRepliedUserId != 0 &&
                                    messages.messageRepliedUserId !=
                                        null
                                    ? messages.messageRepliedUserId ==
                                    groupChatsController
                                        .senderuserData!
                                        .userId
                                    ? "You"
                                    : replyMessageSenderName
                                    : "username",
                                onReplyTap: () =>
                                    groupChatsController
                                        .scrollToOriginalMessage(
                                      messages.messageRepliedOnId!,
                                    ),
                                assetThumbnail:
                                messages.assetThumbnail,
                                repliedThumbnail: messages
                                    .messageRepliedOnAssetThumbnail,
                                repliedAssetServerName: messages
                                    .messageRepliedOnAssetServerName,
                                isHighlighted: isHighlighted,
                                isForwarded:
                                messages.isForwarded ?? false,
                                showForwarded:
                                messages.showForwarded ?? false,
                                senderName: messageSenderName,
                                url: messages.assetUrl,
                              ),
                            );
                          }),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          );
        }),

        // Scroll-to-bottom arrow
        Obx(() {
          return groupChatsController.showScrollToBottom.value
              ? Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              mini: true,
              onPressed: () => groupChatsController.scrollToBottom(),
              child: const Icon(Icons.arrow_downward),
            ),
          )
              : const SizedBox.shrink();
        }),
      ],
    );
  }
}
