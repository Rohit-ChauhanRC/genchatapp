import 'package:flutter/material.dart';
import 'package:genchatapp/app/constants/message_enum.dart';
import 'package:genchatapp/app/data/models/new_models/response_model/new_message_model.dart';

typedef StringCallback = void Function(String);
typedef StringMessageCallBack = void Function(
    String message, NewMessageModel replyMessage, MessageType messageType);
typedef ReplyMessageWithReturnWidget = Widget Function(
    NewMessageModel? replyMessage);
typedef ReplyMessageCallBack = void Function(NewMessageModel replyMessage);
typedef VoidCallBack = void Function();
typedef DoubleCallBack = void Function(double, double);
typedef MessageCallBack = void Function(NewMessageModel message);
typedef VoidCallBackWithFuture = Future<void> Function();
typedef StringsCallBack = void Function(String emoji, String messageId);
typedef StringWithReturnWidget = Widget Function(String separator);
typedef DragUpdateDetailsCallback = void Function(DragUpdateDetails);
