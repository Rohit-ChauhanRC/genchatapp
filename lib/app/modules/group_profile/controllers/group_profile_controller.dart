import 'dart:io';
import 'package:genchatapp/app/data/local_database/chatconnect_table.dart';
import 'package:genchatapp/app/data/local_database/contacts_table.dart';
import 'package:genchatapp/app/data/models/new_models/response_model/create_group_model.dart';
import 'package:genchatapp/app/data/repositories/group/group_repository.dart';
import 'package:genchatapp/app/routes/app_pages.dart';
import 'package:genchatapp/app/services/shared_preference_service.dart';
import 'package:get/get.dart';

import '../../../config/services/socket_service.dart';
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
  final socketService = Get.find<SocketService>();

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
  set currentUserPermission(UserGroupInfo? info) =>
      _currentUserPermission.value = info;

  final Rx<File?> _image = Rx<File?>(null);
  File? get image => _image.value;
  set image(File? img) => _image.value = img;

  bool get isSuperAdmin =>
      groupDetails.group?.creatorId == currentUserPermission?.userId;

  bool get isAdmin => currentUserPermission?.isAdmin == true && !isSuperAdmin;

  bool get isMember => currentUserPermission?.isAdmin != true && !isSuperAdmin;

  bool get canEditGroup => isSuperAdmin || isAdmin;
  bool get canAddParticipants => isSuperAdmin || isAdmin;
  bool get canExitGroup => !isSuperAdmin;
  bool get canRevokeAdmin => isSuperAdmin;
  bool get canMakeAdmin => isSuperAdmin;
  bool get canRemoveMember => isSuperAdmin || isAdmin;

  @override
  void onInit() {
    super.onInit();
    groupId = Get.arguments;
    if (groupId != null || groupId != 0) {
      getGroupDetails(groupId: groupId);
    }
    bindSocketEvents();
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

  void bindSocketEvents() {
    ever(socketService.updateGroupAdmins, (bool? updateGroupAdmin) {
      if (updateGroupAdmin == true) {
        getGroupDetails(groupId: groupId);
      }
    });
  }

  Future<void> getGroupDetails({required int groupId}) async {
    final groupDetail = await groupTable.getGroupById(groupId);
    if (groupDetail != null) {
      groupDetails = groupDetail;
      print(
        "Data Fetched for GroupId: $groupId\nGroupDetails: ${groupDetail.toJson()}",
      );
      final userDetail = await contactsTable.getUserById(
        groupDetails.group?.creatorId ?? 0,
      );
      if (userDetail != null) {
        creatorUserDetail = userDetail;
      }

      final currentUserId = sharedPreferenceService.getUserData()?.userId;
      final currentUserInfo = groupDetail.users?.firstWhere(
        (u) => u.userInfo?.userId == currentUserId,
        orElse: () => User(userInfo: null, userGroupInfo: null),
      );
      currentUserPermission = currentUserInfo?.userGroupInfo;
    } else {
      print("Group Data are not fetched for GroupId: $groupId");
    }
  }

  Future<String> getLocalName(int? userId, String? name) async {
    if (userId == null) return name ?? "";
    final contact = await contactsTable.getUserById(userId);
    return "${contact?.localName ?? name}${contact!.isBlocked! ? "  This user is blocked by you!" : ""}";
  }

  Future<bool> getUerBlock(int? userId) async {
    final contact = await contactsTable.getUserById(userId!);
    return contact!.isBlocked!;
  }

  Future<void> selectImage() async {
    showImagePicker(
      onGetImage: (img) async {
        if (img != null) {
          image = img;

          try {
            final processedImage = image!;
            final uploadResponse = await groupRepository.uploadGroupPic(
              processedImage,
              groupId,
            );

            if (uploadResponse != null && uploadResponse.statusCode == 200) {
              // print("✅ Group icon uploaded: ${uploadResponse.data}");
              final responseModel = CreateGroupModel.fromJson(
                uploadResponse.data,
              );

              if (responseModel.status == true && responseModel.data != null) {
                if (responseModel.status == true) {
                  await groupTable.insertOrUpdateGroup(responseModel.data!);
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
              }
            } else {
              showAlertMessage('Failed to upload group picture.');
            }
          } catch (e) {
            showAlertMessage("Error uploading group icon: $e");
          }
        }
      },
    );
  }

  void updateGroupName(String newGroupName) async {
    try {
      final uploadResponse = await groupRepository
          .updateGroupNameAndDescription(
            isEditingGroupName: true,
            groupId: groupId,
            groupName: newGroupName,
          );

      if (uploadResponse != null && uploadResponse.statusCode == 200) {
        print("✅ Group name updated: ${uploadResponse.data}");
        final responseModel = CreateGroupModel.fromJson(uploadResponse.data);

        if (responseModel.status == true && responseModel.data != null) {
          if (responseModel.status == true) {
            await groupTable.insertOrUpdateGroup(responseModel.data!);
            final data = responseModel.data;
            final groupId = data?.group?.id ?? 0;
            await getGroupDetails(groupId: groupId);
            await chatConectTable.updateContact(
              uid: groupId.toString(),
              isGroup: 1,
              profilePic: data?.group?.displayPictureUrl ?? '',
              timeSent: data?.group?.updatedAt ?? "",
              name: data?.group?.name ?? '',
            );
          }
        }
      } else {
        showAlertMessage('Failed to update group name.');
      }
    } catch (e) {
      showAlertMessage("Error updating group name: $e");
    }
  }

  void updateGroupDescription(String newDesc) async {
    try {
      final uploadResponse = await groupRepository
          .updateGroupNameAndDescription(
            isEditingGroupName: false,
            groupId: groupId,
            groupDescription: newDesc,
          );

      if (uploadResponse != null && uploadResponse.statusCode == 200) {
        print("✅ Group description updated: ${uploadResponse.data}");
        final responseModel = CreateGroupModel.fromJson(uploadResponse.data);

        if (responseModel.status == true && responseModel.data != null) {
          if (responseModel.status == true) {
            await groupTable.insertOrUpdateGroup(responseModel.data!);
            final data = responseModel.data;
            final groupId = data?.group?.id ?? 0;
            await getGroupDetails(groupId: groupId);
            // await chatConectTable.updateContact(
            //   uid: groupId.toString(),
            //   isGroup: 1,
            //   profilePic: data?.group?.displayPictureUrl ?? '',
            //   timeSent: data?.group?.updatedAt ?? "",
            //   name: data?.group?.name ?? '',
            // );
          }
        }
      } else {
        showAlertMessage('Failed to update group description.');
      }
    } catch (e) {
      showAlertMessage("Error updating group description: $e");
    }
  }

  void makeAdmin(int userId) async {
    try {
      final uploadResponse = await groupRepository.makeNewAdmin(
        userId: userId,
        groupId: groupId,
      );

      if (uploadResponse != null && uploadResponse.statusCode == 200) {
        print("✅ Make Group admin: ${uploadResponse.data}");
        final responseModel = CreateGroupModel.fromJson(uploadResponse.data);

        if (responseModel.status == true && responseModel.data != null) {
          if (responseModel.status == true) {
            // await groupTable.insertOrUpdateGroup(responseModel.data!);
            // final data = responseModel.data;
            // final groupId = data?.group?.id ?? 0;
            // await getGroupDetails(groupId: groupId);
          }
        }
      } else {
        showAlertMessage('Failed to make group admin.');
      }
    } catch (e) {
      showAlertMessage("Error getting make group admin: $e");
    }
  }

  void revokeAdmin(int userId) async {
    try {
      final uploadResponse = await groupRepository.removeAdmin(
        userId: userId,
        groupId: groupId,
      );

      if (uploadResponse != null && uploadResponse.statusCode == 200) {
        print("✅ remove Group admin: ${uploadResponse.data}");
        final responseModel = CreateGroupModel.fromJson(uploadResponse.data);

        if (responseModel.status == true && responseModel.data != null) {
          if (responseModel.status == true) {
            // await groupTable.insertOrUpdateGroup(responseModel.data!);
            // final data = responseModel.data;
            // final groupId = data?.group?.id ?? 0;
            // await getGroupDetails(groupId: groupId);
          }
        }
      } else {
        showAlertMessage('Failed to remove group admin.');
      }
    } catch (e) {
      showAlertMessage("Error getting remove group admin: $e");
    }
  }

  void removeUser(int userId) async {
    try {
      final uploadResponse = await groupRepository.removeUser(
        userId: userId,
        groupId: groupId,
      );

      if (uploadResponse != null && uploadResponse.statusCode == 200) {
        print("✅ remove Group user: ${uploadResponse.data}");
        final responseModel = CreateGroupModel.fromJson(uploadResponse.data);

        if (responseModel.status == true && responseModel.data != null) {
          if (responseModel.status == true) {
            // await groupTable.insertOrUpdateGroup(responseModel.data!);
            // final data = responseModel.data;
            // final groupId = data?.group?.id ?? 0;
            await getGroupDetails(groupId: groupId);
          }
        }
      } else {
        showAlertMessage('Failed to remove group user.');
      }
    } catch (e) {
      showAlertMessage("Error getting remove group user: $e");
    }
  }

  void navigateToAddParticipant() {
    final existingMemberIds =
        groupDetails.users
            ?.where((u) => u.userGroupInfo?.isRemoved != true)
            .map((u) => u.userInfo?.userId ?? 0)
            .toList() ??
        [];
    Get.toNamed(
      Routes.ADD_PARTICIPENTS_IN_GROUP,
      arguments: {'groupId': groupId, 'existingMemberIds': existingMemberIds},
    );
  }

  Future<void> exitGroup() async {
    try {
      final currentUserId = sharedPreferenceService.getUserData()?.userId;
      final uploadResponse = await groupRepository.removeUser(
        userId: int.parse(currentUserId.toString()),
        groupId: groupId,
      );

      if (uploadResponse != null && uploadResponse.statusCode == 200) {
        print("✅ left Group user: ${uploadResponse.data}");
        final responseModel = CreateGroupModel.fromJson(uploadResponse.data);

        if (responseModel.status == true && responseModel.data != null) {
          if (responseModel.status == true) {
            // await groupTable.insertOrUpdateGroup(responseModel.data!);
            // final data = responseModel.data;
            // final groupId = data?.group?.id ?? 0;
            await getGroupDetails(groupId: groupId);
            Get.until((route) => route.settings.name == Routes.HOME);
          }
        }
      } else {
        showAlertMessage('Failed to left group user.');
      }
    } catch (e) {
      showAlertMessage("Error getting left group user: $e");
    }
  }

  Future<void> deleteGroup() async {

    try{
      // final currentUserId = sharedPreferenceService.getUserData()?.userId;
      final uploadResponse = await groupRepository.deleteGroup(groupId: groupId);

      if (uploadResponse != null && uploadResponse.statusCode == 200) {
        print("✅ delete Group: ${uploadResponse.data}");
        final responseModel = CreateGroupModel.fromJson(uploadResponse.data);

        if (responseModel.status == true && responseModel.data != null) {
          if (responseModel.status == true) {
            await groupTable.insertOrUpdateGroup(responseModel.data!);
            final data = responseModel.data;
            final groupId = data?.group?.id ?? 0;
            await getGroupDetails(groupId: groupId);
            Get.until((route) => route.settings.name == Routes.HOME);
          }
        }
      } else {
        showAlertMessage('Failed to delete group.');
      }
    }catch(e){
      showAlertMessage("Error getting delete group: $e");
    }
  }

}
