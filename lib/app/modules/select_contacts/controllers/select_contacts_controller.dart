import 'dart:io';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:genchatapp/app/config/services/socket_service.dart';
import 'package:genchatapp/app/data/local_database/chatconnect_table.dart';
import 'package:genchatapp/app/data/models/new_models/response_model/verify_otp_response_model.dart';
import 'package:genchatapp/app/routes/app_pages.dart';
import 'package:genchatapp/app/utils/alert_popup_utils.dart';

import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import '../../../config/services/connectivity_service.dart';
import '../../../data/local_database/contacts_table.dart';
import '../../../data/models/new_models/response_model/contact_response_model.dart';
import '../../../data/repositories/select_contacts/select_contact_repository.dart';

class SelectContactsController extends GetxController {
  final IContactRepository contactRepository = Get.find<IContactRepository>();
  final ContactsTable contactsTable = ContactsTable();
  final ChatConectTable chatConectTable = ChatConectTable();
  final ConnectivityService connectivityService =
      Get.find<ConnectivityService>();

  final socketService = Get.find<SocketService>();

  final RxBool _isContactRefreshed = true.obs;
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
    bindSocketEvents();
  }

  @override
  void onClose() {
    super.onClose();
    filteredContacts.clear();
    contacts.clear();
  }

  Future<void> loadInitialContacts() async {
    _isContactRefreshed.value = false;
    try {
      final localContacts = await contactsTable.fetchAll();
      print("local contacts number----> ${localContacts.isEmpty}");
      if (localContacts.isNotEmpty) {
        contacts = localContacts;
      } else {
        await refreshSync(); // First-time fetch from API
      }
    } catch (e) {
      print("❌ loadInitialContacts error: $e");
    } finally {
      _isContactRefreshed.value = true; // ✅ always end loading
    }
  }

  Future<void> refreshSync() async {
    if (connectivityService.isConnected.value == false) {
      showAlertMessage(
        "No Internet Connection!\nPlease check your connection and try again.",
      );
      return;
    }

    _isContactRefreshed.value = false;
    await syncContactsWithServer();
    _isContactRefreshed.value = true;
  }

  Future<void> syncContactsWithServer() async {
    try {
      if (await FlutterContacts.requestPermission()) {
        final phoneContacts = await FlutterContacts.getContacts(
          withProperties: true,
        );

        final Map<String, String> localContactMap = {};
        for (var contact in phoneContacts) {
          if (contact.phones.isNotEmpty) {
            // var rawNumber = '';
            for (var i in contact.phones) {
              final rawNumber = i.number;
              final sanitized = rawNumber
                  .replaceAll(RegExp(r'[\s\-\(\)]'), '')
                  .replaceAll(RegExp(r'^\+91'), '')
                  .replaceAll(RegExp(r'^0'), '');
              localContactMap[sanitized] = contact.displayName;
            }
            // final rawNumber = contact.phones.first.number;
          }
        }

        final phoneNumbers = localContactMap.keys.toList();
        final serverUsers = await contactRepository.fetchAppUsersFromContacts(
          phoneNumbers,
        );

        final enrichedUsers = serverUsers.map((user) {
          final userNumber = user.phoneNumber
              ?.replaceAll(RegExp(r'[\s\-\(\)]'), '')
              .replaceAll(RegExp(r'^\+91'), '')
              .replaceAll(RegExp(r'^0'), '');

          final localName =
              localContactMap[userNumber ?? ''] ??
              ''; // leave empty if not found

          return user.copyWith(localName: localName); // only assign localName
        }).toList();

        await contactsTable.createBulk(enrichedUsers);
        final updatedList = await contactsTable.fetchAll();
        for (var user in updatedList) {
          final isGroup = await chatConectTable.isGroupContact(
            user.userId.toString(),
          );
          if (!isGroup) {
            await chatConectTable.updateContact(
              uid: user.userId.toString(),
              profilePic: user.displayPictureUrl,
              name: user.localName == "" || user.localName == null
                  ? user.phoneNumber
                  : user.localName,
              isGroup: 0,
              isBlocked: user.isBlocked == true ? 1 : 0,
            );
            // Download and save profile image using the same name
            if (user.displayPictureUrl != null && user.displayPicture != null) {
              await _downloadAndCacheProfileImage(
                user.displayPictureUrl!,
                user.displayPicture!,
              );
            }
          }
        }
        contacts = enrichedUsers;
      }
    } catch (e) {
      // debugPrint('Error syncing contacts: $e');
    }
  }

  void selectContact(UserList user) {
    Get.toNamed(Routes.SINGLE_CHAT, arguments: user);
  }

  void bindSocketEvents() {
    ever<UserData?>(socketService.updateContactUser, (UserData? data) {
      if (data == null) return;

      final index = contacts.indexWhere((e) => e.userId == data.userId);
      if (index != -1) {
        // contacts[index] = data!; // Replace the whole object
        // OR update fields manually if needed:
        contacts[index].name = data.name;
        contacts[index].email = data.email;
        contacts[index].phoneNumber = data.phoneNumber;
        contacts[index].userDescription = data.userDescription;
        contacts[index].displayPicture = data.displayPicture;
        contacts[index].displayPictureUrl = data.displayPictureUrl;
        update();
        // Optionally trigger refresh if needed (depends on your list type)
        // contacts.refresh(); // Only needed if `contacts` is an RxList
      }
    });
  }

  Future<void> _downloadAndCacheProfileImage(
    String imageUrl,
    String fileName,
  ) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode != 200)
        throw Exception("Failed to download image");

      final imageBytes = response.bodyBytes;
      final originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) throw Exception("Image decode failed");

      // Crop to square
      final int size = originalImage.width < originalImage.height
          ? originalImage.width
          : originalImage.height;
      final square = img.copyCrop(
        originalImage,
        x: (originalImage.width - size) ~/ 2,
        y: (originalImage.height - size) ~/ 2,
        width: size,
        height: size,
      );

      // Create transparent circular image
      final circular = img.Image(width: size, height: size);
      circular.clear(img.ColorInt8.rgba(0, 0, 0, 0)); // fully transparent

      for (int y = 0; y < size; y++) {
        for (int x = 0; x < size; x++) {
          final dx = x - size ~/ 2;
          final dy = y - size ~/ 2;
          if (dx * dx + dy * dy <= (size ~/ 2) * (size ~/ 2)) {
            circular.setPixel(x, y, square.getPixel(x, y));
          }
        }
      }

      final directory = await getApplicationDocumentsDirectory();
      final pngFileName = fileName.replaceAll(
        RegExp(r'\.jpg$'),
        '.png',
      ); // ensure .png
      final filePath = '${directory.path}/$pngFileName';

      final file = File(filePath);
      await file.writeAsBytes(img.encodePng(circular));

      print("✅ Circular PNG with transparency saved: $filePath");
    } catch (e) {
      print("❌ Silent crop failed: $e");
    }
  }
}
