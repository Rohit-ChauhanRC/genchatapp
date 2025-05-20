// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';

class ContactModel extends Equatable {
  final String fullName;
  final String contactNumber;
  final String image;
  final String userId;

  const ContactModel({
    required this.fullName,
    required this.contactNumber,
   required this.image,
    required this.userId,
  });

  @override
  List<Object?> get props => [fullName, contactNumber, image, userId];

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'fullName': fullName,
      'contactNumber': contactNumber,
      'image': image,
      'uid': userId,
    };
  }

  factory ContactModel.fromMap(Map<String, dynamic> map) {
    return ContactModel(
      fullName: map['fullName'] as String,
      contactNumber: map['contactNumber'] as String,
      image: map['image'] ,
      userId: map['uid'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory ContactModel.fromJson(String source) => ContactModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
