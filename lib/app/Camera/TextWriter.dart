import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TextStatusScreen extends StatefulWidget {
  const TextStatusScreen({super.key});

  @override
  State<TextStatusScreen> createState() => _TextStatusScreenState();
}

class _TextStatusScreenState extends State<TextStatusScreen> {
  final TextEditingController _textController = TextEditingController();
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
              child: GestureDetector(
                onTap: () {
                  if (_textController.text.trim().isNotEmpty) {
                    Get.back(result: {
                      "text": _textController.text.trim(),
                      "color": _backgroundColor,
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please type something")),
                    );
                  }
                },
                child: const Icon(Icons.check, color: Colors.white, size: 28),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
