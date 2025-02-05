import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../services/gemini_service.dart';
import '../services/speech_service.dart';
import '../services/storage_service.dart';
import '../widgets/chat_bubble_widget.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController _controller = TextEditingController();
  List<Map<String, String>> messages = [];
  SpeechToTextService speechToText = SpeechToTextService();
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    loadMessages();
  }

  Future<void> loadMessages() async {
    messages = await StorageService.loadMessages();
    setState(() {});
  }

  void sendMessage(String userText) async {
    if (userText.isEmpty) return;

    setState(() {
      messages.add({"sender": "user", "text": userText});
      _controller.clear();
    });

    Future.delayed(Duration(milliseconds: 300), () {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });

    String botResponse = await GeminiService.fetchResponse(userText);

    setState(() {
      messages.add({"sender": "bot", "text": botResponse});
    });

    StorageService.saveMessages(messages);
  }

  void startListening() async {
    String recognizedText = await speechToText.listen();
    _controller.text = recognizedText;
  }

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Gemini AI Chatbot"),
        actions: [
          IconButton(
            icon: Icon(
                themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode),
            onPressed: themeProvider.toggleTheme,
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ChatBubbleWidget(
                  message: messages[index]['text']!,
                  isUser: messages[index]['sender'] == "user",
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(icon: Icon(Icons.mic), onPressed: startListening),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () => sendMessage(_controller.text.trim()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
