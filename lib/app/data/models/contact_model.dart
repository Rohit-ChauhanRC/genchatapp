import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:genchatapp/app/data/models/user_model.dart';

class ContactModel extends Equatable {
  final String fullName;
  final String contactNumber;
  final Uint8List? image;
  final UserModel user;

  const ContactModel({
    required this.fullName,
    required this.contactNumber,
    this.image,
    required this.user,
  });

  @override
  List<Object?> get props => [fullName, contactNumber, image, user];
}
