import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:genchatapp/app/config/services/connectivity_service.dart';
import 'package:genchatapp/app/config/services/firebase_controller.dart';
import 'package:genchatapp/app/constants/message_enum.dart';
import 'package:genchatapp/app/data/models/chat_conntact_model.dart';
import 'package:genchatapp/app/data/models/message_model.dart';
import 'package:genchatapp/app/data/models/message_reply.dart';
import 'package:genchatapp/app/data/models/user_model.dart';
import 'package:genchatapp/app/services/shared_preference_service.dart';
import 'package:genchatapp/app/utils/utils.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class SingleChatController extends GetxController with WidgetsBindingObserver {
  //

  final ConnectivityService connectivityService = Get.find();
  final FirebaseController firebaseController = Get.find();
  final sharedPreferenceService = Get.find<SharedPreferenceService>();

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

  final RxList<MessageModel> messageList = <MessageModel>[].obs;

  final Rx<FlutterSoundRecorder> soundRecorder = FlutterSoundRecorder().obs;

  FocusNode focusNode = FocusNode();

  final Rx<UserModel> _senderuserData = UserModel().obs;
  UserModel get senderuserData => _senderuserData.value;
  set senderuserData(UserModel userData) => _senderuserData.value = (userData);

  final RxString _id = "".obs;
  String get id => _id.value;
  set id(String str) => _id.value = str;

  final RxString _fullname = "".obs;
  String get fullname => _fullname.value;
  set fullname(String str) => _fullname.value = str;

  Rx<UserModel> receiveruserDataModel = UserModel(
    isOnline: false,
  ).obs;

  @override
  void onInit() {
    super.onInit();
    senderuserData = sharedPreferenceService.getUserDetails()!;

    id = Get.arguments[0];
    fullname = Get.arguments[1];
    bindStream();
    bindStreamMessages();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void bindStream() {
    receiveruserDataModel.bindStream(firebaseController.getUserData(id));
  }

  void bindStreamMessages() {
    messageList.bindStream(getMessageStream());
  }

  Stream<List<MessageModel>> getMessageStream() {
    return firebaseController.listenToMessages(
        currentUserId: senderuserData.uid!, receiverId: id.toString());
  }

  Future<void> sendTextMessage() async {
    if (isShowSendButton && messageController.text.trim().isNotEmpty) {
      sentTextMessageFirebase(
        context: Get.context!,
        text: messageController.text.trim(),
      );

      messageController.clear();
    } else {
      var tempDir = await getTemporaryDirectory();
      var path = '${tempDir.path}/flutter_sound.aac';
      if (!isRecorderInit) {
        return;
      }
      if (isRecording) {
        await soundRecorder.value.stopRecorder();
        // sendFileMessage(file: File(path), messageEnum: MessageEnum.audio);
      } else {
        await soundRecorder.value.startRecorder(
          toFile: path,
        );
      }
      isRecording = !isRecording;
    }
  }

  void sentTextMessageFirebase({
    required BuildContext context,
    required String text,
  }) async {
    try {
      var timeSent = DateTime.now();

      var messageId = const Uuid().v1();
      // users -> reciver user id =>chats -> current user id -> set data
      await _saveDataToContactsSubcollection(
        text,
        timeSent,
      );

      _saveMessageToMessageSubcollection(
        messageEnum: MessageEnum.text,
        messageId: messageId,
        text: text,
        timeSent: timeSent,
        messageReplied: messageReply,
      );
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  _saveDataToContactsSubcollection(
    String text,
    DateTime timeSent,
  ) async {
    // users -> reciever user id => chats -> current user id -> set data
    var recieverChatContact = ChatConntactModel(
      uid: senderuserData.uid!,
      name: senderuserData.name!,
      profilePic: senderuserData.profilePic!,
      contactId: senderuserData.uid!,
      timeSent: timeSent,
      lastMessage: text,
    );

    await firebaseController.sendUserMsg(
      currentUid: senderuserData.uid!,
      data: recieverChatContact,
      reciverId: receiveruserDataModel.value.uid!,
    );
    // users -> current user id  => chats -> reciever user id -> set data
    var senderChatContact = ChatConntactModel(
      uid: receiveruserDataModel.value.uid!,
      name: receiveruserDataModel.value.name!,
      profilePic: receiveruserDataModel.value.profilePic!,
      contactId: receiveruserDataModel.value.uid!,
      timeSent: timeSent,
      lastMessage: text,
    );

    await firebaseController.sendUserMsg(
      currentUid: receiveruserDataModel.value.uid!,
      data: senderChatContact,
      reciverId: senderuserData.uid!,
    );
  }

  void _saveMessageToMessageSubcollection({
    required String text,
    required DateTime timeSent,
    required String messageId,
    required MessageEnum messageEnum,
    required MessageReply? messageReplied,
  }) async {
    final message = MessageModel(
      status: MessageStatus.uploading,
      senderId: senderuserData.uid!,
      receieverid: receiveruserDataModel.value.uid!,
      text: text,
      type: messageEnum,
      timeSent: timeSent,
      messageId: messageId,
      repliedMessage:
          messageReplied == null ? '' : messageReplied.message.toString(),
      repliedMessageType: messageReplied!.message == null
          ? MessageEnum.text
          : messageReply.messageEnum!,
      repliedTo: messageReplied.message == null
          ? ''
          : messageReplied.isMe!
              ? senderuserData.name!
              : receiveruserDataModel.value.name ?? '',
    );

    // users -> sender id -> reciever id -> messages -> message id -> store message

    await firebaseController.setUserMsg(
      currentUid: senderuserData.uid!,
      data: message,
      messageId: messageId,
      reciverId: receiveruserDataModel.value.uid!,
    );
    // users -> reciever id  -> sender id -> messages -> message id -> store message
    await firebaseController.setUserMsg(
      currentUid: receiveruserDataModel.value.uid!,
      data: message,
      messageId: messageId,
      reciverId: senderuserData.uid!,
    );

    // await cancelReply();
  }

  Future<void> cancelReply() async {
    messageReply = MessageReply(
      isMe: false,
      message: null,
    );
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

  void showKeyboard() => focusNode.requestFocus();
  void hideKeyboard() => focusNode.unfocus();

  void hideEmojiContainer() {
    isShowEmojiContainer = false;
  }

  void showEmojiContainer() {
    isShowEmojiContainer = true;
  }
}
