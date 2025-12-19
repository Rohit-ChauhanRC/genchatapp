// import 'package:flutter/material.dart';
// import 'package:genchatapp/app/constants/colors.dart';
// import 'package:genchatapp/app/constants/constants.dart';
// import 'package:genchatapp/app/constants/message_enum.dart';
// import 'package:genchatapp/app/data/models/new_models/response_model/new_message_model.dart';
// import 'package:genchatapp/app/modules/group_chats/controllers/group_chats_controller.dart';
// import 'package:genchatapp/app/modules/singleChat/widgets/audio_waveform_player_widget.dart';
// import 'package:genchatapp/app/modules/singleChat/widgets/display_gif_image.dart';
// import 'package:genchatapp/app/modules/singleChat/widgets/document_message_widget.dart';
// import 'package:genchatapp/app/modules/singleChat/widgets/image_widget.dart';
// import 'package:genchatapp/app/modules/singleChat/widgets/video_player_item.dart';
// import 'package:get/get.dart';

// class MessageInfo extends StatefulWidget {
//   MessageInfo({
//     super.key,
//     required this.selectedMessages,
//     required this.groupChatsController,
//   });

//   NewMessageModel selectedMessages;

//   final GroupChatsController groupChatsController;

//   @override
//   State<MessageInfo> createState() => _MessageInfoState();
// }

// class _MessageInfoState extends State<MessageInfo> {
//   String path = '';

//   @override
//   void initState() async {
//     super.initState();
//     await widget.groupChatsController.getMessageInfoApi(
//       widget.selectedMessages.messageId!,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           messageInfo,
//           style: TextStyle(
//             fontSize: 20,
//             color: whiteColor,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         iconTheme: const IconThemeData(color: Colors.white),
//         // automaticallyImplyLeading: false,
//         centerTitle: false,
//         backgroundColor: textBarColor,
//       ),
//       body: ListView(
//         children: [
//           if (widget.selectedMessages.messageType == MessageType.image)
//             _imageWidget(path),
//           if (widget.selectedMessages.messageType == MessageType.video)
//             _videoWidget(path, thumbnailPath),

//           if (widget.selectedMessages.messageType == MessageType.text)
//             _textWidget(
//               widget.groupChatsController.encryptionService.decryptText(
//                 widget.selectedMessages.message.toString(),
//               ),
//             ),

//           if (widget.selectedMessages.messageType == MessageType.document)
//             _docWidget(path, widget.selectedMessages.assetUrl),

//           if (widget.selectedMessages.messageType == MessageType.gif)
//             _gifWidget(gifPath),

//           if (widget.selectedMessages.messageType == MessageType.audio)
//             _audioWidget(audioPath, widget.selectedMessages.assetServerName!),

//           _sectionTitle("Read by"),

//           // ...controller.readList.map(_memberTile),
//           Divider(),

//           _sectionTitle("Delivered to"),
//           // ...controller.deliveredList.map(_memberTile),
//         ],
//       ),
//     );
//   }

//   Widget _sectionTitle(String title) {
//     return Padding(
//       padding: const EdgeInsets.all(12.0),
//       child: Text(
//         title,
//         style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//       ),
//     );
//   }

//   // Widget _memberTile(MemberStatus member) {
//   Widget _imageWidget(String imagePath) {
//     return ImageWidget(rootFolderPath: imagePath, url: '', isReply: false);
//   }

//   Widget _videoWidget(String imagePath, String thumbnailPath) {
//     return VideoPlayerItem(
//       videoUrl: imagePath,
//       url: '',
//       isReply: false,
//       localFilePath: thumbnailPath,
//     );
//   }

//   Widget _textWidget(String title) {
//     return Padding(
//       padding: const EdgeInsets.all(12.0),
//       child: Text(
//         title,
//         style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//       ),
//     );
//   }

//   Widget _docWidget(String path, String? url) {
//     return DocumentMessageWidget(
//       localFilePath: path,
//       url: url ?? '',
//       isReply: false,
//     );
//   }

//   Widget _gifWidget(String gifPath) {
//     return DisplayGifImage(filePath: gifPath, isReply: false);
//   }

//   Widget _audioWidget(String audioPath, String url) {
//     return Padding(
//       padding: const EdgeInsets.all(12.0),
//       child: AudioPlayerScreen(
//         audioPath: audioPath,
//         audioUrl: url,
//         isReply: false,
//         // message: audioMessage,
//       ),
//     );
//   }
// }
