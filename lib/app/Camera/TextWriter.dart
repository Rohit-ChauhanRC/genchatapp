import 'package:flutter/material.dart';
import 'package:genchatapp/app/data/repositories/status/status_repository.dart';
import 'package:genchatapp/app/modules/updates/controllers/updates_controller.dart';
import 'package:get/get.dart';

class TextStatusScreen extends StatefulWidget {
  TextStatusScreen({super.key, required this.statusRepository});

  final StatusRepository statusRepository;

  final UpdatesController updatesController = Get.find();

  @override
  State<TextStatusScreen> createState() => _TextStatusScreenState();
}

class _TextStatusScreenState extends State<TextStatusScreen> {
  final TextEditingController _textController = TextEditingController();
  final RxBool isUploading = false.obs;

  Color _backgroundColor = Colors.black;
  final Map<int, Color> _colors = {
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _textController,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: null,
                  decoration: const InputDecoration(
                    // border: InputBorder.none,
                    hintText: "Type a status...",
                    hintStyle: TextStyle(color: Colors.white54, fontSize: 20),
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _colors.length,
                  itemBuilder: (context, index) {
                    final color = _colors[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _backgroundColor = color!;
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Done button (top-right)
            Positioned(
              top: 16,
              right: 16,
              child: Obx(() {
                return GestureDetector(
                  onTap: isUploading.value
                      ? null // 🚫 block multiple taps
                      : () async {
                          int? key = _colors.entries
                              .firstWhere(
                                (entry) => entry.value == _backgroundColor,
                                orElse: () =>
                                    const MapEntry(-1, Colors.transparent),
                              )
                              .key;

                          if (_textController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please type something"),
                              ),
                            );
                            return;
                          }

                          isUploading.value = true;

                          try {
                            final uploadResponse = await widget.statusRepository
                                .uploadStatus(
                                  imageFile: null,
                                  isAssets: false,
                                  onProgress: (int i, int j) {},
                                  text: "$key-${_textController.text.trim()}",
                                );

                            if (uploadResponse != null &&
                                uploadResponse.statusCode == 200) {
                              await widget.updatesController.getStatus();
                              Get.close(2);
                            }
                          } finally {
                            isUploading.value = false;
                          }
                        },
                  child: isUploading.value
                      ? const SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check, color: Colors.white, size: 28),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
