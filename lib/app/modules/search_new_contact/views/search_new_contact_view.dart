import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genchatapp/app/common/widgets/gradient_container.dart';
import 'package:genchatapp/app/constants/colors.dart';

import 'package:get/get.dart';

import '../../../config/theme/app_colors.dart';
import '../controllers/search_new_contact_controller.dart';

class SearchNewContactView extends GetView<SearchNewContactController> {
  const SearchNewContactView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: textBarColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const ListTile(
          title: Text(
            'Search contact',
            style: TextStyle(
              fontSize: 18,
              color: whiteColor,
              fontWeight: FontWeight.w400,
            ),
          ),

          // trailing: ,
        ),
        centerTitle: true,
      ),
      body: GradientContainer(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Column(
            children: [
              // Search Input
              TextFormField(
                controller: controller.searchTextController,
                onChanged: (value) async {
                  if (value.length == 10) {
                    controller.searchNewQuery = value;
                    await controller.searchNewContactsWithServer();
                  }
                },
                inputFormatters: [
                  LengthLimitingTextInputFormatter(10),
                  FilteringTextInputFormatter.digitsOnly
                ],
                decoration: const InputDecoration(
                  isDense: true,
                  filled: true,
                  // fillColor: whiteColor,
                  hintText: 'Search without country code',
                  hintStyle: TextStyle(
                    color: greyColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w200,
                  ),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(
                height: 10,
              ),

              Expanded(
                child: Obx(() {
                  var filteredContacts = controller.searchNewContacts;
                  if (filteredContacts.isEmpty) {
                    return Center(
                      child: controller.searchTextController.text.isEmpty ?
                      Text("Please enter number for search new contact.") :
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:[
                          Text("${controller.searchNewQuery} user is not associated with GenChat."),
                          SizedBox(height: 5,),
                          Text("Please click here to share a app link.",
                            // style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          ElevatedButton(
                              onPressed: (){},
                              child: Text("Send Link", style: TextStyle(color: AppColors.whiteColor),)
                          )

                      ]),
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
