import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:genchatapp/app/config/services/folder_creation.dart';
import 'package:genchatapp/app/config/services/notification_service.dart';
import 'package:genchatapp/app/constants/constants.dart';
import 'package:genchatapp/app/constants/message_enum.dart';
import 'package:genchatapp/app/data/local_database/chatconnect_table.dart';
import 'package:genchatapp/app/data/local_database/groups_table.dart';
import 'package:genchatapp/app/data/local_database/local_database.dart';
import 'package:genchatapp/app/data/local_database/message_table.dart';
import 'package:genchatapp/app/data/local_database/status_table.dart';
import 'package:genchatapp/app/data/models/chat_conntact_model.dart';
import 'package:genchatapp/app/data/models/new_models/response_model/block_user_model.dart';
import 'package:genchatapp/app/data/models/new_models/response_model/new_message_model.dart';
import 'package:genchatapp/app/data/models/new_models/response_model/verify_otp_response_model.dart';
import 'package:genchatapp/app/modules/group_chats/controllers/group_chats_controller.dart';
import 'package:genchatapp/app/network/api_endpoints.dart';
import 'package:genchatapp/app/routes/app_pages.dart';
import 'package:genchatapp/app/services/shared_preference_service.dart';
import 'package:genchatapp/app/utils/alert_popup_utils.dart';
import 'package:genchatapp/app/utils/utils.dart';
import 'package:get/get.dart' hide Response;
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../common/user_defaults/user_defaults_keys.dart';
import '../../data/local_database/contacts_table.dart';
import '../../data/models/new_models/response_model/create_group_model.dart';
import '../../data/models/new_models/response_model/message_ack_model.dart';

class SocketService extends GetxService {
  IO.Socket? _socket;
  IO.Socket? get socket => _socket;

  final ContactsTable contactsTable = ContactsTable();

  final ChatConectTable chatConectTable = ChatConectTable();
  final GroupsTable groupsTable = GroupsTable();

  final MessageTable messageTable = MessageTable();
  final FolderCreation folderCreation = FolderCreation();
  final sharedPreferenceService = Get.find<SharedPreferenceService>();

  bool get isConnected => _socket?.connected == true;

  final List<VoidCallback> _onSocketConnectedQueue = [];

  final RxMap<String, bool> typingStatusMap = <String, bool>{}.obs;
  final RxMap<String, Map<String, String>> typingGroupUsersMap =
      <String, Map<String, String>>{}.obs;
  final Rx<NewMessageModel?> incomingMessage = Rx<NewMessageModel?>(null);
  // final Rx<BlockUserModel?> blockUserModel = Rx<BlockUserModel?>(null);

  final Rxn<DeletedMessageModel> deletedMessage = Rxn<DeletedMessageModel>();
  // ReadOnlyAdmin
  final Rxn<ReadOnlyAdmin> groupRedOnly = Rxn<ReadOnlyAdmin>();
  // VanishModeAutoDelete
  final Rxn<VanishModeAutoDelete> vanishModeAutoDelete =
      Rxn<VanishModeAutoDelete>();

  final Rxn<MessageAckModel> messageAcknowledgement = Rxn<MessageAckModel>();
  final Rxn<UserData> updateContactUser = Rxn<UserData>();
  final Rxn<bool> updateGroupAdmins = Rxn<bool>();

  final Rx<BlockUserModel?> incomBlockUser = Rx<BlockUserModel?>(null);

  final DataBaseService db = Get.find();
  final SharedPreferenceService sharedPreference = Get.find();

  final StatusTable statusTable = StatusTable();
  // final GroupChatsController groupChatsController = Get.find();

  Future<void> initSocket(String userId, {Function()? onConnected}) async {
    if (_socket != null) {
      if (_socket!.connected) {
        print('⚠️ Socket already connected, skipping init.');
        return;
      } else {
        // Socket is present but disconnected — dispose and reconnect
        print('🔄 Disposing stale socket and reinitializing...');
        await disposeSocket();
      }
    }
    _socket = IO.io(
      ApiEndpoints.socketBaseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect() // prevent auto connect before setting everything
          .enableForceNew()
          .setQuery({'userId': userId})
          .setAuth({
            "token":
                "${sharedPreferenceService.getString(UserDefaultsKeys.accessToken)}",
          })
          .build(),
    );
    _registerSocketListeners(onConnected, userId);
    _socket?.connect();
    print('🔌 Socket initialized');
    print("Socket base url : ${ApiEndpoints.socketBaseUrl}");
    print(
      "sharedPreferenceService.getString(UserDefaultsKeys.accessToken): ${sharedPreferenceService.getString(UserDefaultsKeys.accessToken)}",
    );
  }

  void _registerSocketListeners(Function()? onConnected, String userId) {
    _socket?.onConnect((_) async {
      print('✅ Socket connected');
      // _isConnected.value = true;
      await retryPendingDeletions();
      await syncPendingMessages(loginUserId: int.parse(userId));
      // ✅ Run queued actions
      for (final action in _onSocketConnectedQueue) {
        action();
      }
      _onSocketConnectedQueue.clear();
      onConnected?.call();
    });

    _socket?.onDisconnect((_) {
      print('❌ Socket disconnected');
      // _isConnected.value = false;
      _clearSocketListeners();
    });

    _socket?.onError((data) {
      print('⚠️ Socket error: $data');
      _clearSocketListeners();
    });

    _socket?.onReconnect((_) {
      print('Socket reconnection.');
      _clearSocketListeners();
      _registerSocketListeners(onConnected, userId);
    });

    // Add your custom events here
    _socket?.on('message-event', (data) async {
      print('📩 Message received: $data');
      int messageId = data["messageId"];
      bool existsLocally = await messageTable.messageExists(messageId);
      //

      if (!existsLocally) {
        print("message not found");
        final newMessage = NewMessageModel(
          message: data["message"],
          senderId: data["senderId"],
          messageId: data["messageId"],
          recipientId: data["recipientId"],
          messageSentFromDeviceTime: data["messageSentFromDeviceTime"],
          messageType: data['messageType'] != null
              ? MessageTypeExtension.fromValue(data['messageType'])
              : MessageType.text,
          // default if null
          state: MessageState.sent,
          senderPhoneNumber: data["senderPhoneNumber"],
          receiverPhoneNumber: data["receiverPhoneNumber"],
          isGroupMessage: data["isGroupMessage"] ?? false,
          isRepliedMessage: data["isRepliedMessage"] ?? false,
          messageRepliedOnId: data["messageRepliedOnId"],
          messageRepliedOn: data["messageRepliedOn"] ?? '',
          messageRepliedOnType: data["messageRepliedOnType"] != null
              ? MessageTypeExtension.fromValue(data["messageRepliedOnType"])
              : null,
          messageRepliedOnAssetThumbnail:
              data["messageRepliedOnAssetThumbnail"] ?? '',
          messageRepliedOnAssetServerName:
              data["messageRepliedOnAssetServerName"] ?? '',
          isAsset: data["isAsset"] ?? false,
          assetThumbnail: data["assetThumbnail"] ?? "",
          assetOriginalName: data["assetOriginalName"] ?? '',
          assetServerName: data["assetServerName"] ?? '',
          assetUrl: data["assetUrl"] ?? '',
          isForwarded: data["isForwarded"] ?? false,
          showForwarded: data["showForwarded"] ?? false,
          forwardedMessageId: data['forwardedMessageId'] ?? 0,
          messageRepliedUserId: data["messageRepliedUserId"] ?? 0,
        );
        final groupId = newMessage.recipientId;
        final receiveMessageTime = newMessage.messageSentFromDeviceTime;

        final msgDate = DateTime.tryParse(
          newMessage.messageSentFromDeviceTime ?? "",
        );

        final messageTimer = sharedPreferenceService.getInt(
          UserDefaultsKeys.messageDurationKey,
        );
        final bool isGroup = newMessage.isGroupMessage!;

        if (isGroup) {
          final group = await groupsTable.getGroupById(groupId!);
          final userList = group!.users;
          //  final user = userList!.map((e) => e.userInfo!.userId == newMessage.senderId);
          final sender = userList!.firstWhere(
            (u) => u.userInfo?.userId == newMessage.senderId,
          );

          final String sentTime = data["messageSentFromDeviceTime"].toString();

          if (sender.userGroupInfo!.autoDeleteMessages == true &&
              messageTimer != null &&
              messageTimer > 0 &&
              isMessageExpired(sentTime, messageTimer)) {
            print("⏱ Message expired before save. Skipping DB insert.");
            return;
          } else {
            messageTable.insertMessage(newMessage);
            incomingMessage.value = newMessage;

            final chatContactMessage = NewMessageModel(
              message: data["message"],
              senderId: data["recipientId"],
              messageId: data["messageId"],
              recipientId: data["isGroupMessage"] == true
                  ? data["recipientId"]
                  : data["senderId"],
              messageSentFromDeviceTime: data["messageSentFromDeviceTime"],
              isGroupMessage: data["isGroupMessage"],
              messageType: data['messageType'] != null
                  ? MessageTypeExtension.fromValue(data['messageType'])
                  : MessageType.text,
              state: MessageState.sent,
              senderPhoneNumber: data["senderPhoneNumber"],
            );

            saveChatContacts(chatContactMessage);
          }
        } else {
          messageTable.insertMessage(newMessage);
          incomingMessage.value = newMessage;

          final chatContactMessage = NewMessageModel(
            message: data["message"],
            senderId: data["recipientId"],
            messageId: data["messageId"],
            recipientId: data["isGroupMessage"] == true
                ? data["recipientId"]
                : data["senderId"],
            messageSentFromDeviceTime: data["messageSentFromDeviceTime"],
            isGroupMessage: data["isGroupMessage"],
            messageType: data['messageType'] != null
                ? MessageTypeExtension.fromValue(data['messageType'])
                : MessageType.text,
            state: MessageState.sent,
            senderPhoneNumber: data["senderPhoneNumber"],
          );

          saveChatContacts(chatContactMessage);
        }
      } else {
        print("⚠️ Message $messageId found in locally, Skipping reinserting.");
      }
    });

    // _socket?.on('message-event', (data) async {
    //   print('📩 Message received: $data');

    //   final int messageId = data["messageId"];
    //   final bool existsLocally = await messageTable.messageExists(messageId);

    //   if (existsLocally) {
    //     print("⚠️ Message $messageId already exists. Skipping.");
    //     return;
    //   }

    //   final int? messageTimer = sharedPreferenceService.getInt(
    //     UserDefaultsKeys.messageDurationKey,
    //   ); // minutes

    //   final String? sentTime = data["messageSentFromDeviceTime"];

    //   final bool?  isGroup = data["isGroupMessage"];

    //   // ⛔ Skip saving if expired
    //   if (isGroup! && messageTimer != null &&
    //       messageTimer > 0 &&
    //       isMessageExpired(sentTime, messageTimer) ) {
    //     print("⏱ Message expired before save. Skipping DB insert.");
    //     return;
    //   }

    //   final newMessage = NewMessageModel(
    //     message: data["message"],
    //     senderId: data["senderId"],
    //     messageId: messageId,
    //     recipientId: data["recipientId"],
    //     messageSentFromDeviceTime: sentTime,
    //     messageType: data['messageType'] != null
    //         ? MessageTypeExtension.fromValue(data['messageType'])
    //         : MessageType.text,
    //     state: MessageState.sent,
    //     senderPhoneNumber: data["senderPhoneNumber"],
    //     receiverPhoneNumber: data["receiverPhoneNumber"],
    //     isGroupMessage: data["isGroupMessage"] ?? false,
    //     isRepliedMessage: data["isRepliedMessage"] ?? false,
    //     messageRepliedOnId: data["messageRepliedOnId"],
    //     messageRepliedOn: data["messageRepliedOn"] ?? '',
    //     messageRepliedOnType: data["messageRepliedOnType"] != null
    //         ? MessageTypeExtension.fromValue(data["messageRepliedOnType"])
    //         : null,
    //     messageRepliedOnAssetThumbnail:
    //         data["messageRepliedOnAssetThumbnail"] ?? '',
    //     messageRepliedOnAssetServerName:
    //         data["messageRepliedOnAssetServerName"] ?? '',
    //     isAsset: data["isAsset"] ?? false,
    //     assetThumbnail: data["assetThumbnail"] ?? "",
    //     assetOriginalName: data["assetOriginalName"] ?? '',
    //     assetServerName: data["assetServerName"] ?? '',
    //     assetUrl: data["assetUrl"] ?? '',
    //     isForwarded: data["isForwarded"] ?? false,
    //     showForwarded: data["showForwarded"] ?? false,
    //     forwardedMessageId: data['forwardedMessageId'] ?? 0,
    //     messageRepliedUserId: data["messageRepliedUserId"] ?? 0,
    //   );

    //   // ✅ Save message
    //   await messageTable.insertMessage(newMessage);
    //   incomingMessage.value = newMessage;

    //   // ⏳ Schedule auto-delete if timer exists
    //   if (messageTimer != null && messageTimer > 0) {
    //     scheduleMessageDeletion(
    //       messageId: messageId,
    //       sentTime: sentTime,
    //       timerMinutes: messageTimer,
    //     );
    //   }
    // });

    _socket?.on('message-acknowledgement', (data) async {
      print('✅ Message Ack: $data');
      if (data["state"] == 1) {
        messageTable.updateAckMessage(
          clientSystemMessageId: data["clientSystemMessageId"].toString(),
          state: data["state"],
          messageId: data["messageId"],
          syncStatus: SyncStatus.synced,
        );
      } else if (data["state"] == 2 || data["state"] == 3) {
        messageTable.updateAckStateMessage(
          messageId: data["messageId"].toString(),
          state: data["state"],
        );
      }

      messageAcknowledgement.value = MessageAckModel(
        clientSystemMessageId: data["clientSystemMessageId"].toString(),
        state: data["state"],
        messageId: data["messageId"],
      );
      //
    });

    _socket?.on('user-connection-status', (data) async {
      print('✅ user connection status: $data');
      final int userId = int.parse(data['userId']);
      final bool isOnlineBool = data['isOnline'];
      final int isOnline = isOnlineBool ? 1 : 0;

      String? lastSeenTime;

      // Update only when user goes offline
      if (!isOnlineBool) {
        lastSeenTime = data['lastSeen'];
      }

      bool success = await contactsTable.updateUserOnlineStatus(
        userId,
        isOnline,
        lastSeenTime ?? '', // Pass empty string if user is online
      );

      print(
        success
            ? "✅ User status updated successfully: UserID: $userId Is Online: $isOnline Last Seen Time: $lastSeenTime"
            : "⚠️ No user found with that ID to update: UserID: $userId Is Online: $isOnline Last Seen Time: $lastSeenTime",
      );
    });

    _socket?.on('typing', (data) {
      print('✅ user is typing: $data');
      print('📝 Typing event received: $data');

      final String senderId = data["userId"].toString();
      final bool isTyping = data["isTyping"] == true;

      // 👇 Save typing state in map for the current chat
      if (senderId != userId) {
        typingStatusMap[senderId] = isTyping;
      }
    });

    _socket?.on('group-user-typing', (data) async {
      print('✅ Group user is typing: $data');
      print('📝 Group user Typing event received: $data');
      final String senderId = data["userId"].toString();
      final String groupId = data["groupId"].toString();
      final bool isTyping = data["isTyping"] == true;

      // 👇 Save typing state in map for the current chat
      if (senderId != userId) {
        await updateGroupTypingFromEvent(
          groupId: groupId,
          userId: senderId,
          isTyping: isTyping,
        );
      }
    });

    _socket?.on('message-delete', (data) async {
      print('✅ Message Deleted: $data');
      final int messageId = data['messageId'];
      final bool isDeleteFromEveryOne = data['deleteState'];

      bool existsLocally = await messageTable.messageExists(messageId);
      if (existsLocally) {
        final msg = await messageTable.getMessageById(messageId);
        final isLast = await messageTable.isLastMessage(
          messageId: messageId,
          senderId: msg?.senderId ?? 0,
          receiverId: msg?.recipientId ?? 0,
        );
        final isGroupMessage = msg?.isGroupMessage;

        if (isDeleteFromEveryOne) {
          await messageTable.updateMessageContent(
            messageId: messageId,
            newText: "This message was deleted",
            newType: MessageType.deleted,
          );
        } else {
          await messageTable.deleteMessage(messageId);
        }

        // 🔔 Notify controller
        deletedMessage.value = DeletedMessageModel(
          messageId: messageId,
          isDeleteFromEveryone: isDeleteFromEveryOne,
        );

        // Optional: update chat contact if last message
        if (isLast) {
          if (isDeleteFromEveryOne) {
            await chatConectTable.updateContact(
              uid: isGroupMessage == true
                  ? msg!.recipientId.toString()
                  : msg!.senderId.toString(),
              isGroup: isGroupMessage == true ? 1 : 0,
              lastMessageId: 0,
              lastMessage: "This message was deleted",
              timeSent: msg.messageSentFromDeviceTime,
            );
          } else {
            final newLast = await messageTable.getLatestMessageForUser(
              msg?.recipientId ?? 0,
              msg?.senderId ?? 0,
            );
            final isGroupNewLast = newLast?.isGroupMessage;
            if (newLast != null) {
              await chatConectTable.updateContact(
                lastMessageId: newLast.messageId,
                uid: msg!.recipientId.toString(),
                isGroup: 0,
                lastMessage: newLast.message,
                timeSent: newLast.clientSystemMessageId,
              );
            } else {
              await chatConectTable.updateContact(
                lastMessageId: 0,
                uid: msg!.recipientId.toString(),
                isGroup: 0,
                lastMessage: '',
                timeSent: '',
              );
            }
          }
        }
      } else {
        print("⚠️ Message ID $messageId not found locally. Skipping deletion.");
      }
    });

    _socket?.on('user-update', (data) async {
      print('✅ User Details Update: $data');
      UserData userDetails = UserData.fromJson(data["userData"]);
      updateContactUser.value = userDetails;
      // print("userData after json to model: $userDetails");
      await chatConectTable.updateContact(
        uid: userDetails.userId.toString(),
        isGroup: 0,
        profilePic: userDetails.displayPictureUrl,
      );
      await contactsTable.updateUserFields(
        userId: userDetails.userId ?? 0,
        name: userDetails.name,
        phoneNumber: userDetails.phoneNumber,
        email: userDetails.email,
        userDescription: userDetails.userDescription,
        displayPicture: userDetails.displayPicture,
        displayPictureUrl: userDetails.displayPictureUrl,
      );
    });

    _socket?.on('group-updated', (data) async {
      print('✅ Group Details Updated: $data');
      final responseModel = CreateGroupModel.fromJson(data);
      // print("after Parsing: ${responseModel.toJson()}");
      if (responseModel.status == true && responseModel.data != null) {
        await groupsTable.insertOrUpdateGroup(responseModel.data!);
        final data = responseModel.data;
        final groupId = data?.group?.id ?? 0;
        await chatConectTable.updateContact(
          uid: groupId.toString(),
          isGroup: 1,
          profilePic: data?.group?.displayPictureUrl ?? '',
          timeSent: data?.group?.updatedAt ?? "",
          name: data?.group?.name ?? '',
        );
      }
      updateGroupAdmins.value = false;
      updateGroupAdmins.value = true;
    });

    _socket?.on('group-created', (data) async {
      print('✅ New Group created: $data');
      final responseModel = CreateGroupModel.fromJson(data);
      // print("after Parsing: ${responseModel.toJson()}");
      if (responseModel.status == true && responseModel.data != null) {
        await groupsTable.insertOrUpdateGroup(responseModel.data!);
        final data = responseModel.data;
        final groupId = data?.group?.id ?? 0;
        await chatConectTable.insert(
          contact: ChatConntactModel(
            uid: groupId.toString(),
            isGroup: 1,
            profilePic: data?.group?.displayPictureUrl ?? '',
            timeSent: data?.group?.updatedAt ?? "",
            name: data?.group?.name ?? '',
            contactId: groupId.toString(),
            lastMessage: "",
            lastMessageId: 0,
            unreadCount: 0,
          ),
        );
      }
    });

    _socket?.on('group-user-added', (data) async {
      print('✅ New User added in group: $data');
      final groupMap = data["group"];
      final usersData = data["users"];

      Group group = Group.fromJson(groupMap);
      List<User> usersList = [];
      if (usersData is List) {
        usersList = usersData
            .map((e) => User.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      } else if (usersData is Map) {
        usersList = [User.fromJson(Map<String, dynamic>.from(usersData))];
      }

      final isGroupExists = await groupsTable.isGroupExists(group.id!);

      if (!isGroupExists) {
        print("group not found:----> Going to inserted");
        final responseModel = CreateGroupModel(
          status: true,
          message: "",
          statusCode: 200,
          data: GroupData(group: group, users: usersList),
        );
        await groupsTable.insertOrUpdateGroup(responseModel.data!);
        final data = responseModel.data;
        print("New group inserted:---> $data");
        final groupId = data?.group?.id ?? 0;
        await chatConectTable.insert(
          contact: ChatConntactModel(
            uid: groupId.toString(),
            isGroup: 1,
            profilePic: data?.group?.displayPictureUrl ?? '',
            timeSent: data?.group?.updatedAt ?? "",
            name: data?.group?.name ?? '',
            contactId: groupId.toString(),
            lastMessage: "",
            lastMessageId: 0,
            unreadCount: 0,
          ),
        );
        print("Group inserted Sucessfully: $groupId");
      } else {
        // Handle both list & single map

        print('Adding users in group:----> $usersList');

        for (var user in usersList) {
          final userInfo = user.userInfo!;
          final userGroup = user.userGroupInfo!;
          // Save new user info if needed
          await groupsTable.updateUserIfNeeded(userInfo);

          // Add user to group mapping
          await groupsTable.updateUserGroupRole(
            groupId: userGroup.groupId ?? 0,
            userId: userGroup.userId ?? 0,
            isAdmin: userGroup.isAdmin ?? false,
            isRemoved: userGroup.isRemoved ?? false,
            updaterId: userGroup.updaterId ?? 0,
            createdAt: userGroup.createdAt ?? "",
            updatedAt: userGroup.updatedAt ?? "",
          );
        }
        // Refresh UI or any state observers
        updateGroupAdmins.value = false;
        updateGroupAdmins.value = true;
      }
    });

    _socket?.on('group-user-removed', (data) async {
      print('✅ User removed in group: $data');

      final groupMap = data["group"];
      final userMap = data["users"];

      Group group = Group.fromJson(groupMap);
      User user = User.fromJson(userMap);

      if (group != null && user != null) {
        // Update user's profile if needed
        await groupsTable.updateUserIfNeeded(user.userInfo!);

        // Mark user as removed in group
        await groupsTable.updateUserRemovedStatus(
          groupId: user.userGroupInfo?.groupId ?? 0,
          userId: user.userGroupInfo?.userId ?? 0,
          isRemoved: user.userGroupInfo?.isRemoved ?? true,
          updaterId: user.userGroupInfo?.updaterId ?? 0,
          updatedAt: user.userGroupInfo?.updatedAt ?? "",
        );

        // Refresh UI or any state observers
        updateGroupAdmins.value = false;
        updateGroupAdmins.value = true;
      }
    });

    _socket?.on('group-admin-toggled', (data) async {
      print('✅ Admin toggled in group: $data');

      // Parse the data manually if you're not using CreateGroupModel anymore
      final groupMap = data["group"];
      final userMap = data["users"];

      Group group = Group.fromJson(groupMap);
      User user = User.fromJson(userMap);
      // print("after Parsing group: ${group.toJson()} \n after Parsing group: ${user.toJson()}");
      if (group != null && user != null) {
        // update user's profile if needed
        await groupsTable.updateUserIfNeeded(user.userInfo!);

        // update user group role
        await groupsTable.updateUserGroupRole(
          groupId: user.userGroupInfo?.groupId ?? 0,
          userId: user.userGroupInfo?.userId ?? 0,
          isAdmin: user.userGroupInfo?.isAdmin ?? false,
          isRemoved: user.userGroupInfo?.isRemoved ?? false,
          updaterId: user.userGroupInfo?.updaterId ?? 0,
          createdAt: user.userGroupInfo?.createdAt ?? "",
          updatedAt: user.userGroupInfo?.updatedAt ?? "",
        );
        updateGroupAdmins.value = false;
        updateGroupAdmins.value = true;
      }
    });

    _socket?.on('group-deleted', (data) async {
      print("✅ Group deleted: $data");
      final responseModel = CreateGroupModel.fromJson(data);
      if (responseModel.status == true && responseModel.data != null) {
        await groupsTable.insertOrUpdateGroup(responseModel.data!);
        final data = responseModel.data;
        final groupId = data?.group?.id ?? 0;
        await chatConectTable.updateContact(
          uid: groupId.toString(),
          isGroup: 1,
          profilePic: data?.group?.displayPictureUrl ?? '',
          timeSent: data?.group?.updatedAt ?? "",
          name: data?.group?.name ?? '',
        );
      }
    });

    _socket?.on('custom-error', (data) async {
      print('🚫 Custom Error: $data');
      final statusCode = data['statusCode'];
      if (statusCode == 401) {
        showAlertMessage("Your session has expired. Please log in again.");
        await logoutApp(() {
          Get.offAllNamed(Routes.LANDING);
        });
      }
    });

    _socket?.on('user-blocked', (data) async {
      print(data);

      incomBlockUser.value = BlockUserModel(
        blockedBy: data["blockedBy"],
        isBlock: data["isBlock"],
      );
    });

    // status time
    _socket?.on('config-change', (data) async {
      if (data["statusDuration"] != null) {
        sharedPreferenceService.setInt(
          UserDefaultsKeys.statusDurationKey,
          int.parse(data["statusDuration"].toString()),
        );
      }

      if (data["messageDuration"] != null) {
        sharedPreferenceService.setInt(
          UserDefaultsKeys.messageDurationKey,
          int.parse(data["messageDuration"].toString()),
        );
      }

      print(data);
    });

    // group israedonly chg
    _socket?.on('group-state-toggled', (data) async {
      print(data);

      groupsTable.updateGroupReadOnly(
        data["groupId"],
        data["isReadOnly"] ? 1 : 0,
      );
      groupRedOnly.value = ReadOnlyAdmin(
        groupId: data["groupId"],
        isReadOnly: data["isReadOnly"],
      );
      // groupId, isReadOnly
    });
    //  vanish mode
    _socket?.on('group-message-autodelete-toggled', (data) async {
      print(data);
      // groupId, userId,autoDeleteMessages

      groupsTable.updateAutoDeleteMessages(
        groupId: data["groupId"],
        userId: data["userIds"][0],
        autoDeleteMessages: data["autoDeleteMessages"],
      );

      // VanishModeAutoDelete

      vanishModeAutoDelete.value = VanishModeAutoDelete(
        groupId: data["groupId"],
        autoDeleteMessages: data["autoDeleteMessages"],
        userId: data["userIds"][0],
      );
      // fndj
      // getGroupDataFromLocal
      // groupId, isReadOnly
    });
  }

  void sendMessage(NewMessageModel data) async {
    saveChatContacts(data);

    _socket?.emit('message-event', data.toMap());
  }

  void sendMessageSync(NewMessageModel data) async {
    _socket?.emit('message-event', data.toMap());
  }

  void sendMessageSeen(int messageId) {
    messageTable.updateAckStateMessage(
      messageId: messageId.toString(),
      state: 3,
    );
    _socket?.emit('message-seen', {"messageId": messageId});
  }

  void sendMessageSeenGroup(int messageId, String recipientUserId) {
    // messageTable.updateAckStateMessage(
    //   messageId: messageId.toString(),
    //   state: 2,
    // );
    _socket?.emit('group-message-seen', {
      "messageId": messageId,
      "groupRecipientId": recipientUserId,
    });
  }

  void checkUserOnline(Map<String, dynamic> data) {
    _socket?.emit('user-connection-status', data);
  }

  void emitTypingStatus({required String recipientId, required bool isTyping}) {
    _socket?.emit('typing', {"recipientId": recipientId, "isTyping": isTyping});
  }

  void emitGroupTypingStatus({
    required String recipientId,
    required bool isTyping,
  }) {
    _socket?.emit('group-user-typing', {
      "groupId": recipientId,
      "isTyping": isTyping,
    });
  }

  void monitorReceiverTyping(
    String receiverUserId,
    void Function(bool isTyping) onTypingStatusChanged,
  ) {
    ever(typingStatusMap, (_) {
      if (typingStatusMap.containsKey(receiverUserId)) {
        onTypingStatusChanged(typingStatusMap[receiverUserId] == true);
      }
    });
  }

  Future<void> updateGroupTypingFromEvent({
    required String groupId,
    required String userId,
    required bool isTyping,
  }) async {
    final uid = int.tryParse(userId) ?? -1;
    final gid = int.tryParse(groupId) ?? -1;

    String? userName;

    // 🔍 Step 1: Check local contact table
    final user = await contactsTable.getUserById(uid);
    if (user != null) {
      userName = user.localName?.isNotEmpty == true
          ? user.localName
          : user.name;
    } else {
      // 🔍 Step 2: Fallback → get phoneNumber from group members
      final groupData = await groupsTable.getGroupById(gid);
      userName = groupData?.users
          ?.firstWhere(
            (u) => u.userInfo?.userId == uid,
            orElse: () => User(userInfo: null, userGroupInfo: null),
          )
          .userInfo
          ?.phoneNumber;
    }

    // 🔄 Step 3: Update typing map
    final groupMap = typingGroupUsersMap[groupId] ?? {};
    if (isTyping && userName != null && userName.isNotEmpty) {
      groupMap[userId] = userName;
    } else {
      groupMap.remove(userId); //lmlmgmrogrogm
    }
    typingGroupUsersMap[groupId] = Map.from(groupMap);
  }

  void monitorGroupTyping(
    String groupId,
    void Function(List<String> typingUserNames) onTypingUsersChanged,
  ) {
    ever(typingGroupUsersMap, (_) {
      final users = typingGroupUsersMap[groupId]?.values.toList() ?? [];
      onTypingUsersChanged(users);
    });
  }

  void emitMessageDelete({
    required int messageId,
    required bool isDeleteFromEveryOne,
  }) {
    _socket?.emit('message-delete', {
      "messageId": messageId,
      "deleteState": isDeleteFromEveryOne,
    });
  }

  Future<void> disposeSocket() async {
    if (_socket?.connected == true) {
      _socket?.disconnect();
    }
    _clearSocketListeners();
    _socket?.dispose();
    _socket = null;
    print('🔌 Socket disposed manually');
  }

  Future<void> saveChatContacts(NewMessageModel data) async {
    try {
      final messageText = _getMessageTypeText(data);

      // ✅ 1. Handle GROUP message
      if (data.isGroupMessage == true) {
        final groupId = data.recipientId.toString();
        final group = await groupsTable.getGroupById(int.parse(groupId));

        if (group != null) {
          final existing = await chatConectTable.fetchById(
            uid: groupId,
            isGroup: true,
          );

          if (existing != null) {
            await chatConectTable.updateContact(
              uid: groupId,
              lastMessage: messageText,
              lastMessageId: data.messageId,
              timeSent: data.messageSentFromDeviceTime,
              name: existing.name, // Don't override name/profilePic
              profilePic: existing.profilePic,
              isGroup: 1,
            );
          } else {
            await chatConectTable.insert(
              contact: ChatConntactModel(
                uid: groupId,
                contactId: groupId,
                lastMessage: messageText,
                lastMessageId: data.messageId,
                timeSent: data.messageSentFromDeviceTime,
                name: group.group?.name ?? '',
                profilePic: group.group?.displayPictureUrl ?? '',
                isGroup: 1,
              ),
            );
          }
        }
        return; // ✅ Done with group
      }

      // ✅ 2. Handle PERSONAL message
      final userId = data.recipientId.toString();
      final existing = await chatConectTable.fetchById(
        uid: userId,
        isGroup: false,
      );

      final user = await contactsTable.getUserById(data.recipientId!);
      final name = user?.localName == "" || user?.localName == null
          ? data.receiverPhoneNumber
          : user?.localName;
      final profilePic = user?.displayPictureUrl ?? '';

      // if(user != null){
      if (existing != null) {
        await chatConectTable.updateContact(
          uid: userId,
          lastMessage: messageText,
          lastMessageId: data.messageId,
          timeSent: data.messageSentFromDeviceTime,
          name: name,
          profilePic: profilePic,
          isGroup: 0,
        );
      } else {
        await chatConectTable.insert(
          contact: ChatConntactModel(
            uid: userId,
            contactId: userId,
            lastMessage: messageText,
            lastMessageId: data.messageId,
            timeSent: data.messageSentFromDeviceTime,
            name: name != null && name.isNotEmpty
                ? name
                : data.senderPhoneNumber,
            profilePic: profilePic,
            isGroup: 0,
          ),
        );
      }
      // }else{
      //   final fallbackName = data.receiverPhoneNumber ??
      //       "Unknown"; // You must pass senderPhoneNumber in NewMessageModel
      //   final fallbackUid = data.recipientId ?? "0";
      //
      //   if (existing != null) {
      //     await chatConectTable.updateContact(
      //       uid: fallbackUid.toString(),
      //       lastMessage: messageText,
      //       lastMessageId: data.messageId,
      //       timeSent: data.messageSentFromDeviceTime,
      //       name: fallbackName,
      //       profilePic: "",
      //       isGroup: 0,
      //     );
      //   } else {
      //     await chatConectTable.insert(
      //       contact: ChatConntactModel(
      //         uid: fallbackUid.toString(),
      //         contactId: fallbackUid.toString(),
      //         lastMessage: messageText,
      //         lastMessageId: data.messageId,
      //         timeSent: data.messageSentFromDeviceTime,
      //         name: fallbackName,
      //         profilePic: "",
      //         isGroup: 0,
      //       ),
      //     );
      //     await contactsTable.insertPlaceholderUser(
      //         userId: int.parse(fallbackUid.toString()),
      //         isOnline: 1,
      //         phoneNumber: fallbackName,
      //         localName: fallbackName
      //     );
      //   }
      //

      // }
    } catch (e) {
      debugPrint("Error saving chat contact: $e");
    }
  }

  String? _getMessageTypeText(NewMessageModel data) {
    switch (data.messageType) {
      case MessageType.image:
      case MessageType.video:
      case MessageType.document:
      case MessageType.gif:
      case MessageType.audio:
        return data.messageType?.value;
      default:
        return data.message;
    }
  }

  Future<void> retryPendingDeletions() async {
    final pendingDeletions = await messageTable.getQueuedDeletions();

    for (var entry in pendingDeletions) {
      final messageId = entry['messageId'];
      final isDeleteFromEveryone = entry['deleteState'] as bool;

      // Retry emitting
      emitMessageDelete(
        messageId: messageId,
        isDeleteFromEveryOne: isDeleteFromEveryone,
      );

      // After successful retry, remove from queue
      await messageTable.removeQueuedDeletion(messageId);
    }
  }

  Future<void> syncPendingMessages({required int loginUserId}) async {
    final dbMessages = await messageTable.fetchAllPendingMessages(
      loginUserId: loginUserId,
    );
    for (final msg in dbMessages) {
      if (msg.isAsset == false) {
        sendMessageSync(msg);
      }
    }
  }

  void runWhenConnected(VoidCallback action) {
    if (isConnected) {
      action();
    } else {
      _onSocketConnectedQueue.add(action);
    }
  }

  void _clearSocketListeners() {
    _socket?.clearListeners();
    // _socket?.off('message-event');
    // _socket?.off('message-acknowledgement');
    // _socket?.off('group-message-acknowledgement');
    // _socket?.off('user-connection-status');
    // _socket?.off('typing');
    // _socket?.off('message-delete');
    // _socket?.off('custom-error');
  }

  // Future<bool> refreshToken() async {
  //   String? refreshToken = sharedPreferenceService.getString(
  //     UserDefaultsKeys.refreshToken,
  //   );
  //   int? userId = sharedPreferenceService.getUserData()?.userId;

  //   print(
  //     "🔄 Refreshing Token...\n🔑 RefreshToken: $refreshToken\n👤 UserId: $userId",
  //   );

  //   if (refreshToken == null || userId == null) {
  //     print("🔴 No refresh token or user ID found!");
  //     return false;
  //   }

  //   try {
  //     final dio = Dio(
  //       BaseOptions(
  //         baseUrl: "${ApiEndpoints.baseUrl}${ApiEndpoints.apiVersion}",
  //         connectTimeout: const Duration(seconds: 50),
  //         receiveTimeout: const Duration(seconds: 50),
  //         headers: {
  //           'Accept': 'application/json',
  //           'Content-Type': 'application/json',
  //         },
  //       ),
  //     );

  //     Response response = await dio.post(
  //       'refresh-access-token',
  //       data: {"userId": userId, "refreshToken": refreshToken},
  //     );

  //     if (response.statusCode == 200 && response.data['status'] == true) {
  //       print(
  //         "🔁 Refresh token response: ${response.statusCode} ${response.data}",
  //       );
  //       String newAccessToken =
  //           response.data['data']['accessToken']; // ✅ Corrected key
  //       String newRefreshToken =
  //           response.data['data']['refreshToken']; // ✅ Corrected key

  //       print(
  //         "New Access Token: $newAccessToken\n New refresh token: $newRefreshToken",
  //       );
  //       await sharedPreferenceService.remove(UserDefaultsKeys.accessToken);
  //       // await sharedPreferenceService.remove(UserDefaultsKeys.refreshToken);
  //       await sharedPreferenceService.setString(
  //         UserDefaultsKeys.accessToken,
  //         newAccessToken,
  //       );
  //       // await sharedPreferenceService.setString(
  //       //   UserDefaultsKeys.refreshToken,
  //       //   newRefreshToken,
  //       // );

  //       print("✅ Token refreshed successfully!");
  //       return true;
  //     } else {
  //       print("🔴 Token refresh failed: ${response.data}");
  //     }
  //   } catch (e) {
  //     print("🔴 Refresh token request failed: $e");
  //   }
  //   print("🔴 Refresh token invalid, logging out...");

  //   // await sharedPreference.clear().then((onValue) {
  //   //   Get.offAllNamed(Routes.LANDING);
  //   // });
  //   return false;
  // }

  Future<void> sendBase64(File data) async {
    print(data.length);
    _socket?.emit('asset-start');

    // final base64String = await convertImageToBase64(data);
    // final chunks = splitIntoChunks(
    //   base64String,
    //   1024,
    // ); // 1KB per chunk (adjust as needed)
    final stream = data.openRead();

    await for (final chunk in stream) {
      // Option A: send raw binary (best)int
      print("chunk: $chunk");
      _socket?.emit("asset-chunk", chunk);

      // Option B: send base64 if your server requires text
      // final base64Chunk = base64Encode(chunk);
      // socket.write(jsonEncode({'type': 'chunk', 'data': base64Chunk}) + "\n");
    }

    // for (int i = 0; i < chunks.length; i++) {
    //   _socket?.emit("asset-chunk", chunks[i]);
    // }
    // _socket?.emit('test-asset-event', data);
    _socket?.emit('asset-end');
  }

  Future<String> convertImageToBase64(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    return base64Encode(bytes);
  }

  List<String> splitIntoChunks(String base64String, int chunkSize) {
    final chunks = <String>[];
    for (var i = 0; i < base64String.length; i += chunkSize) {
      final end = (i + chunkSize < base64String.length)
          ? i + chunkSize
          : base64String.length;
      chunks.add(base64String.substring(i, end));
    }
    return chunks;
  }

  Future<void> sendBase64Scientist(File data) async {
    const chunkSize = 512 * 1024;
    final raf = await data.open(mode: FileMode.read);
    final fileSize = await data.length();

    Uint8List buffer = Uint8List(chunkSize);
    int offset = 0;

    _socket?.emit('asset-start', {'size': fileSize});

    try {
      while (true) {
        final bytesRead = await raf.read(chunkSize);
        if (bytesRead.isEmpty) break;

        // ✅ Use sublistView to avoid copy overhead
        // final chunk = base64Encode(Uint8List.sublistView(buffer, 0, bytesRead));

        _socket?.emit('asset-chunk', bytesRead);
        // offset += bytesRead;
        // print("Progress: ${(offset / fileSize * 100).toStringAsFixed(2)}%");
      }

      _socket?.emit('asset-end', {'success': true});
    } finally {
      raf.closeSync();
    }
  }

  Future<void> logoutApp(Function()? onSuccess) async {
    await NotificationService.unsubscribeFromTopics();
    await db.closeDb();
    await disposeSocket();
    await sharedPreference.clear();
    onSuccess?.call();
  }

  void scheduleMessageDeletion({
    required int messageId,
    required String? sentTime,
    required int timerMinutes,
  }) {
    if (sentTime == null) return;

    final sentDate = DateTime.tryParse(sentTime);
    if (sentDate == null) return;

    final expiryTime = sentDate.add(Duration(minutes: timerMinutes));
    final delay = expiryTime.difference(DateTime.now());

    if (delay.isNegative) return;

    Future.delayed(delay, () async {
      print("🗑 Auto deleting message $messageId");
      await messageTable.deleteMessage(messageId);
    });
  }
}
