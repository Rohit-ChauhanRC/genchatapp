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





class ChatList extends StatelessWidget {
  const ChatList({
    super.key,
    required this.singleChatController,
    // required this.firebaseController,
  });

  final SingleChatController singleChatController;
  // final FirebaseController firebaseController;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Obx(() {
          // if (singleChatController.isLoading) {
          //   return loadingWidget(text: "Fetching data please wait....");
          // }
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
                await singleChatController.loadMoreMessages();
              },
              edgeOffset: 0,
              displacement: 40,
              child: ScrollablePositionedList.builder(
                itemScrollController: singleChatController.itemScrollController,
                itemPositionsListener:
                    singleChatController.itemPositionsListener,
                itemCount: messageCount + (isTyping ? 1 : 0),
                // physics: const ClampingScrollPhysics(),
                physics: const BouncingScrollPhysics(
                  decelerationRate: ScrollDecelerationRate.normal,
                ),
                  itemBuilder: (context, index) {
                    // Files now show directly in messageList, no separate pending uploads
                    if (isTyping && index == messageCount) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: TypingBubble(),
                      );
                    }

                    var messages = singleChatController.messageList[index];
                    final id = (messages.messageId ?? messages.clientSystemMessageId).toString();
                    singleChatController.messageIdToIndex[id] = index;

                    return ValueListenableBuilder<String?>(
                      valueListenable: singleChatController.highlightedMessageId,
                      builder: (context, highlightId, _) {
                        final isHighlighted = highlightId == messages.messageId.toString();
                        bool isMsgSelected =
                        singleChatController.selectedMessages.contains(messages);
                        final bgColor = isMsgSelected || isHighlighted
                            ? AppColors.mySideBgColor.withOpacity(0.3)
                            : Colors.transparent;

                        return Container(
                          color: bgColor,
                          child: messages.senderId ==
                              singleChatController.senderuserData?.userId
                              ?
                          MyMessageCard(
                            percent: singleChatController.percent,
                            isProgess: singleChatController.percent,
                            audioMessage: messages.message ?? "",
                            message:
                            messages.messageType ==
                                MessageType.text ||
                                messages.messageType ==
                                    MessageType.deleted
                                ? (messages.message!.isNotEmpty
                                ? messages.message.toString()
                                : '') // NULL-SAFE
                                : (messages
                                .assetServerName!
                                .isNotEmpty
                                ? messages.assetServerName
                                .toString()
                                : ''),
                            date: DateFormat('hh:mm a').format(
                              DateTime.parse(
                                messages.messageSentFromDeviceTime ??
                                    '',
                              ),
                            ),
                            // date: "",
                            type:
                            messages.messageType ??
                                MessageType.text,
                            status:
                            messages.state ??
                                MessageState.unsent,
                            syncStatus:
                            messages.syncStatus ??
                                SyncStatus.pending,
                            onLeftSwipe:
                            messages.messageType ==
                                MessageType.deleted
                                ? null
                                : (v) {
                              singleChatController
                                  .onMessageSwipe(
                                isMe: true,
                                message:
                                messages.messageType !=
                                    MessageType.text
                                    ? messages
                                    .assetServerName
                                    .toString()
                                    : messages.message
                                    .toString(),
                                messageType:
                                messages
                                    .messageType ??
                                    MessageType.text,
                                isReplied: true,
                                messageId:
                                messages.messageId ??
                                    0,
                                assetsThumbnail:
                                messages
                                    .assetThumbnail ??
                                    "",
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
                                singleChatController
                                    .senderuserData!
                                    .userId
                                ? "You"
                                : singleChatController
                                .receiverUserData!
                                .localName
                                : "username",
                            repliedAssetServerName: messages
                                .messageRepliedOnAssetServerName,
                            repliedThumbnail: messages
                                .messageRepliedOnAssetThumbnail,
                            onReplyTap: () => singleChatController
                                .scrollToOriginalMessage(
                              messages.messageRepliedOnId!,
                            ),
                            isHighlighted: isHighlighted,
                            isForwarded: messages.isForwarded!,
                            showForwarded: messages.showForwarded!,
                            isAsset: messages.isAsset!,
                            onRetryTap: () async {
                              await singleChatController
                                  .retryPendingMediaFile(messages);
                            },
                            url: messages.assetUrl,
                            isRetryUploadFile:
                            messages.isRetrying ?? false.obs,
                            assetThumbnail: messages.assetThumbnail,
                            isUploading: messages.isUploading,
                            uploadProgress: messages.uploadProgress,
                          )
                              :
                          SenderMessageCard(
                            message:
                            messages.messageType ==
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
                            type:
                            messages.messageType ??
                                MessageType.text,
                            onRightSwipe:
                            messages.messageType ==
                                MessageType.deleted
                                ? null
                                : (v) {
                              // singleChatController.isRepUpdate = true;
                              singleChatController.onMessageSwipe(
                                isMe: false,
                                message:
                                messages.messageType !=
                                    MessageType.text
                                    ? messages.assetServerName
                                    .toString()
                                    : messages.message.toString(),
                                messageType:
                                messages.messageType ??
                                    MessageType.text,
                                isReplied: true,
                                messageId:
                                messages.messageId ?? 0,
                                assetsThumbnail:
                                messages.assetThumbnail ?? "",
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
                            repliedUserName:
                            messages.messageRepliedUserId != 0 &&
                                messages.messageRepliedUserId !=
                                    null
                                ? messages.messageRepliedUserId ==
                                singleChatController
                                    .senderuserData!
                                    .userId
                                ? "You"
                                : singleChatController
                                .receiverUserData!
                                .localName
                                : "username",
                            repliedAssetServerName: messages
                                .messageRepliedOnAssetServerName,
                            repliedThumbnail:
                            messages.messageRepliedOnAssetThumbnail,
                            onReplyTap: () => singleChatController
                                .scrollToOriginalMessage(
                              messages.messageRepliedOnId!,
                            ),
                            isHighlighted: isHighlighted,
                            isForwarded: messages.isForwarded!,
                            showForwarded: messages.showForwarded!,
                            url: messages.assetUrl,
                            assetThumbnail: messages.assetThumbnail,
                          ),
                        );
                      },
                    );
                  },

              ),
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
