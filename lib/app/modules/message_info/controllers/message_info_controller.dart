import 'package:flutter/foundation.dart';
import 'package:genchatapp/app/config/services/connectivity_service.dart';
import 'package:genchatapp/app/constants/message_enum.dart';
import 'package:genchatapp/app/data/local_database/contacts_table.dart';
import 'package:genchatapp/app/data/local_database/message_info_table.dart';
// import 'package:genchatapp/app/data/local_database/message_table.dart';
import 'package:genchatapp/app/data/models/message_info_model.dart';
import 'package:genchatapp/app/data/models/new_models/response_model/create_group_model.dart';
import 'package:genchatapp/app/data/models/new_models/response_model/new_message_model.dart';
import 'package:genchatapp/app/data/repositories/group/group_repository.dart';
import 'package:genchatapp/app/modules/group_chats/controllers/group_chats_controller.dart';
import 'package:get/get.dart';

class MessageInfoController extends GetxController {
  //
  final ContactsTable contactsTable = ContactsTable();

  final GroupRepository groupRepository = Get.put<GroupRepository>(
    GroupRepository(apiClient: Get.find(), sharedPreferences: Get.find()),
  );

  final GroupChatsController groupChatsController = Get.find();

  final MessageInfoTable messageInfoTable = MessageInfoTable();

  final ConnectivityService connectivityService = Get.find();

  final Rx<NewMessageModel> selectedMessages = NewMessageModel().obs;

  final RxList<MessageInfoModel> messageInfoList = <MessageInfoModel>[].obs;

  final RxString path = "".obs;
  final RxString thumbnailPath = "".obs;

  final RxString gifPath = "".obs;

  final RxString audioPath = "".obs;
  final RxString videoPath = "".obs;

  final RxList<User> usersList = <User>[].obs;

  @override
  void onInit() {
    super.onInit();
    selectedMessages.value = Get.arguments[0];
    usersList.value = Get.arguments[1];
  }

  @override
  void onReady() async {
    super.onReady();
    getAllPaths();
    await getData();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> getData() async {
    if (connectivityService.isConnected.value) {
      await getMessageInfoApi(selectedMessages.value.messageId!);
    } else {
      await getLocalMessageInfo();
    }
  }

  Future<void> getMessageInfoApi(int messageId) async {
    try {
      // Step 1: Create group
      final response = await groupRepository.getMessageInfo(messageId);

      if (response != null && response.statusCode == 200) {
        List<MessageInfoModel> messageInfoData = (response.data['data'] as List)
            .map((e) => MessageInfoModel.fromJson(e))
            .toList();

        final message = await messageInfoTable.getMessageById(messageId);
        if (message.isNotEmpty) {
          for (var i = 0; i < messageInfoData.length; i++) {
            await messageInfoTable.updateMessage(messageInfoData[i]);
          }
          // await messageInfoTable.updateMessage(message);
          final newMessage = await messageInfoTable.getMessageById(messageId);

          messageInfoList.assignAll(newMessage);
        } else {
          for (var i = 0; i < messageInfoData.length; i++) {
            await messageInfoTable.insertMessage(messageInfoData[i]);
          }
          final message = await messageInfoTable.getMessageById(messageId);
          messageInfoList.assignAll(message);
        }

        if (kDebugMode) {}
      }
    } catch (e) {
      // showAlertMessage("Something went wrong: $e");
    } finally {}
  }

  Future<void> getLocalMessageInfo() async {
    final message = await messageInfoTable.getMessageById(
      selectedMessages.value.messageId!,
    );
    if (message.isNotEmpty) {
      messageInfoList.assignAll(message);
    }
  }

  void getAllPaths() async {
    if (selectedMessages.value.messageType == MessageType.image ||
        selectedMessages.value.messageType == MessageType.video ||
        selectedMessages.value.messageType == MessageType.gif ||
        selectedMessages.value.messageType == MessageType.audio ||
        selectedMessages.value.messageType == MessageType.document) {
      path.value = groupChatsController.getFilePath(
        selectedMessages.value.messageType!,
        selectedMessages.value.assetServerName!,
      );
    }
    thumbnailPath.value =
        "${groupChatsController.rootPath}Thumbnail/${selectedMessages.value.assetThumbnail}";

    gifPath.value =
        "${groupChatsController.rootPath}GIFs/${selectedMessages.value.assetThumbnail}";
    audioPath.value =
        "${groupChatsController.rootPath}Audio/${selectedMessages.value.assetThumbnail}";
  }

  Future<String> getLocalName(int? userId, String? name) async {
    if (userId == null) return name ?? "";
    final contact = await contactsTable.getUserById(userId);
    return "${contact?.localName ?? name}${contact!.isBlocked! ? "  This user is blocked by you!" : ""}";
  }
}
