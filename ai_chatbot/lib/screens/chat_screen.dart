import 'package:flutter/material.dart';
import '../services/openai_service.dart';
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

    String botResponse = await OpenAIService.fetchResponse(userText);

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
    return Scaffold(
      backgroundColor: Colors.white, // Standard White Theme
      appBar: AppBar(
        title: Text("ChatBot"),
        backgroundColor: Colors.blue, // Header color
        elevation: 5,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length,
              padding: EdgeInsets.all(10),
              itemBuilder: (context, index) {
                return ChatBubbleWidget(
                  message: messages[index]['text']!,
                  isUser: messages[index]['sender'] == "user",
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.mic, color: Colors.blue),
                  onPressed: startListening,
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: () => sendMessage(_controller.text.trim()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
