import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:genchatapp/app/routes/app_pages.dart';

import 'package:get/get.dart';

import '../../../data/models/new_models/response_model/contact_response_model.dart';
import '../../../data/repositories/select_contacts/select_contact_repository.dart';


class SelectContactsController extends GetxController {
  final IContactRepository contactRepository = Get.find<IContactRepository>();


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
      final name = contact.name?.toLowerCase() ?? '';
      final number = contact.phoneNumber ?? '';
      return name.contains(searchQuery.toLowerCase()) || number.contains(searchQuery);
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    refreshSync();
  }

  Future<void> refreshSync() async {
    _isContactRefreshed.value = false;
    await syncContactsWithServer();
    _isContactRefreshed.value = true;
  }

  Future<void> syncContactsWithServer() async {
    try {
      if (await FlutterContacts.requestPermission()) {
        final phoneContacts = await FlutterContacts.getContacts(withProperties: true);

        // Create a map of phoneNumber => displayName from local contacts
        final Map<String, String> localContactMap = {};
        for (var contact in phoneContacts) {
          if (contact.phones.isNotEmpty) {
            final rawNumber = contact.phones.first.number;
            final sanitizedNumber = rawNumber
                .replaceAll(RegExp(r'[\s\-\(\)]'), '')
                .replaceAll('+91', ''); // Normalize
            localContactMap[sanitizedNumber] = contact.displayName;
          }
        }

        final phoneNumbers = localContactMap.keys.toList();

        // Fetch registered users from API
        final serverUsers = await contactRepository.fetchAppUsersFromContacts(phoneNumbers);

        // Assign local name to each registered user
        final List<UserList> enrichedUsers = serverUsers.map((user) {
          final number = user.phoneNumber?.replaceAll('+91', '') ?? '';
          final localName = localContactMap[number] ?? user.name ?? 'Unknown';
          return user.copyWith(name: localName);
        }).toList();

        contacts = enrichedUsers;
      }
    } catch (e) {
      debugPrint('Error fetching contacts: $e');
    }
  }

  void selectContact(UserList user) {
    // Navigate to chat or do any action with selected contact
    Get.toNamed(Routes.SINGLE_CHAT, arguments: user); // Adjust route as needed
  }


}

