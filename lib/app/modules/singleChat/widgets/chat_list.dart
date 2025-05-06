import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:genchatapp/app/config/services/firebase_controller.dart';
import 'package:genchatapp/app/config/theme/app_colors.dart';
import 'package:genchatapp/app/constants/message_enum.dart';
import 'package:genchatapp/app/modules/singleChat/controllers/single_chat_controller.dart';
import 'package:genchatapp/app/modules/singleChat/widgets/typping_bubble.dart';
import 'package:genchatapp/app/utils/utils.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../constants/colors.dart';
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
            return Center(
                child: const Text(
              "No messages yet!",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ));
            // loadingWidget(text: "Fetching data please wait....");
          }
          // SchedulerBinding.instance.addPostFrameCallback((_) {
          //   singleChatController.scrollController.jumpTo(
          //       singleChatController.scrollController.position.maxScrollExtent);
          //   if (singleChatController.scrollController.hasClients) {
          //     singleChatController.scrollController.animateTo(
          //       singleChatController.scrollController.position.maxScrollExtent,
          //       duration: const Duration(seconds: 3),
          //       curve: Curves.easeOut,
          //     );
          //   }
          // })
          // ;
          SchedulerBinding.instance.addPostFrameCallback((_) {
            Future.delayed(Duration(milliseconds: 100), () {
              if (!singleChatController.hasScrolledInitially.value &&
                  singleChatController.scrollController.hasClients) {
                singleChatController.scrollToBottom();
                singleChatController.hasScrolledInitially.value = true;
              }
            });
          });

          final isTyping = singleChatController.isReceiverTyping;
          final messageCount = singleChatController.messageList.length;

          return ListView.builder(
            controller: singleChatController.scrollController,
            itemCount: messageCount + (isTyping ? 1 : 0),
            physics: BouncingScrollPhysics(),
            // singleChatController.isAtBottom.value
            // ? ClampingScrollPhysics():NeverScrollableScrollPhysics(),
            // padding: const EdgeInsets.only(bottom: 80),
            itemBuilder: (context, index) {
              if (isTyping && index == messageCount) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: TypingBubble(), // 👈 your animated dots widget
                );
              }
              var messages = singleChatController.messageList[index];
              final messageId = messages.messageId!;

              GlobalKey? messageKey =
                  singleChatController.messageKeys[messageId.toString()];
              if (messageKey == null) {
                messageKey = GlobalKey();
                singleChatController.messageKeys[messageId.toString()] = messageKey;
              }
              return InkWell(
                onLongPress: () {
                  singleChatController.toggleMessageSelection(messages);
                  print("selected Multiple Taps");
                },
                onTap: () {
                  if (singleChatController.selectedMessages.isNotEmpty) {
                    singleChatController.toggleMessageSelection(messages);
                    print("selected tap");
                  }
                },
                child: Obx(() {
                  bool isMsgSelected =
                      singleChatController.selectedMessages.contains(messages);
                  return Container(
                            key: messageKey,

                    color: isMsgSelected
                        ? AppColors.mySideBgColor.withOpacity(0.3)
                        : Colors.transparent,
                    child: messages.senderId ==
                            singleChatController.senderuserData?.userId
                        ? MyMessageCard(

                            message: messages.messageType == MessageType.text ||
                                    messages.messageType == MessageType.deleted
                                ? (messages.message ?? '') // NULL-SAFE
                                : (messages.assetServerName ?? ''),
                            date: DateFormat('hh:mm a').format(DateTime.parse(
                                messages.messageSentFromDeviceTime ?? '')),
                            // date: "",
                            type: messages.messageType ?? MessageType.text,
                            status: messages.state ?? MessageState.unsent,
                            onLeftSwipe:
                                messages.messageType == MessageType.deleted
                                    ? null
                                    : (v) {
                                        // singleChatController.isRepUpdate = true;

                                        singleChatController.onMessageSwipe(
                                          isMe: true,
                                          message: messages.message ?? '',
                                          messageType: messages.messageType ??
                                              MessageType.text,
                                          isReplied: true,
                                          messageId: messages.messageId ?? 0,
                                        );
                                      },
                            repliedMessageType: messages.messageRepliedOnType ??
                                MessageType.text,
                            repliedText: (messages.messageRepliedOn ?? '').obs,
                            // username: messages.,
                            repliedUserId: messages.messageRepliedUserId,
                            repliedUserName: messages.messageRepliedUserId != 0
                                ? messages.messageRepliedUserId ==
                                        singleChatController
                                            .senderuserData!.userId
                                    ? "You"
                                    : singleChatController
                                        .receiverUserData!.name
                                : "username",
                            onReplyTap: () =>
                                singleChatController.scrollToOriginal(
                                    messages.messageRepliedOnId.toString()),
                          )
                        : SenderMessageCard(

                            message: messages.messageType == MessageType.text ||
                                    messages.messageType == MessageType.deleted
                                ? (messages.message ?? '')
                                : (messages.assetServerName ?? ''),
                            date: DateFormat('hh:mm a').format(DateTime.parse(
                                messages.messageSentFromDeviceTime ?? '')),
                            type: messages.messageType ?? MessageType.text,
                            onRightSwipe:
                                messages.messageType == MessageType.deleted
                                    ? null
                                    : (v) {
                                        // singleChatController.isRepUpdate = true;
                                        singleChatController.onMessageSwipe(
                                            isMe: false,
                                            message: messages.message ?? '',
                                            messageType: messages.messageType ??
                                                MessageType.text,
                                            isReplied: true,
                                            messageId: messages.messageId ?? 0);
                                      },
                            repliedMessageType: messages.messageRepliedOnType ??
                                MessageType.text,
                            repliedText: (messages.messageRepliedOn ?? '').obs,
                            // username: messages.repliedTo,
                            repliedUserId: messages.messageRepliedUserId,
                            repliedUserName: messages.messageRepliedUserId != 0 && messages.messageRepliedUserId  != null
                                ? messages.messageRepliedUserId == singleChatController.senderuserData!.userId
                                    ? "You"
                                    : singleChatController
                                        .receiverUserData!.localName
                                : "username",
                          ),
                  );
                }),
              );
              // }
            },
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
