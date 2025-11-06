import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:genchatapp/app/constants/colors.dart';
import 'package:genchatapp/app/data/models/status_model.dart';
import 'package:genchatapp/app/modules/updates/controllers/updates_controller.dart';

class StatusView extends StatefulWidget {
  final UpdatesController controller;
  final StatusModel status;

  const StatusView({
    super.key,
    required this.controller,
    required this.status,
  });

  @override
  State<StatusView> createState() => _StatusViewState();
}

class _StatusViewState extends State<StatusView> {
  late UpdatesController controller;
  late StatusModel status;
   int index=0;
    Timer? timer;
  @override
  void initState() {
    super.initState();
    controller = widget.controller;
    status = widget.status;
    // controller.progress.value = 0;
    _startProgress();
  }
  @override
  void dispose() {
    timer?.cancel();
    controller.timer?.cancel();
    super.dispose();
  }

  void _startProgress() {
    controller.progress.value = 0;
    timer?.cancel();
    timer = Timer.periodic(const Duration(milliseconds: 50), (t) {
      controller.progress.value += 0.02; // 5 seconds total
      if (controller.progress.value >= 1) {
        t.cancel();
        _nextImage();
      }
    });
  }
  void _nextImage(){
    if(index<status.imageUrl.length-1){
      setState(() {
        index++;
      });
      _startProgress();


    }
    else{
      _nextImage();
    }

  }


  void previousImage(){
    if(index>0){
      setState(() {
        index--;
      });
    }
    _startProgress();

  }
  void _onTapDown(TapDownDetails details, BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final dx = details.globalPosition.dx;
    if (dx < width / 3) {
      // tap left → previous status
      // controller.skip(); // close or move to previous
      previousImage();
    } else {
      // tap right → next status
      // controller.skip(); // close or move to next
      _nextImage();

    }
  }

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTapDown: (details) => _onTapDown(details, context),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                status.imageUrl[index],
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                },
              ),
            ),

            Positioned(
              top: 40,
              left: 10,
              right: 10,
              child: Obx(() {
                return Row(
                  children: List.generate(status.imageUrl.length, (i) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: i < index
                                ? 1
                                : i == index
                                ? controller.progress.value
                                : 0,
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


            Positioned(
              top: 55,
              left: 15,
              child: Row(
                children: [
                  GestureDetector(
                    onTap:()=>Navigator.pop(context),
                    child: Icon(Icons.arrow_back,color: Colors.white,size: 25),
                  ),
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(status.ProfilePic),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        status.name,
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        status.time,
                        style: const TextStyle(color: Colors.white70, fontSize: 12),

                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 💬 Reply Box (Bottom)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black.withOpacity(0.5),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      Expanded(

                        child: TextFormField(
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Reply...',
                            hintStyle: const TextStyle(color: Colors.white54),
                            filled: true,
                            fillColor: Colors.white12,
                            border: OutlineInputBorder(

                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const CircleAvatar(

                        backgroundColor: Colors.white,
                        radius: 20,
                        child: Icon(Icons.send, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
