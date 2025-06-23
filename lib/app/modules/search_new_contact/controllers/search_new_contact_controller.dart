import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:genchatapp/app/data/models/new_models/response_model/contact_response_model.dart';
import 'package:genchatapp/app/data/repositories/select_contacts/select_contact_repository.dart';
import 'package:genchatapp/app/routes/app_pages.dart';
import 'package:get/get.dart';

class SearchNewContactController extends GetxController {
  //

  final IContactRepository contactRepository = Get.find<IContactRepository>();

  final RxList<UserList> _contactsNew = <UserList>[].obs;
  List<UserList> get contactsNew => _contactsNew;
  set contactsNew(List<UserList> value) => _contactsNew.assignAll(value);

  final RxString _searchNewQuery = ''.obs;
  String get searchNewQuery => _searchNewQuery.value;
  set searchNewQuery(String value) => _searchNewQuery.value = value;

  List<UserList> get searchNewContacts {
    if (searchNewQuery.isEmpty) return contactsNew;
    return contactsNew.where((contact) {
      final name = contact.localName?.toLowerCase() ?? '';
      final number = contact.phoneNumber ?? '';
      return name.contains(searchNewQuery.toLowerCase()) ||
          number.contains(searchNewQuery);
    }).toList();
  }

  final RxList<UserList> filteredContacts = <UserList>[].obs;

  @override
  void onInit() {
    super.onInit();
    filteredContacts.value = Get.arguments as List<UserList>;
    // print(filteredContacts.value);
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
    _contactsNew.clear();
    _searchNewQuery.close();
    searchNewContacts.clear();
  }

  void selectContact(UserList user) {
    Get.toNamed(Routes.SINGLE_CHAT, arguments: user);
  }

  Future<void> seachNewContactsWithServer() async {
    try {
      if (await FlutterContacts.requestPermission()) {
        final serverUsers =
            await contactRepository.fetchAppUsersFromContacts([searchNewQuery]);

        final enrichedUsers = serverUsers.map((user) {
          final userNumber = user.phoneNumber
              ?.replaceAll(RegExp(r'[\s\-\(\)]'), '')
              .replaceAll(RegExp(r'^\+91'), '')
              .replaceAll(RegExp(r'^0'), '');

          // final localName = localContactMap[userNumber ?? ''] ??
          //     ''; // leave empty if not found

          return user.copyWith(
              localName: user.phoneNumber); // only assign localName
        }).toList();

        contactsNew = enrichedUsers;
      }
    } catch (e) {
      // debugPrint('Error syncing contacts: $e');
    }
  }
}
