import 'package:flutter/material.dart';
import 'package:genchatapp/app/routes/app_pages.dart';

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
        iconTheme: const IconThemeData(color: Colors.white),
        title: ListTile(
          title: const Text(
            'Select contact',
            style: TextStyle(
              fontSize: 18,
              color: whiteColor,
              fontWeight: FontWeight.w400,
            ),
          ),
          subtitle: Obx(() => controller.contacts.isNotEmpty
              ? Text('${controller.contacts.length} contacts',
                  style: const TextStyle(
                      fontWeight: FontWeight.w200,
                      color: whiteColor,
                      fontSize: 12))
              : const Text("0  contact",
                  style: TextStyle(
                      fontWeight: FontWeight.w200,
                      color: whiteColor,
                      fontSize: 12))),
          // trailing: ,
        ),
        actions: [
          // IconButton(
          //   onPressed: () {},
          //   icon: const Icon(
          //     Icons.search,
          //   ),
          // ),
          IconButton(
            onPressed: () {
              // controller.isContactRefreshed = false;
              controller.getContacts();
            },
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
        centerTitle: true,
      ),
      body: GradientContainer(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.start,
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Input
              TextFormField(
                onChanged: (v) {},
                decoration: InputDecoration(
                  isDense: true,
                  filled: true,
                  fillColor: whiteColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: textBarColor, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(
                      color: textBarColor,
                      width: 1,
                    ), // Border for enabled state
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(
                      color: textBarColor,
                      width: 2,
                    ), // Border for focused state
                  ),
                  hintText: 'Search',
                  hintStyle: const TextStyle(
                    color: greyColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w200,
                  ),
                ),
                keyboardType: TextInputType.text,
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: Obx(() => controller.contacts.isNotEmpty &&
                        controller.isContactRefreshed
                    ? ListView.builder(
                        itemCount: controller.contacts.length,
                        itemBuilder: (context, i) {
                          var contact = controller.contacts[i];
                          return InkWell(
                            onTap: () {
                              // controller.selectContact(contact, context);
                              Get.toNamed(Routes.SINGLE_CHAT, arguments: [
                                contact.user.uid,
                                contact.fullName
                              ]);
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: ListTile(
                                title: Text(
                                  contact.fullName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                                leading: contact.image == null
                                    ? const SizedBox()
                                    : CircleAvatar(
                                        backgroundImage:
                                            MemoryImage(contact.image!),
                                        radius: 30,
                                      ),
                                subtitle: Text(
                                  contact.contactNumber.isNotEmpty
                                      ? contact.contactNumber
                                      : '',
                                  style: const TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          );
                        })
                    : const Center(
                        child: CircularProgressIndicator(
                          color: textBarColor,
                        ),
                      )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
