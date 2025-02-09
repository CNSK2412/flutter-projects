import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart'; // Import the shimmer package
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
    if (userText.isEmpty) return;

    // Add user message to the chat
    setState(() {
      messages.add({"sender": "user", "text": userText});
      _controller.clear();
    });
    _scrollToBottom();

    // Fetch bot response
    setState(() {
      isLoading = true; // Show loading indicator
    });
    String botResponse = await GeminiService.fetchResponse(userText);
    botResponse = _formatBotResponse(botResponse); // Format AI response

    // Add bot response to the chat
    setState(() {
      messages.add({"sender": "bot", "text": botResponse});
      isLoading = false; // Hide loading indicator
    });
    _scrollToBottom();

    // Save messages to storage
    StorageService.saveMessages(messages);
  }

  Future<void> _startListening() async {
    final recognizedText = await _speechToText.listen();
    setState(() {
      _controller.text = recognizedText.trim();
    });
  }

  /// Function to clean and format AI response
  String _formatBotResponse(String response) {
    response = response.trim();

    // Ensure the response ends with proper punctuation
    if (!response.endsWith('.') && !response.endsWith('!') && !response.endsWith('?')) {
      response += '.';
    }

    // Balance brackets and quotes
    const pairs = {'(': ')', '[': ']', '{': '}', '"': '"', "'": "'"};
    for (final open in pairs.keys) {
      final openCount = response.split(open).length - 1;
      final closeCount = response.split(pairs[open]!).length - 1;
      if (openCount > closeCount) {
        response += pairs[open]!;
      }
    }

    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "AI-ChatBot",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
                  return _buildLoadingIndicator(); // Modern shimmer effect
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
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 5),
                  Container(
                    width: 150,
                    height: 12,
                    color: Colors.grey[300],
                  ),
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
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, spreadRadius: 2)],
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
                contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              ),
              onSubmitted: _sendMessage,
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