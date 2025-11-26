import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';

// class DocumentPickerScreen extends StatefulWidget {
//   final List<File> files;
//   final Function(List<File>) onSend;
//
//   const DocumentPickerScreen({
//     super.key,
//     required this.files,
//     required this.onSend,
//   });
//
//   @override
//   State<DocumentPickerScreen> createState() => _DocumentPickerScreenState();
// }
//
// class _DocumentPickerScreenState extends State<DocumentPickerScreen> {
//   List<File> selected = [];
//
//   Icon _fileIcon(String ext) {
//     switch (ext) {
//       case 'pdf':
//         return const Icon(Icons.picture_as_pdf, color: Colors.red, size: 32);
//       case 'doc':
//       case 'docx':
//         return const Icon(Icons.description, color: Colors.blue, size: 32);
//       case 'xls':
//       case 'xlsx':
//         return const Icon(Icons.table_chart, color: Colors.green, size: 32);
//       case 'ppt':
//       case 'pptx':
//         return const Icon(Icons.slideshow, color: Colors.orange, size: 32);
//       default:
//         return const Icon(Icons.insert_drive_file, size: 32);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final files = widget.files;
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Select Documents"),
//         actions: [
//           if (selected.isNotEmpty)
//             TextButton(
//               onPressed: () {
//                 widget.onSend(selected);
//                 Navigator.pop(context);
//               },
//               child: const Text("SEND", style: TextStyle(color: Colors.white)),
//             ),
//         ],
//       ),
//         body: files.isEmpty
//             ? const Center(child: Text("No documents found"))
//             : Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: GridView.builder(
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 3,        // 3 per row
//               crossAxisSpacing: 10,
//               mainAxisSpacing: 10,
//               childAspectRatio: 0.75,   // adjust shape
//             ),
//             itemCount: files.length,
//             itemBuilder: (context, index) {
//               final file = files[index];
//               final name = file.path.split('/').last;
//               final ext = name.split('.').last.toLowerCase();
//
//               return GestureDetector(
//                 onTap: () => OpenFile.open(file.path), // preview
//                 child: Container(
//                   padding: const EdgeInsets.all(10),
//                   decoration: BoxDecoration(
//                     color: selected.contains(file)
//                         ? Colors.blue.shade50
//                         : Colors.grey.shade100,
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(
//                       color: selected.contains(file)
//                           ? Colors.blue
//                           : Colors.grey.shade400,
//                       width: selected.contains(file) ? 2 : 1,
//                     ),
//                   ),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       _fileIcon(ext),
//                       const SizedBox(height: 8),
//                       Text(
//                         name,
//                         textAlign: TextAlign.center,
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                         style: const TextStyle(fontSize: 12),
//                       ),
//                       const SizedBox(height: 8),
//                       Checkbox(
//                         value: selected.contains(file),
//                         onChanged: (_) {
//                           setState(() {
//                             selected.contains(file)
//                                 ? selected.remove(file)
//                                 : selected.add(file);
//                           });
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//
//     );
//   }
// }
