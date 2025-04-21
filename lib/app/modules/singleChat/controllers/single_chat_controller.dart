import 'dart:async';
import 'dart:io';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:genchatapp/app/config/services/connectivity_service.dart';
import 'package:genchatapp/app/constants/message_enum.dart';
import 'package:genchatapp/app/data/models/message_model.dart';
import 'package:genchatapp/app/data/models/message_reply.dart';
import 'package:genchatapp/app/data/models/new_models/response_model/contact_response_model.dart';
import 'package:genchatapp/app/data/models/new_models/response_model/new_message_model.dart';
import 'package:genchatapp/app/data/models/new_models/response_model/verify_otp_response_model.dart';
import 'package:genchatapp/app/services/shared_preference_service.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:tenor_flutter/tenor_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../config/services/folder_creation.dart';
import '../../../config/services/socket_service.dart';
import '../../../data/local_database/contacts_table.dart';
import '../../../data/local_database/message_table.dart';
import '../../../utils/utils.dart';

class SingleChatController extends GetxController with WidgetsBindingObserver {
  //

  final connectivityService = Get.find<ConnectivityService>();
  // final firebaseController = Get.put(FirebaseController());
  final sharedPreferenceService = Get.find<SharedPreferenceService>();
  final FolderCreation folderCreation = Get.find<FolderCreation>();
  final ContactsTable contactsTable = ContactsTable();
  final socketService = Get.find<SocketService>();

  var hasScrolledInitially = false.obs;

  final TextEditingController messageController = TextEditingController();

  final Rx<Emoji> emoji = const Emoji("", "").obs;

  final ScrollController scrollController = ScrollController();

  final Rx<MessageReply> _messageReply = MessageReply().obs;
  MessageReply get messageReply => _messageReply.value;
  set messageReply(MessageReply msg) => _messageReply.value = msg;

  final RxBool _isShowSendButton = false.obs;
  bool get isShowSendButton => _isShowSendButton.value;
  set isShowSendButton(bool b) => _isShowSendButton.value = b;

  final RxBool _isRepUpdate = false.obs;
  bool get isRepUpdate => _isRepUpdate.value;
  set isRepUpdate(bool b) => _isRepUpdate.value = b;

  final RxBool _isReply = false.obs;
  bool get isReply => _isReply.value;
  set isReply(bool b) => _isReply.value = b;

  final RxBool _isShowEmojiContainer = false.obs;
  bool get isShowEmojiContainer => _isShowEmojiContainer.value;
  set isShowEmojiContainer(bool b) => _isShowEmojiContainer.value = b;

  final RxBool _isRecording = false.obs;
  bool get isRecording => _isRecording.value;
  set isRecording(bool b) => _isRecording.value = b;

  final RxBool _isRecorderInit = false.obs;
  bool get isRecorderInit => _isRecorderInit.value;
  set isRecorderInit(bool b) => _isRecorderInit.value = b;

  final RxBool _isLoading = true.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(bool b) => _isLoading.value = b;

  final RxList<NewMessageModel> messageList = <NewMessageModel>[].obs;

  final Rx<FlutterSoundRecorder> soundRecorder = FlutterSoundRecorder().obs;

  FocusNode focusNode = FocusNode();

  final Rx<UserData?> _senderuserData = UserData().obs;
  UserData? get senderuserData => _senderuserData.value;
  set senderuserData(UserData? userData) => _senderuserData.value = (userData);

  final Rx<UserList?> _receiverUserData = Rx<UserList?>(null);
  UserList? get receiverUserData => _receiverUserData.value;
  set receiverUserData(UserList? userData) {
    // print("receiverUserData updated: ${userData?.isOnline}");
    _receiverUserData.value = (userData);
  }

  final RxString _id = "".obs;
  String get id => _id.value;
  set id(String str) => _id.value = str;

  final RxString _fullname = "".obs;
  String get fullname => _fullname.value;
  set fullname(String str) => _fullname.value = str;

  final RxString _rootPath = "".obs;
  String get rootPath => _rootPath.value;
  set rootPath(String str) => _rootPath.value = str;

  // Rx<UserModel> receiveruserDataModel = UserModel(
  //   isOnline: false,
  // ).obs;

  final RxList<MessageModel> selectedMessages = <MessageModel>[].obs;
  late Stream<List<NewMessageModel>> messageStream;
  late StreamSubscription<List<NewMessageModel>> messageSubscription;

  late StreamSubscription<UserList?> receiverUserSubscription;

  @override
  void onInit() async {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    senderuserData = sharedPreferenceService.getUserData();

    UserList? user = Get.arguments;
    if (user != null) {
      checkUserOnline(user);
      receiverUserData = user;
      bindReceiverUserStream(user.userId ?? 0);
    }

    // print(
    //     "reciverName:----> ${receiverUserData?.localName}\nreceiverUserId:----> ${receiverUserData?.userId}");
    // fullname = Get.arguments[1];
    getRootFolder();
    // _startLoadingTimer();
    bindMessageStream();
    scrollController.addListener(handleScroll);
  }

  @override
  void onReady() {
    // bindStream();

    // startListeningForConnectivityChanges();
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
    WidgetsBinding.instance.removeObserver(this);
    selectedMessages.clear();
    messageSubscription.cancel();
    receiverUserSubscription.cancel();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        if (connectivityService.isConnected.value && !socketService.isConnected) {
          await socketService.initSocket(senderuserData!.userId.toString());
        }else if (socketService.isConnected){
          checkUserOnline(receiverUserData);
        }

        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.paused:
        disConnectSocket();

        break;
      default:
    }
  }

  void handleScroll() {
    if (!scrollController.hasClients) return;

    final maxScroll = scrollController.position.maxScrollExtent;
    final currentOffset = scrollController.offset;
    final viewportHeight = scrollController.position.viewportDimension;

    final isScrollable = maxScroll > viewportHeight;
    final isAtBottom = (maxScroll - currentOffset) <= 100;

    hasScrolledInitially.value = isScrollable && !isAtBottom;
  }

  void checkUserOnline(UserList? user) async {
    var params = {"recipientId": user?.userId};
    if (socketService.isConnected) {
      socketService.checkUserOnline(params);
    }
  }

  void disConnectSocket() async {
    socketService.disposeSocket();
  }

  void bindReceiverUserStream(int userId) {
    receiverUserSubscription = getReceiverStream(userId).listen((user) {
      if (user != null) {
        receiverUserData = user;
      }
    });
  }

  Stream<UserList?> getReceiverStream(int userId) async* {
    yield* Stream.periodic(const Duration(seconds: 1), (_) async {
      return await contactsTable.getUserById(userId);
    }).asyncMap((event) async => await event);
  }

  void _startLoadingTimer() {
    Timer(Duration(seconds: 3), () {
      isLoading = false; // Stop loading after 3 seconds
    });
  }

  Future<void> getRootFolder() async {
    rootPath = await folderCreation.getRootFolderPath();
  }

  void bindMessageStream() {
    messageStream = getMessageStream();
    messageSubscription = messageStream.listen((messages) {
      // print(messages);

      messageList.assignAll(messages);
      if (messages.isNotEmpty) {
        for (var i in messages) {
          if ((i.state == MessageState.sent ||
                  i.state == MessageState.unsent ||
                  i.state == MessageState.delivered) &&
              i.messageId != null) {
            if (receiverUserData!.userId == i.senderId &&
                socketService.isConnected) {
              socketService.sendMessageSeen(i.messageId!);
            }
          } else if (i.syncStatus == SyncStatus.pending &&
              i.messageId == null) {
            if (socketService.isConnected) {
              socketService.sendMessageSync(i);
            }
          }
        }
      }
    });
  }

  Stream<List<NewMessageModel>> getMessageStream() async* {
    yield* Stream.periodic(const Duration(seconds: 1), (_) async {
      return await MessageTable().fetchMessages(
        receiverId: receiverUserData?.userId ?? 0,
        senderId: senderuserData?.userId ?? 0,
      );
    }).asyncMap((event) async => await event);
  }

  // void startListeningForConnectivityChanges() {
  //   ever(connectivityService.isConnected, (bool isConnected) async {
  //     if (isConnected) {
  //       await syncFirebaseMessagesToLocal();
  //     }
  //   });
  // }

  // void bindStream() {
  //   receiveruserDataModel.bindStream(firebaseController.getUserData(id));
  // }

  Future<void> sendTextMessage() async {
    if (messageController.text.trim().isEmpty) return;

    final clientSystemMessageId = const Uuid().v1();
    final timeSent = DateTime.now();

    final newMessage = NewMessageModel(
      senderId: senderuserData?.userId,
      recipientId: receiverUserData?.userId,
      message: messageController.text.trim(),
      messageSentFromDeviceTime: timeSent.toString(),
      clientSystemMessageId: clientSystemMessageId,
      state: MessageState.unsent,
      syncStatus: SyncStatus.pending,
      createdAt: timeSent.toString(),
      senderPhoneNumber: senderuserData?.phoneNumber,
    );
    await MessageTable().insertMessage(newMessage).then((onValue) {
      Future.delayed(Durations.medium4);
      if (socketService.isConnected) {
        socketService.sendMessage(newMessage);
      }
    });

    // messageList.add(newMessage);
    messageController.clear();
    // await cancelReply();

    // if (connectivityService.isConnected.value) {
    // await _syncMessageToFirebase(newMessage);
    // }
  }

  // Future<void> _syncMessageToFirebase(MessageModel message) async {
  //   try {
  //     await _saveDataToContactsSubcollection(message);
  //     final sentMessage = message.copyWith(
  //         status: receiveruserDataModel.value.isOnline!
  //             ? MessageStatus.delivered
  //             : MessageStatus.sent,
  //         syncStatus: 'sent');
  //
  //     await firebaseController.setUserMsg(
  //         currentUid: sentMessage.senderId,
  //         data: sentMessage,
  //         messageId: sentMessage.messageId,
  //         reciverId: sentMessage.receiverId);
  //     // Save message in the receiver's chat with 'delivered' status
  //     final deliveredMessage =
  //         message.copyWith(status: MessageStatus.delivered, syncStatus: 'sent');
  //     // users -> reciever id  -> sender id -> messages -> message id -> store message
  //     await firebaseController.setUserMsg(
  //         currentUid: deliveredMessage.receiverId,
  //         data: deliveredMessage,
  //         messageId: deliveredMessage.messageId,
  //         reciverId: deliveredMessage.senderId);
  //
  //     // Update sync status in SQLite
  //     await MessageTable()
  //         .updateSyncStatus(message.messageId, 'sent', MessageStatus.delivered);
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print("Error syncing message: $e");
  //     }
  //   }
  // }

  // void retryPendingMessages() async {
  //   final unsentMessages = await MessageTable().fetchUnsentMessages();
  //
  //   for (var message in unsentMessages) {
  //     if (connectivityService.isConnected.value) {
  //       try {
  //         if (message.type == MessageEnum.text) {
  //           await _syncMessageToFirebase(message);
  //         }
  //         else if (message.type != MessageEnum.text && message.fileUrl == null) {
  //           final file = File(message.filePath ?? '');
  //           final fileUrl = await uploadFileToServer(file, message.type.toString());
  //           message = message.copyWith(fileUrl: fileUrl);
  //
  //           await _syncMessageToFirebase(message);
  //         }
  //       } catch (e) {
  //         if (kDebugMode) {
  //           print("Error syncing message: $e");
  //         }
  //       }
  //     } else {
  //       if (kDebugMode) {
  //         print("No connectivity, unable to sync message: ${message.toMap()}");
  //       }
  //       break;
  //     }
  //   }
  //
  //   // Retry pending deletions
  //   final queuedDeletions = await MessageTable().getQueuedDeletions();
  //   for (var messageId in queuedDeletions) {
  //     if (connectivityService.isConnected.value) {
  //       try {
  //         await firebaseController.deleteMessage(
  //           currentUid: senderuserData!.userId.toString(),
  //           receiverId: id,
  //           messageId: messageId,
  //         );
  //         await MessageTable().removeQueuedDeletion(messageId);
  //       } catch (e) {
  //         print("Error syncing deletion: $e");
  //       }
  //     }
  //   }
  // }
  //
  // void markMessagesAsSeen(MessageModel messages) async {
  //   final currentUserId = messages.receiverId;
  //   final senderId = messages.senderId.toString(); // ID of the chat partner
  //
  //   // Update status only for messages not yet marked as 'seen'
  //   if (messages.status == MessageStatus.delivered &&
  //       messages.receiverId == senderuserData!.userId.toString()) {
  //     await firebaseController.updateMessageStatus(
  //       currentUserId: senderuserData!.userId.toString(),
  //       senderId: senderId,
  //       messageId: messages.messageId,
  //       status: receiveruserDataModel.value.isOnline!
  //           ? MessageStatus.seen
  //           : messages.status,
  //     );
  //   }
  // }
  //
  // Future<void> deleteMessages({required bool deleteForEveryone}) async {
  //   if (selectedMessages.isEmpty) return;
  //
  //   try {
  //     for (var message in selectedMessages) {
  //       if (deleteForEveryone) {
  //         // Delete for everyone
  //         final placeholderMessage = message.copyWith(
  //           text: "This message was deleted",
  //           type: MessageEnum.deleted,
  //         );
  //
  //         // Update the message for both sender and receiver in Firebase
  //         await firebaseController.setUserMsg(
  //           currentUid: message.senderId,
  //           data: placeholderMessage,
  //           messageId: message.messageId,
  //           reciverId: message.receiverId,
  //         );
  //
  //         await firebaseController.setUserMsg(
  //           currentUid: message.receiverId,
  //           data: placeholderMessage,
  //           messageId: message.messageId,
  //           reciverId: message.senderId,
  //         );
  //
  //         // Update the message content locally in SQLite
  //         await MessageTable().updateMessageContent(
  //           messageId: message.messageId,
  //           newText: "This message was deleted",
  //         );
  //
  //         // Update the message in the UI
  //         final index = messageList
  //             .indexWhere((msg) => msg.messageId == message.messageId);
  //         if (index != -1) {
  //           messageList[index] = placeholderMessage;
  //           messageList.refresh();
  //         }
  //       } else {
  //         // Delete for me (local deletion only)
  //         await MessageTable().deleteMessage(message.messageId);
  //         messageList.removeWhere((msg) => msg.messageId == message.messageId);
  //
  //         // Optionally, queue deletion for Firebase if offline
  //         if (connectivityService.isConnected.value) {
  //           await firebaseController.deleteMessage(
  //             currentUid: senderuserData!.userId.toString(),
  //             receiverId: id,
  //             messageId: message.messageId,
  //           );
  //         } else {
  //           await MessageTable().markForDeletion(message.messageId);
  //         }
  //       }
  //     }
  //     selectedMessages.clear();
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print("Error deleting messages: $e");
  //     }
  //   }
  // }

  void toggleMessageSelection(MessageModel message) {
    if (selectedMessages.contains(message)) {
      selectedMessages.remove(message);
      if (kDebugMode) {
        // print("Message removed from list:------> $message");
      }
    } else {
      selectedMessages.add(message);
      if (kDebugMode) {
        // print("Message added to list:------> $message");
      }
    }
    selectedMessages.refresh();
  }

  void clearSelectedMessages() {
    selectedMessages.clear();
  }

  // _saveDataToContactsSubcollection(MessageModel message) async {
  //   // users -> reciever user id => chats -> current user id -> set data
  //   var recieverChatContact = ChatConntactModel(
  //     uid: message.senderId,
  //     name: senderuserData?.name ?? "",
  //     profilePic: senderuserData?.displayPictureUrl ?? "",
  //     contactId: message.senderId,
  //     timeSent: message.timeSent,
  //     lastMessage: message.text,
  //   );
  //
  //   await firebaseController.sendUserMsg(
  //     currentUid: message.senderId,
  //     data: recieverChatContact,
  //     reciverId: message.receiverId,
  //   );
  //   // users -> current user id  => chats -> reciever user id -> set data
  //   var senderChatContact = ChatConntactModel(
  //     uid: message.receiverId,
  //     name: receiveruserDataModel.value.name!,
  //     profilePic: receiveruserDataModel.value.profilePic!,
  //     contactId: message.receiverId,
  //     timeSent: message.timeSent,
  //     lastMessage: message.text,
  //   );
  //
  //   await firebaseController.sendUserMsg(
  //     currentUid: message.receiverId,
  //     data: senderChatContact,
  //     reciverId: message.senderId,
  //   );
  // }

  Future<void> cancelReply() async {
    messageReply = MessageReply(
      isMe: false,
      message: null,
    );
  }

  void selectFile(String fileType) async {
    File? selectedFile;

    if (fileType == MessageEnum.image.type) {
      selectedFile = await pickImage();
    } else if (fileType == MessageEnum.video.type) {
      // selectedFile = await pickVideo();
    } else if (fileType == MessageEnum.audio.type) {
      // selectedFile = await pickAudio();
    } else if (fileType == MessageEnum.document.type) {
      // selectedFile = await pickDocument();
    }

    if (selectedFile != null) {
      // sendFileMessage(file: selectedFile, messageEnum: fileType.toEnum());
    }
  }

  // Future<void> sendFileMessage({
  //   required File file,
  //   required MessageEnum messageEnum,
  // }) async {
  //   final messageId = const Uuid().v1();
  //   final timeSent = DateTime.now();
  //   final fileType = messageEnum.type.split('.').last;
  //   final fileExtension = file.toString().split('.').last.replaceAll("'", "");
  //   try {
  //     // Save file locally
  //     final localFilePath = await saveFileLocally(file, fileType, fileExtension);
  //
  //     // Upload file to the server
  //     final fileUrl = await uploadFileToServer(file, fileType);
  //
  //     final newMessage = MessageModel(
  //       senderId: senderuserData!.userId.toString(),
  //       receiverId: id.toString(),
  //       text: fileType,
  //       type: messageEnum,
  //       timeSent: timeSent,
  //       messageId: messageId,
  //       status: MessageStatus.uploading,
  //       repliedMessage: messageReply == null
  //           ? '' : messageReply.message.toString(),
  //       repliedTo: messageReply.message == null ? '' :
  //       messageReply.isMe!
  //           ? senderuserData?.name ?? ""
  //           : receiveruserDataModel.value.name ?? "",
  //       repliedMessageType: messageReply.message == null
  //           ? MessageEnum.text
  //           : messageReply.messageEnum!,
  //       syncStatus: 'pending',
  //       fileUrl: fileUrl,
  //       filePath: localFilePath,
  //       fileSize: 0,
  //       thumbnailPath: ""
  //     );
  //
  //     // Save message locally
  //     await MessageTable().insertMessage(newMessage);
  //     messageList.add(newMessage);
  //
  //     // Sync message with Firebase if online
  //     if (connectivityService.isConnected.value) {
  //       // await _syncMessageToFirebase(newMessage.copyWith(
  //       //   status: receiveruserDataModel.value.isOnline!
  //       //       ? MessageStatus.delivered
  //       //       : MessageStatus.sent,
  //       // ));
  //     }
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print("Error sending file message: $e");
  //     }
  //   }
  // }

  // Future<String> uploadFileToServer(File file, String fileType) async {
  //   try {
  //     final fileName = 'GENCHAT_$fileType${senderuserData!.userId.toString()}_${DateTime.now().millisecondsSinceEpoch}';
  //     final serverPath = 'chat/$fileType/${senderuserData!.userId.toString()}/$fileName';
  //
  //     // Upload file to Firebase Storage or server
  //     final uploadTask = firebaseController.firebaseStorage.ref(serverPath).putFile(file);
  //     final snapshot = await uploadTask;
  //     final fileUrl = await snapshot.ref.getDownloadURL();
  //     print("FileURL from server:-----------------> $fileUrl");
  //
  //     return fileUrl; // Return public file URL
  //   } catch (e) {
  //     throw Exception("File upload failed: $e");
  //   }
  // }

  Future<String> saveFileLocally(
      File file, String fileType, String fileExtension) async {
    final subFolderName = fileType.toTitleCase;
    final fileName =
        "GENCHAT_$fileType-${senderuserData!.userId.toString()}-${DateTime.now().millisecondsSinceEpoch}.$fileExtension";
    final filePath = await folderCreation.saveFileFromFile(
      sourceFile: file,
      fileName: fileName,
      subFolder: subFolderName,
    );
    // print("FileName for saving locally:----------------> $fileName");
    // print("FilePath for saving locally:----------------> $filePath");
    return '$subFolderName/$fileName';
  }

  Future<File?> pickImage() async {
    Completer<File?> completer = Completer<File?>();
    showImagePicker(onGetImage: (img) {
      if (img != null) {
        // sendFileMessage(
        //   file: img,
        //   messageEnum: MessageEnum.image,
        // );
        completer.complete(img);
      } else {
        completer.complete(null);
      }
    });
    return completer.future;
  }

  void selectGif() async {
    TenorResult? gif = await pickGIF(Get.context!);
    if (gif != null) {
      // sendGIFMessage(
      //   context: Get.context!,
      //   gifUrl: gif.media.tinyGif?.url ?? gif.media.tinyGifTransparent!.url,
      // );
    }
  }

  void toggleEmojiKeyboardContainer() {
    if (isShowEmojiContainer) {
      showKeyboard();
      hideEmojiContainer();
    } else {
      hideKeyboard();
      showEmojiContainer();
    }
  }

  void onMessageSwipe({
    required String message,
    required bool isMe,
    required MessageEnum messageEnum,
  }) {
    messageReply = MessageReply(
      message: message,
      isMe: isMe,
      messageEnum: messageEnum.type.toEnum(),
    );
  }

  void showKeyboard() => focusNode.requestFocus();
  void hideKeyboard() => focusNode.unfocus();

  void hideEmojiContainer() {
    isShowEmojiContainer = false;
  }

  void showEmojiContainer() {
    isShowEmojiContainer = true;
  }
}
