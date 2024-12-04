import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';

import 'package:get/get.dart';

import '../../../constants/colors.dart';
import '../../../widgets/gradientContainer.dart';
import '../controllers/select_contacts_controller.dart';

class SelectContactsView extends GetView<SelectContactsController> {
  const SelectContactsView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: textBarColor,
        iconTheme: IconThemeData(
            color: Colors.white
        ),
        title: ListTile(
          title: const Text('Select contact', style: TextStyle(
            fontSize: 18,
            color: whiteColor,
            fontWeight: FontWeight.w400,
          ),),
          subtitle: Obx(() => controller.contacts.isNotEmpty
              ? Text('${controller.contacts.length} contacts', style: TextStyle(fontWeight: FontWeight.w200, color: whiteColor, fontSize: 12))
              : const Text("0  contact", style: TextStyle(fontWeight: FontWeight.w200, color: whiteColor, fontSize: 12))),
          // trailing: ,
        ),
        // actions: [
        //   IconButton(
        //     onPressed: () {},
        //     icon: const Icon(
        //       Icons.search,
        //     ),
        //   ),
        //   IconButton(
        //     onPressed: () {},
        //     icon: const Icon(
        //       Icons.more_vert,
        //     ),
        //   ),
        // ],
        centerTitle: true,
      ),
      body: GradientContainer(
        child: Obx(() => controller.contacts.isNotEmpty
            ? ListView.builder(
            itemCount: controller.contacts.length,
            itemBuilder: (context, i) {
              Contact contact = controller.contacts[i];
              return InkWell(
                onTap: () {
                  controller.selectContact(contact, context);
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: ListTile(
                    title: Text(
                      contact.displayName,
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    leading: contact.photo == null
                        ? null
                        : CircleAvatar(
                      backgroundImage: MemoryImage(contact.photo!),
                      radius: 30,
                    ),
                    subtitle: Text(
                      contact.phones.isNotEmpty ? contact.phones[0].number : '',
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              );
            })
            : const SizedBox()),
      ),
    );
  }
}
