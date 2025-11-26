import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';

import '../Controllers/DocumentsController.dart';


class DocumentPickerScreen extends StatelessWidget {
  final Function(List<File>) onSend;

  DocumentPickerScreen({
    super.key,
    required this.onSend,
  });

  final controller = Get.put(DocumentPickerController());

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Documents"),
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
              final file = controller.files[index];
              final name = file.path.split('/').last;
              final ext = name.split('.').last.toLowerCase();
              final isSelected = controller.selected.contains(file);

              return GestureDetector(
                onTap: () => OpenFile.open(file.path),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.blue.shade50
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
                      Checkbox(
                        value: isSelected,
                        onChanged: (_) => controller.toggleSelection(file),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),

      floatingActionButton: Obx(() {
        if (controller.selected.isEmpty) return const SizedBox.shrink();

        return FloatingActionButton.extended(
          backgroundColor: Colors.blue,
          icon: const Icon(Icons.send),
          label: Text("Send (${controller.selected.length})"),
          onPressed: () {
            onSend(controller.selected.toList());
            Get.back();
          },
        );
      }),
    );
  }
}
