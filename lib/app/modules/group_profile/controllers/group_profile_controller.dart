import 'dart:io';
import 'package:genchatapp/app/data/local_database/chatconnect_table.dart';
import 'package:genchatapp/app/data/local_database/contacts_table.dart';
import 'package:genchatapp/app/data/models/new_models/response_model/create_group_model.dart';
import 'package:genchatapp/app/data/repositories/group/group_repository.dart';
import 'package:genchatapp/app/services/shared_preference_service.dart';
import 'package:get/get.dart';

import '../../../data/local_database/groups_table.dart';
import '../../../data/models/chat_conntact_model.dart';
import '../../../data/models/new_models/response_model/contact_response_model.dart';
import '../../../utils/alert_popup_utils.dart';
import '../../../utils/utils.dart';

class GroupProfileController extends GetxController {

  final GroupsTable groupTable = GroupsTable();
  final ContactsTable contactsTable = ContactsTable();
  final ChatConectTable chatConectTable = ChatConectTable();
  final sharedPreferenceService = Get.find<SharedPreferenceService>();
  final GroupRepository groupRepository = Get.find<GroupRepository>();

  final RxInt _groupId = 0.obs;
  int get groupId => _groupId.value;
  set groupId(int a) => _groupId.value = a;

  final Rx<GroupData> _groupDetails = GroupData().obs;
  GroupData get groupDetails => _groupDetails.value;
  set groupDetails(GroupData a) => _groupDetails.value = a;

  final Rx<UserList> _creatorUserDetail = UserList().obs;
  UserList get creatorUserDetail => _creatorUserDetail.value;
  set creatorUserDetail(UserList a) => _creatorUserDetail.value = a;

  final Rx<UserGroupInfo?> _currentUserPermission = Rx<UserGroupInfo?>(null);
  UserGroupInfo? get currentUserPermission => _currentUserPermission.value;
  set currentUserPermission(UserGroupInfo? info) => _currentUserPermission.value = info;

  final Rx<File?> _image = Rx<File?>(null);
  File? get image => _image.value;
  set image(File? img) => _image.value = img;

  bool get isSuperAdmin =>
      groupDetails.group?.creatorId == currentUserPermission?.userId;

  bool get isAdmin =>
      currentUserPermission?.isAdmin == true && !isSuperAdmin;

  bool get isMember =>
      currentUserPermission?.isAdmin != true && !isSuperAdmin;

  bool get canEditGroup => isSuperAdmin;
  bool get canAddParticipants => isSuperAdmin || isAdmin;
  bool get canExitGroup => !isSuperAdmin;
  bool get canRevokeAdmin => isSuperAdmin;
  bool get canMakeAdmin => isSuperAdmin;
  bool get canRemoveMember => isSuperAdmin || isAdmin;

  @override
  void onInit() {
    super.onInit();
    groupId = Get.arguments;
    if(groupId != null || groupId != 0){
      getGroupDetails(groupId: groupId);
    }
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
    groupId = 0;
  }

  Future<void> getGroupDetails({required int groupId}) async{

    final groupDetail = await groupTable.getGroupById(groupId);
    if(groupDetail != null){
      groupDetails = groupDetail;
      print("Data Fetched for GroupId: $groupId\nGroupDetails: ${groupDetail.toJson()}");
      final userDetail = await contactsTable.getUserById(groupDetails.group?.creatorId ?? 0);
      if(userDetail != null){
        creatorUserDetail = userDetail;
      }

      final currentUserId = sharedPreferenceService.getUserData()?.userId;
      final currentUserInfo = groupDetail.users?.firstWhere(
            (u) => u.userInfo?.userId == currentUserId,
        orElse: () => User(userInfo: null, userGroupInfo: null),
      );
      currentUserPermission = currentUserInfo?.userGroupInfo;

    }
  }

  Future<String> getLocalName(int? userId, String? name) async{
    if (userId == null) return name ?? "";
    final contact = await contactsTable.getUserById(userId);
    return contact?.localName ?? name ?? "";
  }

  Future<void> selectImage() async {
    showImagePicker(onGetImage: (img) async {
      if (img != null) {
        image = img;

        try {
          final processedImage = image!;
          final uploadResponse = await groupRepository.uploadGroupPic(processedImage, groupId);

          if (uploadResponse != null && uploadResponse.statusCode == 200) {
            print("✅ Group icon uploaded: ${uploadResponse.data}");
            final responseModel = CreateGroupModel.fromJson(uploadResponse.data);

            if (responseModel.status == true && responseModel.data != null) {
              if (responseModel.status == true) {
                await groupTable.insertOrUpdateGroup(responseModel.data!);
                final data = responseModel.data;
                final groupId = data?.group?.id ?? 0;
                await chatConectTable.insert(
                  contact: ChatConntactModel(
                    lastMessageId: 0,
                    contactId: groupId.toString(),
                    lastMessage: "",
                    name: data?.group?.name ?? '',
                    profilePic: data?.group?.displayPictureUrl ?? '',
                    timeSent:  data?.group?.updatedAt ?? "",//DateTime.now().toString(),//data?.group?.createdAt ?? '',
                    uid: groupId.toString(),
                    isGroup: 1,
                  ),
                );
              }
            }
          } else {
            showAlertMessage('Failed to upload group picture.');
          }
        } catch (e) {
          showAlertMessage("Error uploading group icon: $e");
        }
      }
    });
  }

  void updateGroupName(String newName) async {

    // await groupTable.updateGroupName(groupId, newName);
    // await getGroupDetails(groupId: groupId);
  }

  void updateGroupDescription(String newDesc) async {
    // await groupTable.updateGroupDescription(groupId, newDesc);
    // await getGroupDetails(groupId: groupId);
  }

  void removeParticipant(int userId) async {
    // await groupTable.removeUserFromGroup(userId, groupId);
    // await getGroupDetails(groupId: groupId);
  }

  void navigateToAddParticipant() {
    // Get.toNamed('/add_participants', arguments: groupId);
  }


}
