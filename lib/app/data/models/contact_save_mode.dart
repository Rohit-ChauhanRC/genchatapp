// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';

class ContactSaveModel extends Equatable {
  final String fullName;
  final String contactNumber;

  const ContactSaveModel({required this.fullName, required this.contactNumber});

  @override
  List<Object?> get props => [fullName, contactNumber];

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'fullName': fullName,
      'contactNumber': contactNumber,
    };
  }

  factory ContactSaveModel.fromMap(Map<String, dynamic> map) {
    return ContactSaveModel(
      fullName: map['fullName'] as String,
      contactNumber: map['contactNumber'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory ContactSaveModel.fromJson(String source) =>
      ContactSaveModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
