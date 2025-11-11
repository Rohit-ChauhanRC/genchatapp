import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../../../data/models/status_model.dart';
import '../controllers/updates_controller.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../../../data/models/status_model.dart';
import '../controllers/updates_controller.dart';

class StatusView extends StatefulWidget {
  final UpdatesController controller;
  final StatusModel status;
  final List<StatusModel> statusList;
  final int startIndex;

  const StatusView({
    super.key,
    required this.controller,
    required this.statusList,
    required this.status,
    required this.startIndex,
  });

  @override
  State<StatusView> createState() => _StatusViewState();
}

class _StatusViewState extends State<StatusView> {
  late UpdatesController controller;
  late StatusModel status;
  late List<StatusModel> statusList;

  int currentStatusIndex = 0;
  int index = 0;

  VideoPlayerController? _videoController;
  StreamSubscription? _videoListener;
  bool isVideo = false;

  @override

  void initState() {
    super.initState();

    controller = widget.controller;
    statusList = widget.statusList;
    currentStatusIndex = widget.startIndex;
    status = statusList[currentStatusIndex];


    _loadMedia();
  }

  Future<void> _loadMedia() async {
    _videoListener?.cancel();
    _videoController?.removeListener(_onVideoTick);
    _videoController?.pause();
    await _videoController?.dispose();
    _videoController = null;
    controller.stopProgress();

    final media = status.media[index];
    isVideo = media['type'] == 'video';

    if (isVideo) {
      _videoController = VideoPlayerController.network(media['url']!)
        ..initialize().then((_) {
          setState(() {});
          _videoController?.play();
          _videoController?.setLooping(false);

          _videoListener =
              Stream.periodic(const Duration(milliseconds: 100)).listen((_) {
                _onVideoTick();
              });
        }).catchError((_) => _next());
    } else {
      controller.startProgress(durationSeconds: 5, onFinish: _next);
      setState(() {});
    }
  }

  void _onVideoTick() {
    if (_videoController == null || !_videoController!.value.isInitialized) return;

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

    setState(() {});
    _loadMedia();
  }

  void _previous() {
    if (index > 0) {
      index--;
      setState(() {});
      _loadMedia();
    } else {
      Get.back();
    }
  }

  void _onTapDown(TapDownDetails details, BuildContext context) {
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
    final media = status.media[index];
    return GestureDetector(
      onTapDown: (details) => _onTapDown(details, context),
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
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Positioned.fill(
              child: Builder(
                builder: (_) {
                  final media = status.media[index];
                  final type = media['type'];

                  if (type == 'video') {
                    return (_videoController != null && _videoController!.value.isInitialized)
                        ? FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _videoController!.value.size.width,
                        height: _videoController!.value.size.height,
                        child: VideoPlayer(_videoController!),
                      ),
                    )
                        : const Center(child: CircularProgressIndicator(color: Colors.white));
                  }

                  else if (type == 'image') {
                    return Image.network(
                      media['url']!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const Center(child: CircularProgressIndicator(color: Colors.white));
                      },
                    );
                  }

                  else if (type == 'text') {
                    final bgColorHex = media['bgColor'] ?? '#000000';
                    final textColorHex = media['textColor'] ?? '#FFFFFF';
                    final text = media['text'] ?? '';

                    Color parseColor(String hex) {
                      return Color(int.parse(hex.replaceFirst('#', '0xff')));
                    }

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [parseColor(bgColorHex), Colors.black87],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Text(
                            text,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: parseColor(textColorHex),
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
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

            // progress bars
            Positioned(
              top: 40,
              left: 10,
              right: 10,
              child: Obx(() {
                return Row(
                  children: List.generate(status.media.length, (i) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: i < index ? 1 : i == index ? controller.progress.value : 0,
                            color: Colors.white,
                            backgroundColor: Colors.white24,
                            minHeight: 3,
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
              left: 15,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(radius: 20, backgroundImage: NetworkImage(status.ProfilePic)),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(status.name,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Text(status.time,
                          style: const TextStyle(color: Colors.white70, fontSize: 12)),
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
