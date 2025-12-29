import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

import '../../../data/models/new_models/response_model/contact_response_model.dart';
class SaveContactScreen extends StatelessWidget {
  final UserList user;
  final nameController =
  TextEditingController(text:  '');
  final phoneController =
  TextEditingController(text:  '');
  SaveContactScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(title: const Text("Save Contact")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: const InputDecoration(labelText: "Phone"),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                await FlutterContacts.requestPermission();
                final contact = Contact()
                  ..name.first = nameController.text
                  ..phones = [Phone(phoneController.text)];
                await contact.insert();
                Navigator.pop(context, true);
              },
              child: const Text("Save"),
            )
          ],
        ),
      ),
    );
  }
}
