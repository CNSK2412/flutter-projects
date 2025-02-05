import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController _controller = TextEditingController();
  List<Map<String, String>> messages = [];
  SpeechToTextService speechToText = SpeechToTextService();

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
    return Scaffold(
      appBar: AppBar(title: Text("Gemini AI Chatbot")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ChatBubble(
                  clipper: ChatBubbleClipper1(
                      type: messages[index]['sender'] == "user"
                          ? BubbleType.sendBubble
                          : BubbleType.receiverBubble),
                  alignment: messages[index]['sender'] == "user"
                      ? Alignment.topRight
                      : Alignment.topLeft,
                  margin: EdgeInsets.symmetric(vertical: 5),
                  backGroundColor: messages[index]['sender'] == "user"
                      ? Colors.blue
                      : Colors.grey[300],
                  child: Text(
                    messages[index]['text']!,
                    style: TextStyle(
                        color: messages[index]['sender'] == "user"
                            ? Colors.white
                            : Colors.black),
                  ),
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

// Gemini API Integration
class GeminiService {
  static const String apiKey =
      "your_gemini_api_key"; // Insert your Gemini API key
  static const String apiUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent";

  static Future<String> fetchResponse(String userMessage) async {
    final response = await http.post(
      Uri.parse("$apiUrl?key=$apiKey"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "contents": [
          {
            "role": "user",
            "parts": [
              {"text": userMessage}
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'] ??
          "Sorry, I didn't understand that.";
    } else {
      return "Error: Unable to get a response";
    }
  }
}

// Speech-to-Text Service
class SpeechToTextService {
  final stt.SpeechToText speech = stt.SpeechToText();

  Future<String> listen() async {
    bool available = await speech.initialize();
    if (available) {
      String recognizedText = "";
      await speech.listen(onResult: (result) {
        recognizedText = result.recognizedWords;
      });
      return recognizedText;
    } else {
      return "Speech recognition not available";
    }
  }
}

// Chat History Service using SharedPreferences
class StorageService {
  static Future<void> saveMessages(List<Map<String, String>> messages) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('chatHistory',
        messages.map((m) => "${m['sender']}:${m['text']}").toList());
  }

  static Future<List<Map<String, String>>> loadMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? storedMessages = prefs.getStringList('chatHistory');

    if (storedMessages != null) {
      return storedMessages.map((m) {
        var parts = m.split(':');
        return {"sender": parts[0], "text": parts.sublist(1).join(':')};
      }).toList();
    }
    return [];
  }
}
