import 'dart:typed_data';

import 'package:genchatapp/app/data/models/user_model.dart';

class ContactModel {
  final String fullName;
  final String contactNumber;
  final Uint8List? image;
  final UserModel user;

  ContactModel({
    required this.fullName,
    required this.contactNumber,
    this.image,
    required this.user,
  });
}
