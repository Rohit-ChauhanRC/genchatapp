import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

void main() {
  runApp(MaterialApp(home: ChatScreen()));
}

class Message {
  final String id;
  final String text;

  Message({required this.id, required this.text});
}

class ChatScreen extends StatefulWidget {
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ItemScrollController _scrollController = ItemScrollController();
  final ItemPositionsListener _positionsListener = ItemPositionsListener.create();

  List<Message> messages = [];
  bool isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _loadInitialMessages();

    _positionsListener.itemPositions.addListener(() {
      final positions = _positionsListener.itemPositions.value;
      final maxVisibleIndex = positions.map((e) => e.index).fold(0, (prev, idx) => idx > prev ? idx : prev);
      if (maxVisibleIndex >= messages.length - 1 && !isLoadingMore) {
        _loadMoreMessagesPreservingScroll();
      }
    });
  }

  void _loadInitialMessages() {
    messages = List.generate(30, (i) => Message(id: 'msg_$i', text: 'Message ${i + 1}'));
    setState(() {});
  }

  Future<void> _loadMoreMessagesPreservingScroll() async {
    final positions = _positionsListener.itemPositions.value;
    if (positions.isEmpty) return;

    final firstVisible = positions
        .where((item) => item.itemLeadingEdge >= 0)
        .reduce((a, b) => a.index < b.index ? a : b);

    final preservedIndex = firstVisible.index;
    final preservedOffset = firstVisible.itemLeadingEdge;

    setState(() => isLoadingMore = true);

    // Simulate network delay
    await Future.delayed(Duration(seconds: 1));

    // Add 10 older messages
    final newMessages = List.generate(10, (i) {
      final id = 'msg_${messages.length + i}';
      return Message(id: id, text: 'Old Message ${messages.length + i + 1}');
    });

    setState(() {
      messages.addAll(newMessages);
      isLoadingMore = false;
    });

    // Wait for UI to rebuild, then correct scroll
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(
        index: preservedIndex + newMessages.length,
        alignment: preservedOffset,
      );
    });
  }

  void _scrollToMessage(String id) async {
    int index = messages.indexWhere((m) => m.id == id);
    while (index == -1) {
      await _loadMoreMessagesPreservingScroll();
      index = messages.indexWhere((m) => m.id == id);
      await Future.delayed(Duration(milliseconds: 100));
    }

    if (_scrollController.isAttached) {
      _scrollController.scrollTo(
        index: index,
        duration: Duration(milliseconds: 400),
        alignment: 0.5,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: ScrollablePositionedList.builder(
              itemScrollController: _scrollController,
              itemPositionsListener: _positionsListener,
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return ListTile(
                  title: Text(message.text),
                  onTap: () {
                    // Simulate replying to a specific message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Scrolling to message ID: ${message.id}')),
                    );
                    _scrollToMessage(message.id);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}