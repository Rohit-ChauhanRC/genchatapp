import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../../../constants/colors.dart';
import '../../../data/local_database/status_table.dart';
import '../../../data/models/new_models/response_model/contact_response_model.dart';
import '../../../data/models/new_models/response_model/status_model.dart';
import '../../../data/models/status_model.dart';
import '../../../utils/TImeFormat.dart';
import '../controllers/updates_controller.dart';

class StatusView extends StatefulWidget {
  final UpdatesController controller;
  final Statusmodel? status;
  final List<Statusmodel> statusList;
  final int? startIndex;
  final bool isSelf;

  const StatusView({
    super.key,
    required this.controller,
    required this.statusList,
    this.status,
    this.startIndex,
    this.isSelf = false,
  });

  @override
  State<StatusView> createState() => _StatusViewState();
}

class _StatusViewState extends State<StatusView> {
  late UpdatesController controller;
  late Statusmodel status;
  late List<Statusmodel> statusList;
  late bool isSelf;

  int currentStatusIndex = 0;
  int index = 0;

  VideoPlayerController? _videoController;
  StreamSubscription? _videoListener;
  bool isVideo = false;

  final Map<int, Color> colors = {
    0: Colors.black,
    1: Colors.blue,
    2: Colors.green,
    3: Colors.purple,
    4: Colors.orange,
    5: Colors.red,
    6: Colors.teal,
    7: Colors.pink,
  };

  @override
  void initState() {
    super.initState();
    controller = widget.controller;
    statusList = widget.statusList;

    currentStatusIndex = widget.startIndex ?? 0;
    status = statusList[currentStatusIndex];
    isSelf = widget.isSelf;

    _loadMedia();
  }

  Future<void> _loadMedia() async {
    print(
      "Loading media for statusIndex=$currentStatusIndex, mediaIndex=$index",
    );

    // Reset previous controller
    _videoListener?.cancel();
    _videoController?.removeListener(_onVideoTick);
    _videoController?.pause();
    await _videoController?.dispose();
    _videoController = null;

    controller.stopProgress();

    // SAFETY
    if (status.media.isEmpty) {
      print(" ERROR: media list empty for this status");
      return;
    }

    final media = status.media[index];
    final type = media["type"];
    final localPath = media["localPath"];
    final url = media["url"];

    if (type == "text") {
      controller.startProgress(durationSeconds: 5, onFinish: _next);
      setState(() {});
      return;
    }

    //--------------------------------------------------
    //                IMAGE STATUS
    //--------------------------------------------------
    if (type == "image") {
      try {
        if (localPath != null && localPath.toString().isNotEmpty) {
          media["_displayImage"] = localPath;
        } else {
          final file = await DefaultCacheManager().getSingleFile(url);
          media["_displayImage"] = file.path;
        }
      } catch (e) {
        media["_displayImage"] = url; // fallback network
      }

      controller.startProgress(durationSeconds: 5, onFinish: _next);
      setState(() {});
      return;
    }

    //--------------------------------------------------
    //                VIDEO STATUS
    //--------------------------------------------------
    if (type == "video") {
      File? videoFile;

      try {
        if (localPath != null && localPath.toString().isNotEmpty) {
          videoFile = File(localPath);
        } else {
          videoFile = await DefaultCacheManager().getSingleFile(url);
        }
      } catch (e) {
        return;
      }

      try {
        _videoController = VideoPlayerController.file(videoFile!)
          ..initialize().then((_) {
            setState(() {});
            _videoController!.play();

            _videoListener = Stream.periodic(
              const Duration(milliseconds: 100),
            ).listen((_) => _onVideoTick());
          });
      } catch (e) {}

      return;
    }

    print("Unknown media type: $type");
  }

  void _onVideoTick() {
    if (_videoController == null || !_videoController!.value.isInitialized)
      return;

    final pos = _videoController!.value.position;
    final dur = _videoController!.value.duration;

    controller.setProgress(pos.inMilliseconds / dur.inMilliseconds);

    if (pos >= dur) {
      _next();
    }
  }

  void _next() {
    if (index < status.media.length - 1) {
      index++;
    } else if (currentStatusIndex < statusList.length - 1) {
      currentStatusIndex++;
      index = 0;
      status = statusList[currentStatusIndex];
    } else {
      Get.back();
      return;
    }
    _loadMedia();
    setState(() {});
  }

  void _previous() {
    controller.stopProgress();
    _videoController?.pause();

    // Case 1: Move to previous media in same status
    if (index > 0) {
      index--;
    }

    // Case 2: Move to previous status
    else if (currentStatusIndex > 0) {
      currentStatusIndex--;
      status = statusList[currentStatusIndex];
      index = status.media.length - 1; // last media of previous status
    }

    else {
      Get.back();
      return;
    }

    setState(() {});
    _loadMedia();
  }

  void _onTapTap(TapUpDetails details) {
    final width = MediaQuery.of(context).size.width;
    if (details.globalPosition.dx < width / 3) {
      _previous();
    } else {
      _next();
    }
  }

  @override
  void dispose() {
    _videoListener?.cancel();
    _videoController?.removeListener(_onVideoTick);
    _videoController?.dispose();
    controller.stopProgress();
    super.dispose();
  }

  @override
  //   @override
  Widget build(BuildContext context) {
    final userData = UserList(
      displayPictureUrl: controller.senderuserData!.displayPictureUrl,

      countryCode: controller.senderuserData!.countryCode,
      displayPicture: controller.senderuserData!.displayPicture,
      email: controller.senderuserData!.email,

      localName: controller.senderuserData!.name,
      name: controller.senderuserData!.name,
      phoneNumber: controller.senderuserData!.phoneNumber,
      userId: controller.senderuserData!.userId,
    );
    final media = status.media[index];
    UserList? user = isSelf
        ? userData
        : controller.contacts.firstWhereOrNull(
            (contact) => contact.userId == status.userId,
          );

    // final media = status.media[index];
    final type = media['type'];

    final text = media['text'] ?? '';
    List<String> parts = [];
    String number = "";
    String text1 = "";
    Color bgColor = textBarColor;

    // Color parseColor(String hex) {
    //   return Color(int.parse(hex.replaceFirst('#', '0xff')));
    // }
    if (text.toString().isNotEmpty) {
      parts = text.split('-');
      number = parts[0]; // "0"
      text1 = parts[1];
      bgColor = colors[int.parse(number)]!;
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapUp: (details) => _onTapTap(details),
      onLongPress: () {
        controller.stopProgress();
        _videoController?.pause();
      },
      onLongPressUp: () {
        if (isVideo) {
          _videoController?.play();
        } else {
          controller.startProgress(durationSeconds: 5, onFinish: _next);
        }
      },
      child: Scaffold(
        backgroundColor: type == 'video' || type == 'image'
            ? textBarColor
            : bgColor,

        body: Stack(
          children: [
            Positioned.fill(
              child: Builder(
                builder: (_) {
                  if (type == 'video') {
                    return (_videoController != null &&
                            _videoController!.value.isInitialized)
                        ? FittedBox(
                            fit: BoxFit.contain,
                            child: SizedBox(
                              width: _videoController!.value.size.width,
                              height: _videoController!.value.size.height,
                              child: VideoPlayer(_videoController!),
                            ),
                          )
                        : const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          );
                  } else if (type == 'image') {
                    final path =
                        media["_displayImage"] ??
                        media["localPath"] ??
                        media["url"];

                    if (path == null || path.toString().isEmpty) {
                      print(" ERROR: No valid image path found: $media");
                      return const Center(child: Text("Image unavailable"));
                    }

                    if (path.toString().startsWith("/")) {
                      return Padding(
                        padding: const EdgeInsets.only(
                          top: 100,
                        ), // keep space for name & time
                        child: Center(
                          child: Image.file(File(path), fit: BoxFit.contain),
                        ),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.only(top: 100),
                      child: Center(
                        child: Image.network(path, fit: BoxFit.contain),
                      ),
                    );
                  } else if (type == 'text') {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),

                      child: Center(
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {},
                          child: SizedBox(
                            width: double.infinity,
                            child: Linkify(
                              text: text1,
                              textAlign: TextAlign.center,
                              onOpen: (link) async {
                                final uri = Uri.parse(link.url);
                                await launchUrl(
                                  uri,
                                  mode: LaunchMode.externalApplication,
                                );
                              },
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w600,
                                height: 1.4,
                              ),
                              linkStyle: const TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),

            // Progress bars for all statuses
            Positioned(
              top: 40,
              left: 10,
              right: 10,
              child: Obx(() {
                int totalStatusCount = 0;
                int currentStatusGlobalIndex = 0;

                // Find the current user's index and calculate total statuses
                for (var i = 0; i < statusList.length; i++) {
                  if (i < currentStatusIndex) {
                    currentStatusGlobalIndex += statusList[i].media.length;
                  } else if (i == currentStatusIndex) {
                    currentStatusGlobalIndex += index;
                  }
                  totalStatusCount += statusList[i].media.length;
                }

                return Row(
                  children: List.generate(totalStatusCount, (i) {
                    bool isCurrent = i == currentStatusGlobalIndex;
                    bool isCompleted = i < currentStatusGlobalIndex;

                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 1.5),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: SizedBox(
                            height: 2.5,
                            child: LinearProgressIndicator(
                              value: isCurrent
                                  ? controller.progress.value
                                  : isCompleted
                                  ? 1.0
                                  : 0.0,
                              backgroundColor: Colors.white.withOpacity(0.3),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isCurrent
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                );
              }),
            ),

            // user info & back button
            Positioned(
              top: 55,
              right: 15,

              child: Row(
                children: [
                  if (widget.isSelf == true)
                    PopupMenuButton(
                      icon: const Icon(Icons.more_vert, color: whiteColor),
                      offset: const Offset(0, 40),
                      color: whiteColor,
                      onSelected: (value) async {
                        // Handle menu item selection
                        if (value == 1) {
                          await controller.deletStatus(status.id);
                          Get.back();
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 1,
                          child: Text(
                            "Delete",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: blackColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            Positioned(
              top: 55,
              left: 15,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    radius: 20,
                    backgroundImage:
                        (user?.displayPictureUrl != null &&
                            user!.displayPictureUrl!.isNotEmpty)
                        ? NetworkImage(user!.displayPictureUrl!)
                        : const AssetImage("assets/images/default_dp.png")
                              as ImageProvider,
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (user?.localName?.isNotEmpty ?? false)
                            ? user!.localName!
                            : (user?.phoneNumber ?? ''),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        formatStatusTime(context, status.createdAt),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// class StatusView extends StatefulWidget {
//   final UpdatesController controller;
//   final StatusModel status;
//   final List<StatusModel> statusList;
//   final int startIndex;
//   const StatusView({super.key, required this.controller,required this.statusList, required this.status,required this.startIndex});
//
//   @override
//   State<StatusView> createState() => _StatusViewState();
// }
//
// class _StatusViewState extends State<StatusView> {
//   late UpdatesController controller;
//   late StatusModel status;
//  int currentStatusIndex=0;
//   int index = 0;
//    List<StatusModel> statusList=[];
//   VideoPlayerController? _videoController;
//   bool isVideo = false;
//   StreamSubscription? _videoListener;
//
//   @override
//   void initState() {
//     super.initState();
//     controller = widget.controller;
//     status = widget.status;
//     status = statusList[currentStatusIndex+1];
//     _loadMedia(); // load first media
//   }
//
//   Future<void> _loadMedia() async {
//     // Clean up any previous video controller
//     _videoListener?.cancel();
//     _videoController?.removeListener(_onVideoTick);
//     _videoController?.pause();
//     await _videoController?.dispose();
//     _videoController = null;
//     controller.stopProgress();
//
//     final media = status.media[index];
//     final type = media['type'];
//     isVideo = type == 'video';
//
//     if (type == 'video') {
//       // Initialize video player
//       _videoController = VideoPlayerController.network(media['url']!)
//         ..initialize().then((_) {
//           setState(() {}); // video initialized
//           _videoController?.play();
//           _videoController?.setLooping(false);
//
//           // drive progress by video duration
//           final duration = _videoController!.value.duration.inMilliseconds;
//           _videoListener = Stream.periodic(const Duration(milliseconds: 100))
//               .listen((_) => _onVideoTick());
//         }).catchError((e) {
//           _next(); // skip on error
//         });
//     }
//
//
//     else {
//       controller.startProgress(durationSeconds: 5, onFinish: _next);
//       setState(() {});
//     }
//   }
//
//   void _onVideoTick() {
//     if (_videoController == null || !_videoController!.value.isInitialized) return;
//     final pos = _videoController!.value.position;
//     final dur = _videoController!.value.duration;
//     if (dur.inMilliseconds == 0) return;
//     final p = pos.inMilliseconds / dur.inMilliseconds;
//     controller.setProgress(p);
//
//     if (p >= 1.0) {
//       _next();
//     }
//   }
//
//   @override
//   void dispose() {
//     _videoListener?.cancel();
//     _videoController?.removeListener(_onVideoTick);
//     _videoController?.dispose();
//     controller.stopProgress();
//     super.dispose();
//   }
//
//   void _next() {
//     status = statusList[currentStatusIndex];  // always sync
//
//     // Move to next media
//     if (index < status.media.length - 1) {
//       index++;
//     }
//
//     // Move to next user's status
//     else if (currentStatusIndex < statusList.length - 1) {
//       currentStatusIndex++;
//       index = 0;
//       status = statusList[currentStatusIndex];
//     }
//
//     // No more statuses -> exit
//     else {
//       Get.back();
//       return;
//     }
//
//     setState(() {});
//     _loadMedia();
//   }
//
//   void _previous() {
//     if (index > 0) {
//       setState(() => index--);
//       _loadMedia();
//     } else {
//       Get.back();
//     }
//   }
//
//   void _onTapDown(TapDownDetails details, BuildContext context) {
//     final width = MediaQuery.of(context).size.width;
//     final dx = details.globalPosition.dx;
//     if (dx < width / 3) {
//       _previous();
//     } else {
//       _next();
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final media = status.media[index];
//     return GestureDetector(
//       onTapDown: (details) => _onTapDown(details, context),
//       onLongPress: () {
//         controller.stopProgress();
//         _videoController?.pause();
//       },
//       onLongPressUp: () {
//         if (isVideo) {
//           _videoController?.play();
//         } else {
//           controller.startProgress(durationSeconds: 5, onFinish: _next);
//         }
//       },
//       child: Scaffold(
//         backgroundColor: Colors.black,
//         body: Stack(
//           children: [
//             Positioned.fill(
//               child: Builder(
//                 builder: (_) {
//                   final media = status.media[index];
//                   final type = media['type'];
//
//                   if (type == 'video') {
//                     return (_videoController != null && _videoController!.value.isInitialized)
//                         ? FittedBox(
//                       fit: BoxFit.cover,
//                       child: SizedBox(
//                         width: _videoController!.value.size.width,
//                         height: _videoController!.value.size.height,
//                         child: VideoPlayer(_videoController!),
//                       ),
//                     )
//                         : const Center(child: CircularProgressIndicator(color: Colors.white));
//                   }
//
//                   else if (type == 'image') {
//                     return Image.network(
//                       media['url']!,
//                       fit: BoxFit.cover,
//                       loadingBuilder: (context, child, progress) {
//                         if (progress == null) return child;
//                         return const Center(child: CircularProgressIndicator(color: Colors.white));
//                       },
//                     );
//                   }
//
//                   else if (type == 'text') {
//                     final bgColorHex = media['bgColor'] ?? '#000000';
//                     final textColorHex = media['textColor'] ?? '#FFFFFF';
//                     final text = media['text'] ?? '';
//
//                     Color parseColor(String hex) {
//                       return Color(int.parse(hex.replaceFirst('#', '0xff')));
//                     }
//
//                     return AnimatedContainer(
//                       duration: const Duration(milliseconds: 300),
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           colors: [parseColor(bgColorHex), Colors.black87],
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                         ),
//                       ),
//                       child: Center(
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 24.0),
//                           child: Text(
//                             text,
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                               color: parseColor(textColorHex),
//                               fontSize: 28,
//                               fontWeight: FontWeight.w600,
//                               height: 1.4,
//                             ),
//                           ),
//                         ),
//                       ),
//                     );
//                   }
//
//                   return const SizedBox();
//                 },
//               ),
//             ),
//
//             // progress bars
//             Positioned(
//               top: 40,
//               left: 10,
//               right: 10,
//               child: Obx(() {
//                 return Row(
//                   children: List.generate(status.media.length, (i) {
//                     return Expanded(
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 2),
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(8),
//                           child: LinearProgressIndicator(
//                             value: i < index ? 1 : i == index ? controller.progress.value : 0,
//                             color: Colors.white,
//                             backgroundColor: Colors.white24,
//                             minHeight: 3,
//                           ),
//                         ),
//                       ),
//                     );
//                   }),
//                 );
//               }),
//             ),
//
//             // user info & back button
//             Positioned(
//               top: 55,
//               left: 15,
//               child: Row(
//                 children: [
//                   GestureDetector(
//                     onTap: () => Navigator.pop(context),
//                     child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
//                   ),
//                   const SizedBox(width: 10),
//                   CircleAvatar(radius: 20, backgroundImage: NetworkImage(status.ProfilePic)),
//                   const SizedBox(width: 10),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(status.name,
//                           style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//                       Text(status.time,
//                           style: const TextStyle(color: Colors.white70, fontSize: 12)),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
