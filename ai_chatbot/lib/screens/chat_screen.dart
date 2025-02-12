import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../services/gemini_service.dart';
import '../services/speech_service.dart';
import '../services/storage_service.dart';
import '../widgets/chat_bubble_widget.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final SpeechToTextService _speechToText = SpeechToTextService();
  List<Map<String, String>> messages = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final loadedMessages = await StorageService.loadMessages();
    setState(() {
      messages = loadedMessages;
      _scrollToBottom(); // Scroll after loading messages
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String userText) async {
    userText = userText.trim();
    if (userText.isEmpty) return;

    setState(() {
      messages.add({"sender": "user", "text": userText});
      _controller.clear();
      isLoading = true;
    });
    _scrollToBottom();

    try {
      String botResponse = await GeminiService.fetchResponse(userText);
      botResponse = _formatBotResponse(botResponse);
      setState(() {
        messages.add({"sender": "bot", "text": botResponse});
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        messages.add({"sender": "bot", "text": "Oops! Something went wrong."});
        isLoading = false;
      });
    }

    _scrollToBottom();
    StorageService.saveMessages(messages);
  }

  Future<void> _startListening() async {
    final recognizedText = await _speechToText.listen();
    if (recognizedText.isNotEmpty) {
      setState(() {
        _controller.text = recognizedText.trim();
      });
    }
  }

  String _formatBotResponse(String response) {
    response = response.trim();

    // Ensure response ends with proper punctuation
    if (!RegExp(r'[.!?]$').hasMatch(response)) {
      response += '.';
    }

    // Balance brackets and quotes
    Map<String, String> pairs = {
      '(': ')',
      '[': ']',
      '{': '}',
      '"': '"',
      "'": "'"
    };
    pairs.forEach((open, close) {
      int openCount = response.split(open).length - 1;
      int closeCount = response.split(close).length - 1;
      if (openCount > closeCount) response += close;
    });

    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("AI-ChatBot",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue,
        elevation: 5,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length + (isLoading ? 1 : 0),
              padding: const EdgeInsets.all(10),
              itemBuilder: (context, index) {
                if (index == messages.length && isLoading) {
                  return _buildLoadingIndicator();
                }
                final message = messages[index];
                return ChatBubbleWidget(
                  message: message['text']!,
                  isUser: message['sender'] == "user",
                );
              },
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      width: double.infinity,
                      height: 12,
                      color: Colors.grey[300]),
                  const SizedBox(height: 5),
                  Container(width: 150, height: 12, color: Colors.grey[300]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, spreadRadius: 2)
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.mic, color: Colors.blue),
            onPressed: _startListening,
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: "Type a message...",
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              ),
              onSubmitted: (text) => _sendMessage(text),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: () => _sendMessage(_controller.text.trim()),
            ),
          ),
        ],
      ),
    );
  }
}
