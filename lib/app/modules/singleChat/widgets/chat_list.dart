import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:genchatapp/app/config/services/firebase_controller.dart';
import 'package:genchatapp/app/constants/message_enum.dart';
import 'package:genchatapp/app/modules/singleChat/controllers/single_chat_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'my_message_card.dart';
import 'sender_message_card.dart';

class ChatList extends StatelessWidget {
  const ChatList({
    super.key,
    required this.singleChatController,
    required this.firebaseController,
  });

  final SingleChatController singleChatController;
  final FirebaseController firebaseController;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (singleChatController.messageList.isEmpty) {
        return const SizedBox();
      }
      SchedulerBinding.instance.addPostFrameCallback((_) {
        // singleChatController.scrollController.jumpTo(
        //     singleChatController.scrollController.position.maxScrollExtent);
        if (singleChatController.scrollController.hasClients) {
          singleChatController.scrollController.animateTo(
            singleChatController.scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
      return ListView.builder(
        controller: singleChatController.scrollController,
        itemCount: singleChatController.messageList.length,
        itemBuilder: (context, index) {
          var messages = singleChatController.messageList[index];
          if (messages.receiverId ==
                  singleChatController.receiveruserDataModel.value.uid) {
            // singleChatController.setChatMessageSeen(
            //   context,
            //   messages.messageId,
            // );
          }
          if (messages.senderId == singleChatController.senderuserData.uid) {
            return MyMessageCard(
              message: messages.text.toString(),
              date: DateFormat.Hm().format(messages.timeSent).toString(),
              // date: "",
              type: messages.type.type.toString().toEnum(),
                status: messages.status.type.toString().toStatusEnum(),
              onLeftSwipe: (v) {
                // singleChatController.isRepUpdate = true;

                // singleChatController.onMessageSwipe(
                //   isMe: true,
                //   message: messages.text.toString(),
                //   messageEnum: messages.type,
                // );
              },
              repliedMessageType: messages.repliedMessageType.type.toEnum(),
              repliedText: messages.repliedMessage.obs,
              username: messages.repliedTo,
            );
          }
          return SenderMessageCard(
            message: messages.text.toString(),
            date: DateFormat.Hm().format(messages.timeSent).toString(),
            type: messages.type.type.toString().toEnum(),
            onRightSwipe: (v) {
              singleChatController.isRepUpdate = true;
              // singleChatController.onMessageSwipe(
              //   isMe: false,
              //   message: messages.text.toString(),
              //   messageEnum: messages.type,
              // );
            },
            repliedMessageType: messages.repliedMessageType.type.toEnum(),
            repliedText: messages.repliedMessage.obs,
            username: messages.repliedTo,
          );
        },
      );
    });
  }
}
