import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:genchatapp/app/routes/app_pages.dart';
import 'package:genchatapp/app/utils/alert_popup_utils.dart';

import 'package:get/get.dart';

import '../../../config/services/connectivity_service.dart';
import '../../../data/local_database/contacts_table.dart';
import '../../../data/models/new_models/response_model/contact_response_model.dart';
import '../../../data/repositories/select_contacts/select_contact_repository.dart';

class SelectContactsController extends GetxController {
  final IContactRepository contactRepository = Get.find<IContactRepository>();
  final ContactsTable contactsTable = ContactsTable();
  final ConnectivityService connectivityService =
      Get.find<ConnectivityService>();

  final RxBool _isContactRefreshed = false.obs;
  bool get isContactRefreshed => _isContactRefreshed.value;
  set isContactRefreshed(bool v) => _isContactRefreshed.value = v;

  final RxList<UserList> _contacts = <UserList>[].obs;
  List<UserList> get contacts => _contacts;
  set contacts(List<UserList> value) => _contacts.assignAll(value);

  final RxString _searchQuery = ''.obs;
  String get searchQuery => _searchQuery.value;
  set searchQuery(String value) => _searchQuery.value = value;

  List<UserList> get filteredContacts {
    if (searchQuery.isEmpty) return contacts;
    return contacts.where((contact) {
      final name = contact.localName?.toLowerCase() ?? '';
      final number = contact.phoneNumber ?? '';
      return name.contains(searchQuery.toLowerCase()) ||
          number.contains(searchQuery);
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    // contactsTable.deleteTable();
    loadInitialContacts();
  }

  Future<void> loadInitialContacts() async {
    final localContacts = await contactsTable.fetchAll();
    if (localContacts.isNotEmpty) {
      contacts = localContacts;
      _isContactRefreshed.value = true;
    } else {
      await refreshSync(); // First-time fetch from API
    }
  }

  Future<void> refreshSync() async {
    if (!connectivityService.isConnected.value) {
      showAlertMessage(
          "No Internet Connection!\nPlease check your connection and try again.");
      return;
    }

    _isContactRefreshed.value = false;
    await syncContactsWithServer();
    _isContactRefreshed.value = true;
  }

  Future<void> syncContactsWithServer() async {
    try {
      if (await FlutterContacts.requestPermission()) {
        final phoneContacts =
            await FlutterContacts.getContacts(withProperties: true);

        final Map<String, String> localContactMap = {};
        for (var contact in phoneContacts) {
          if (contact.phones.isNotEmpty) {
            final rawNumber = contact.phones.first.number;
            final sanitized = rawNumber
                .replaceAll(RegExp(r'[\s\-\(\)]'), '')
                .replaceAll(RegExp(r'^\+91'), '')
                .replaceAll(RegExp(r'^0'), '');
            localContactMap[sanitized] = contact.displayName;
          }
        }

        final phoneNumbers = localContactMap.keys.toList();
        final serverUsers =
            await contactRepository.fetchAppUsersFromContacts(phoneNumbers);

        final enrichedUsers = serverUsers.map((user) {
          final userNumber = user.phoneNumber
              ?.replaceAll(RegExp(r'[\s\-\(\)]'), '')
              .replaceAll(RegExp(r'^\+91'), '')
              .replaceAll(RegExp(r'^0'), '');

          final localName = localContactMap[userNumber ?? ''] ??
              ''; // leave empty if not found

          return user.copyWith(localName: localName); // only assign localName
        }).toList();

        await contactsTable.createBulk(enrichedUsers);
        contacts = enrichedUsers;
      }
    } catch (e) {
      // debugPrint('Error syncing contacts: $e');
    }
  }

  void selectContact(UserList user) {
    Get.toNamed(Routes.SINGLE_CHAT, arguments: user);
  }
}
