import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:genchatapp/app/modules/singleChat/controllers/single_chat_controller.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';

import '../../../constants/colors.dart';
import '../../../constants/message_enum.dart';
import '../../../utils/utils.dart';
import '../Controllers/DocumentsController.dart';

class DocumentPickerScreen extends StatelessWidget {
  final Function(List<File>) onSend;

  // SingleChatController singleChatController = Get.find<SingleChatController>();
  final dynamic chatController;

  DocumentPickerScreen({
    super.key,
    required this.onSend,
    required this.chatController,
  });

  Icon _fileIcon(String ext) {
    switch (ext) {
      case 'pdf':
        return const Icon(Icons.picture_as_pdf, color: Colors.red, size: 32);
      case 'doc':
      case 'docx':
        return const Icon(Icons.description, color: Colors.blue, size: 32);
      case 'xls':
      case 'xlsx':
        return const Icon(Icons.table_chart, color: Colors.green, size: 32);
      case 'ppt':
      case 'pptx':
        return const Icon(Icons.slideshow, color: Colors.orange, size: 32);
      default:
        return const Icon(Icons.insert_drive_file, size: 32);
    }
  }

  Future<List<File>> pickDocuments() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: true,
      allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'txt', 'ppt'],
    );

    if (result == null || result.files.isEmpty) return [];

    return result.paths.whereType<String>().map((path) => File(path)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DocumentPickerController>();
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [Text("Select Documents", style: TextStyle(fontSize: 15))],
        ),
        leading: const BackButton(color: Colors.black),
        actions: [
          TextButton(
            onPressed: () async {
              final picked = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowMultiple: true,
                allowedExtensions: [
                  'pdf',
                  'doc',
                  'docx',
                  'xls',
                  'xlsx',
                  'txt',
                  'ppt',
                ],
              );

              if (picked == null || picked.files.isEmpty) {
                return;
              }
              final docs = picked.paths.whereType<String>().map((e) {
                return File(e);
              }).toList();
              for (final file in docs) {
                final type = getMessageType(file);
                try {
                  await chatController.sendFileMessage(
                    file: file,
                    messageEnum: type,
                  );
                } catch (e, s) {
                  // debugPrint(s.toString());
                }
              }

              Navigator.pop(context);
              chatController.cancelReply();
            },
            child: const Text(
              "Browse Documents",
              style: TextStyle(
                color: Colors.blue,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),

      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.files.isEmpty) {
          return const Center(child: Text("No documents found"));
        }

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: GridView.builder(
            itemCount: controller.files.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 10,
              childAspectRatio: 0.75,
            ),
            itemBuilder: (_, index) {
              final path = controller.files[index];
              final name = path.split('/').last;
              final ext = name.split('.').last.toLowerCase();
              final isSelected = controller.selected.contains(path);

              return Obx(() {
                final isSelected = controller.selected.contains(path);

                return GestureDetector(
                  onTap: () => controller.toggleSelection(path),
                  onLongPress: () => OpenFile.open(path),
                  child: Container(
                    key: ValueKey(path),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.blue.shade100
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.grey.shade400,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _fileIcon(ext),
                        const SizedBox(height: 8),
                        Text(
                          name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        if (isSelected)
                          const Icon(Icons.check_circle, color: Colors.blue),
                      ],
                    ),
                  ),
                );
              });
            },
          ),
        );
      }),

      floatingActionButton: Obx(() {
        if (controller.selected.isEmpty) return const SizedBox.shrink();

        return FloatingActionButton.extended(
          backgroundColor: textBarColor,
          icon: const Icon(Icons.send),
          label: Text("Send (${controller.selected.length})"),
          onPressed: () async {
            final selectedCount = controller.selected.length;

            if (selectedCount > 5) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("You can only send up to 5 documents."),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            // SHOW CONFIRMATION DIALOG
            // bool confirm = await showDialog(
            //   context: context,
            //   builder: (_) {
            //     return AlertDialog(
            //       title: const Text("Confirm Share"),
            //       content: Text("$selectedCount file(s) will be shared."),
            //       actions: [
            //         TextButton(
            //           onPressed: () => Navigator.pop(context, false),
            //           child: const Text("Cancel"),
            //         ),
            //         ElevatedButton(
            //           onPressed: () async {
            //             singleChatController.cancelReply();
            //
            //             Navigator.pop(context, true);
            //           },
            //           style: ElevatedButton.styleFrom(
            //             backgroundColor: Colors.teal,
            //             foregroundColor: Colors.white,
            //             shape: RoundedRectangleBorder(
            //               borderRadius: BorderRadius.circular(8),
            //             ),
            //             padding: const EdgeInsets.symmetric(
            //               horizontal: 18,
            //               vertical: 12,
            //             ),
            //           ),
            //           child: const Text(
            //             "Send",
            //             style: TextStyle(
            //               fontSize: 14,
            //               fontWeight: FontWeight.w600,
            //             ),
            //           ),
            //         ),
            //       ],
            //     );
            //   },
            // );

            // if (confirm != true) return;

            // PROCEED IF USER CONFIRMS
            final files = controller.selected
                .map((path) => File(path))
                .toList();

            try {
              for (final f in files) {
                await chatController.sendFileMessage(
                  file: f,
                  messageEnum: getMessageType(f),
                );
              }
              chatController.cancelReply();
              Get.back();
            } catch (e, s) {
            }
          },
        );
      }),
    );
  }
}
