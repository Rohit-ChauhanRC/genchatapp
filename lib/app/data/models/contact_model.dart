
import 'dart:typed_data';

class ContactModel {
  final String fullName;
  final String contactNumber;
  final Uint8List? image;

  ContactModel({
    required this.fullName,
    required this.contactNumber,
    this.image,
  });
}