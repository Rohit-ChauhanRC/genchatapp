import 'dart:async';
import 'package:flutter/material.dart';
import 'package:genchatapp/app/config/theme/app_colors.dart';
import 'package:genchatapp/app/constants/message_enum.dart';
import 'package:genchatapp/app/modules/singleChat/controllers/single_chat_controller.dart';
import 'package:genchatapp/app/modules/singleChat/widgets/typping_bubble.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'my_message_card.dart';
import 'sender_message_card.dart';

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

class ChatList extends StatelessWidget {
  const ChatList({
    super.key,
    required this.singleChatController,
  });

  final SingleChatController singleChatController;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Obx(() {
          if (singleChatController.messageList.isEmpty) {
            return const Center(
              child: Text(
                "No messages yet!",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final isTyping =
              singleChatController.isReceiverTyping &&
                  singleChatController.blocked == false;

          final messageCount = singleChatController.messageList.length;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!singleChatController.hasScrolledInitially.value &&
                singleChatController.messageList.isNotEmpty) {
              singleChatController.scrollToBottom();
              singleChatController.hasScrolledInitially.value = true;
            }
          });

          return RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(const Duration(milliseconds: 500));
              await singleChatController.loadMoreMessages();
            },
            child: ScrollablePositionedList.builder(
              itemScrollController: singleChatController.itemScrollController,
              itemPositionsListener: singleChatController.itemPositionsListener,
              itemCount: messageCount + (isTyping ? 1 : 0),
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                if (isTyping && index == messageCount) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: TypingBubble(),
                  );
                }

                var messages = singleChatController.messageList[index];

                final id =
                (messages.messageId ?? messages.clientSystemMessageId)
                    .toString();

                singleChatController.messageIdToIndex[id] = index;




                bool showHeader = false;

                final msgDate = DateTime.tryParse(messages.messageSentFromDeviceTime ?? "") ??
                    DateTime.fromMillisecondsSinceEpoch(0);

                if (index == 0) {
                  showHeader = true;
                } else {
                  final prevMsg = singleChatController.messageList[index - 1];

                  final prevDate =
                      DateTime.tryParse(prevMsg.messageSentFromDeviceTime ?? "") ??
                          DateTime.fromMillisecondsSinceEpoch(0);

                  // If day changes → show header above this message
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
                      singleChatController.highlightedMessageId,
                      builder: (context, highlightId, _) {
                        final isHighlighted =
                            highlightId == messages.messageId.toString();

                        return InkWell(
                          key: UniqueKey(),
                          onLongPress: () =>
                              singleChatController.toggleMessageSelection(
                                  messages),
                          onTap: () {
                            singleChatController.hideKeyboard();
                            if (singleChatController
                                .selectedMessages.isNotEmpty) {
                              singleChatController.toggleMessageSelection(
                                  messages);
                            }
                          },
                          child: Obx(() {
                            bool isMsgSelected = singleChatController
                                .selectedMessages
                                .contains(messages);

                            final bgColor = isMsgSelected || isHighlighted
                                ? AppColors.mySideBgColor.withOpacity(0.3)
                                : Colors.transparent;

                            final isMine = messages.senderId ==
                                singleChatController.senderuserData?.userId;

                            return Container(
                              color: bgColor,
                              child: isMine
                                  ? Column(
                                children: [
                                  MyMessageCard(
                                    percent: singleChatController.percent,
                                    isProgess:
                                    singleChatController.percent,
                                    audioMessage:
                                    messages.message ?? "",
                                    message: messages.messageType ==
                                        MessageType.text ||
                                        messages.messageType ==
                                            MessageType.deleted
                                        ? (messages.message!.isNotEmpty
                                        ? messages.message.toString()
                                        : '')
                                        : (messages
                                        .assetServerName ??
                                        ''),
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
                                    syncStatus:
                                    messages.syncStatus ??
                                        SyncStatus.pending,
                                    onLeftSwipe: messages.messageType ==
                                        MessageType.deleted
                                        ? null
                                        : (v) {
                                      singleChatController
                                          .onMessageSwipe(
                                        isMe: true,
                                        message: messages.messageType !=
                                            MessageType.text
                                            ? messages
                                            .assetServerName
                                            .toString()
                                            : messages.message
                                            .toString(),
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
                                    repliedText: (messages.messageRepliedOn ?? '').obs,

                                    repliedUserId:
                                    messages.messageRepliedUserId,
                                    repliedUserName: messages
                                        .messageRepliedUserId !=
                                        0
                                        ? messages.messageRepliedUserId ==
                                        singleChatController
                                            .senderuserData!
                                            .userId
                                        ? "You"
                                        : singleChatController
                                        .receiverUserData!
                                        .localName ??
                                        ""
                                        : "username",
                                    repliedAssetServerName: messages
                                        .messageRepliedOnAssetServerName,
                                    repliedThumbnail: messages
                                        .messageRepliedOnAssetThumbnail,
                                    onReplyTap: () =>
                                        singleChatController
                                            .scrollToOriginalMessage(
                                          messages.messageRepliedOnId!,
                                        ),
                                    isHighlighted: isHighlighted,
                                    isForwarded: messages.isForwarded!,
                                    showForwarded:
                                    messages.showForwarded!,
                                    isAsset: messages.isAsset!,
                                    onRetryTap: () async {
                                      await singleChatController
                                          .retryPendingMediaFile(
                                          messages);
                                    },
                                    url: messages.assetUrl,
                                    isRetryUploadFile:
                                    messages.isRetrying ?? false.obs,
                                    assetThumbnail:
                                    messages.assetThumbnail,
                                  ),
                                ],
                              )
                                  : SenderMessageCard(
                                message: messages.messageType ==
                                    MessageType.text ||
                                    messages.messageType ==
                                        MessageType.deleted
                                    ? (messages.message!.isNotEmpty
                                    ? messages.message.toString()
                                    : '')
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
                                  singleChatController
                                      .onMessageSwipe(
                                    isMe: false,
                                    message: messages.messageType !=
                                        MessageType.text
                                        ? messages
                                        .assetServerName
                                        .toString()
                                        : messages.message
                                        .toString(),
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
                                repliedText: (messages.messageRepliedOn ?? '').obs,

                                repliedUserId:
                                messages.messageRepliedUserId,
                                repliedUserName: messages
                                    .messageRepliedUserId !=
                                    0 &&
                                    messages.messageRepliedUserId !=
                                        null
                                    ? messages.messageRepliedUserId ==
                                    singleChatController
                                        .senderuserData!
                                        .userId
                                    ? "You"
                                    : singleChatController
                                    .receiverUserData!
                                    .localName ??
                                    ""
                                    : "username",
                                repliedAssetServerName: messages
                                    .messageRepliedOnAssetServerName,
                                repliedThumbnail: messages
                                    .messageRepliedOnAssetThumbnail,
                                onReplyTap: () =>
                                    singleChatController
                                        .scrollToOriginalMessage(
                                      messages.messageRepliedOnId!,
                                    ),
                                isHighlighted: isHighlighted,
                                isForwarded: messages.isForwarded!,
                                showForwarded:
                                messages.showForwarded!,
                                url: messages.assetUrl,
                                assetThumbnail:
                                messages.assetThumbnail,
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
        Obx(() {
          return singleChatController.showScrollToBottom.value
              ? Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              mini: true,
              onPressed: () => singleChatController.scrollToBottom(),
              child: const Icon(Icons.arrow_downward),
            ),
          )
              : const SizedBox.shrink();
        }),
      ],
    );
  }
}
