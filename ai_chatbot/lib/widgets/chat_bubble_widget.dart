import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';

class ChatBubbleWidget extends StatelessWidget {
  final String message;
  final bool isUser;

  const ChatBubbleWidget({Key? key, required this.message, required this.isUser})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChatBubble(
      clipper: ChatBubbleClipper1(
          type: isUser ? BubbleType.sendBubble : BubbleType.receiverBubble),
      alignment: isUser ? Alignment.topRight : Alignment.topLeft,
      margin: EdgeInsets.symmetric(vertical: 5),
      backGroundColor: isUser ? Colors.blue : Colors.grey[300],
      child: Text(
        message,
        style: TextStyle(color: isUser ? Colors.white : Colors.black),
      ),
    );
  }
}
