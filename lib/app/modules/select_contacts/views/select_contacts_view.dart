import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:genchatapp/app/routes/app_pages.dart';
import 'package:get/get.dart';
import '../../../constants/colors.dart';
import 'package:genchatapp/app/common/widgets/gradient_container.dart';
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
          IconButton(
            onPressed: () async {
              await controller.refreshSync();
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
            children: [
              // Search Input
              TextFormField(
                onChanged: (value) => controller.searchQuery = value,
                decoration: const InputDecoration(
                  isDense: true,
                  filled: true,
                  // fillColor: whiteColor,
                  hintText: 'Search',
                  hintStyle: TextStyle(
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
              InkWell(
                onTap: () {
                  // controller.selectContact(contact);
                  Get.toNamed(Routes.SEARCH_NEW_CONTACT,
                      arguments: controller.filteredContacts);
                },
                child: Container(
                  // height: 50,
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: const ListTile(
                    title: Text(
                      "Search New Contact",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    leading: CircleAvatar(
                      child: Icon(Icons.search_rounded),
                      radius: 30,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: Obx(() {
                  if (!controller.isContactRefreshed) {
                    return const Center(
                      child: CircularProgressIndicator(color: textBarColor),
                    );
                  }
                  var filteredContacts = controller.filteredContacts;
                  if (filteredContacts.isEmpty) {
                    return const Center(
                      child: Text("No contacts found."),
                    );
                  }
                  return ListView.builder(
                      itemCount: filteredContacts.length,
                      itemBuilder: (context, i) {
                        var contact = filteredContacts[i];
                        return InkWell(
                          onTap: () {
                            controller.selectContact(contact);
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: ListTile(
                              title: Text(
                                contact.localName ?? "No Name",
                                style: const TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                              leading: contact.displayPictureUrl == null ||
                                      contact.displayPictureUrl == ""
                                  ? const CircleAvatar(
                                      child: Icon(Icons.person),
                                      radius: 30,
                                    )
                                  : CachedNetworkImage(
                                      imageUrl:
                                          contact.displayPictureUrl.toString(),
                                      imageBuilder: (context, imageProvider) =>
                                          CircleAvatar(
                                        backgroundImage: imageProvider,
                                        radius: 30,
                                      ),
                                      placeholder: (context, url) =>
                                          const CircleAvatar(
                                        radius: 30,
                                        child: CircularProgressIndicator(),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          const CircleAvatar(
                                        radius: 30,
                                        child: Icon(Icons.error),
                                      ),
                                    ),
                              subtitle: Text(
                                contact.phoneNumber ?? '',
                                style: const TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        );
                      });
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
