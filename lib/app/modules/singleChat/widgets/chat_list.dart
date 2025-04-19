import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:genchatapp/app/config/services/firebase_controller.dart';
import 'package:genchatapp/app/constants/message_enum.dart';
import 'package:genchatapp/app/modules/singleChat/controllers/single_chat_controller.dart';
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
    return Obx(() {
      // if (singleChatController.isLoading) {
      //   return loadingWidget(text: "Fetching data please wait....");
      // }
      if (singleChatController.messageList.isEmpty) {
        return loadingWidget(text: "Fetching data please wait....");
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
        if (!singleChatController.hasScrolledInitially.value &&
            singleChatController.scrollController.hasClients) {
          singleChatController.scrollController.animateTo(
            singleChatController.scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
          singleChatController.hasScrolledInitially.value = true;
        }
      });

      return ListView.builder(
        controller: singleChatController.scrollController,
        itemCount: singleChatController.messageList.length,
        itemBuilder: (context, index) {
          var messages = singleChatController.messageList[index];
          // if (messages.receiverId ==
          //         singleChatController.receiveruserDataModel.value.uid) {
          //   // singleChatController.setChatMessageSeen(
          //   //   context,
          //   //   messages.messageId,
          //   // );
          // }
          //   singleChatController.isMsgSelected = singleChatController.selectedMessages.contains(messages);
          // if (messages.senderId == singleChatController.senderuserData.uid) {
          return InkWell(
            onLongPress: () {
              // singleChatController.toggleMessageSelection(messages);
              // print("selected Multiple Taps");
            },
            onTap: () {
              // if (singleChatController.selectedMessages.isNotEmpty) {
              //   singleChatController.toggleMessageSelection(messages);
              //   print("selected tap");
              // }
            },
            child: Obx(() {
              bool isMsgSelected =
                  singleChatController.selectedMessages.contains(messages);
              return Container(
                color: isMsgSelected
                    ? mySideBgColor.withOpacity(0.3)
                    : Colors.transparent,
                child: messages.senderId ==
                        singleChatController.senderuserData!.userId
                    ? MyMessageCard(
                        message: messages.message!,
                        date: DateFormat('hh:mm a').format(DateTime.parse(
                            messages.messageSentFromDeviceTime!)),
                        // date: "",
                        type: MessageEnum.text,
                        status: messages.state!,
                        onLeftSwipe: (v) {
                          // singleChatController.isRepUpdate = true;

                          singleChatController.onMessageSwipe(
                            isMe: true,
                            message: messages.message!,
                            messageEnum: MessageEnum.text,
                          );
                        },
                        // repliedMessageType: messages.repliedMessageType.type.toEnum(),
                        // repliedText: messages.repliedMessage.obs,
                        // username: messages.repliedTo,
                      )
                    :
                    // }
                    SenderMessageCard(
                        message: messages.message.toString(),
                        date: DateFormat('hh:mm a').format(DateTime.parse(
                            messages.messageSentFromDeviceTime!)),
                        type: MessageEnum.text,
                        onRightSwipe: (v) {
                          // singleChatController.isRepUpdate = true;
                          // singleChatController.onMessageSwipe(
                          //   isMe: false,
                          //   message: messages.message!,
                          //   messageEnum: MessageEnum.text,
                          // );
                        },
                        // repliedMessageType: messages.repliedMessageType.type.toEnum(),
                        // repliedText: messages.repliedMessage.obs,
                        // username: messages.repliedTo,
                      ),
              );
            }),
          );
        },
      );
    });
  }
}
