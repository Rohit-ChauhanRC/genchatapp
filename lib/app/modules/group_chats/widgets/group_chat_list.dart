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

class GroupChatList extends StatelessWidget {
  const GroupChatList({
    super.key,
    required this.groupChatsController,
    // required this.firebaseController,
  });

  final GroupChatsController groupChatsController;
  // final FirebaseController firebaseController;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Obx(() {
          // if (groupChatsController.isLoading) {
          //   return loadingWidget(text: "Fetching data please wait....");
          // }
          if (groupChatsController.messageList.isEmpty) {
            return const Center(
                child: Text(
              "No messages yet!",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ));
          }

          final isTyping = groupChatsController.typingDisplayText.isNotEmpty;
          final messageCount = groupChatsController.messageList.length;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!groupChatsController.hasScrolledInitially.value &&
                groupChatsController.messageList.isNotEmpty) {
              groupChatsController.scrollToBottom();
              groupChatsController.hasScrolledInitially.value = true;
            }
          });

          return NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification notification) {
              if (notification.metrics.pixels <= 0) {
                // At the top, allow pull-to-refresh
                return true; // Let RefreshIndicator receive it
              }
              return false;
            },
            child: RefreshIndicator(
              onRefresh: () async {
                // Optional: show a loader for a second for smooth UX
                await Future.delayed(const Duration(milliseconds: 500));
                await groupChatsController.loadMoreMessages();
              },
              edgeOffset: 0,
              displacement: 40,
              child: ScrollablePositionedList.builder(
                itemScrollController: groupChatsController.itemScrollController,
                itemPositionsListener:
                    groupChatsController.itemPositionsListener,
                itemCount: messageCount + (isTyping ? 1 : 0),
                // physics: const ClampingScrollPhysics(),
                physics: const BouncingScrollPhysics(
                    decelerationRate: ScrollDecelerationRate.normal),
                itemBuilder: (context, index) {
                  if (isTyping && index == messageCount) {
                    return const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: TypingBubble(), // 👈 your animated dots widget
                    );
                  }

                  var messages = groupChatsController.messageList[index];

                  final id =
                      (messages.messageId ?? messages.clientSystemMessageId)
                          .toString();

                  groupChatsController.messageIdToIndex[id] = index;

                  // groupChatsController.messageKeys
                  //     .putIfAbsent(id, () => GlobalKey());
                  return ValueListenableBuilder<String?>(
                      valueListenable:
                          groupChatsController.highlightedMessageId,
                      builder: (context, highlightId, _) {
                        final isHighlighted =
                            highlightId == messages.messageId.toString();

                        return InkWell(
                          key: UniqueKey(),
                          onLongPress: () {
                            groupChatsController
                                .toggleMessageSelection(messages);
                            print("selected Multiple Taps");
                          },
                          onTap: () {
                            groupChatsController.hideKeyboard();
                            if (groupChatsController
                                .selectedMessages.isNotEmpty) {
                              groupChatsController
                                  .toggleMessageSelection(messages);
                              print("selected tap");
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
                            final messageSenderName = groupChatsController.senderNamesCache[messages.senderId ?? 0] ?? "";
                            final replyMessageSenderName = groupChatsController.senderNamesCache[messages.messageRepliedUserId ?? 0] ?? "";
                            return Container(
                              color: bgColor,
                              child: isMine
                                  ? GroupMyMessageCard(
                                      message: messages.messageType ==
                                                  MessageType.text ||
                                              messages.messageType ==
                                                  MessageType.deleted
                                          ? (messages.message!.isNotEmpty
                                              ? messages.message.toString()
                                              : '') // NULL-SAFE
                                          : (messages
                                                  .assetServerName!.isNotEmpty
                                              ? messages.assetServerName
                                                  .toString()
                                              : ''),
                                      date: DateFormat('hh:mm a').format(
                                          DateTime.parse(messages
                                                  .messageSentFromDeviceTime ??
                                              '')),
                                      // date: "",
                                      type: messages.messageType ??
                                          MessageType.text,
                                      status:
                                          messages.state ?? MessageState.unsent,
                                      onLeftSwipe: messages.messageType ==
                                              MessageType.deleted
                                          ? null
                                          : (v) {
                                              groupChatsController
                                                  .onMessageSwipe(
                                                isMe: true,
                                                message: messages.message ?? '',
                                                messageType:
                                                    messages.messageType ??
                                                        MessageType.text,
                                                isReplied: true,
                                                messageId:
                                                    messages.messageId ?? 0,
                                                senderName: "",
                                                recipientUserId: messages.senderId ?? 0
                                              );
                                            },
                                      repliedMessageType:
                                          messages.messageRepliedOnType ??
                                              MessageType.text,
                                      repliedText:
                                          (messages.messageRepliedOn != ''
                                                  ? messages.messageRepliedOn
                                                      .toString()
                                                  : '')
                                              .obs,
                                      // username: messages.,
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
                                      onReplyTap: () => groupChatsController
                                          .scrollToOriginalMessage(
                                              messages.messageRepliedOnId!),
                                      isHighlighted: isHighlighted,
                                      isForwarded: messages.isForwarded!,
                                      showForwarded: messages.showForwarded!,
                                    )
                                  : GroupSenderMessageCard(
                                      message: messages.messageType ==
                                                  MessageType.text ||
                                              messages.messageType ==
                                                  MessageType.deleted
                                          ? (messages.message!.isNotEmpty
                                              ? messages.message.toString()
                                              : '')
                                          : (messages.assetServerName ?? ''),
                                      date: DateFormat('hh:mm a').format(
                                          DateTime.parse(messages
                                                  .messageSentFromDeviceTime ??
                                              '')),
                                      type: messages.messageType ??
                                          MessageType.text,
                                      onRightSwipe: messages.messageType ==
                                              MessageType.deleted
                                          ? null
                                          : (v) {
                                              // groupChatsController.isRepUpdate = true;
                                              groupChatsController
                                                  .onMessageSwipe(
                                                      isMe: false,
                                                      message:
                                                          messages.message ??
                                                              '',
                                                      messageType: messages
                                                              .messageType ??
                                                          MessageType.text,
                                                      isReplied: true,
                                                      messageId:
                                                          messages.messageId ??
                                                              0,
                                                senderName: messageSenderName,
                                                recipientUserId: messages.senderId ?? 0,
                                                  );
                                            },
                                      repliedMessageType:
                                          messages.messageRepliedOnType ??
                                              MessageType.text,
                                      repliedText:
                                          (messages.messageRepliedOn!.isNotEmpty
                                                  ? messages.messageRepliedOn
                                                      .toString()
                                                  : '')
                                              .obs,
                                      // username: messages.repliedTo,
                                      repliedUserId:
                                          messages.messageRepliedUserId,
                                      repliedUserName: messages
                                                      .messageRepliedUserId !=
                                                  0 &&
                                              messages.messageRepliedUserId !=
                                                  null
                                          ? messages.messageRepliedUserId ==
                                                  groupChatsController
                                                      .senderuserData!.userId
                                              ? "You"
                                              : replyMessageSenderName
                                          : "username",
                                      onReplyTap: () => groupChatsController
                                          .scrollToOriginalMessage(
                                              messages.messageRepliedOnId!),
                                      isHighlighted: isHighlighted,
                                      isForwarded: messages.isForwarded!,
                                      showForwarded: messages.showForwarded!,
                                      senderName: messageSenderName,
                                    ),
                            );
                          }),
                        );
                      });
                  // }
                },
              ),
            ),
          );
        }),
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
