import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';

class ChatBubbleWidget extends StatelessWidget {
  final String message;
  final bool isUser;

  const ChatBubbleWidget(
      {super.key, required this.message, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return ChatBubble(
      clipper: ChatBubbleClipper1(
          type: isUser ? BubbleType.sendBubble : BubbleType.receiverBubble),
      alignment: isUser ? Alignment.topRight : Alignment.topLeft,
      margin: EdgeInsets.symmetric(vertical: 5),
      backGroundColor: isUser ? Colors.lightBlue[400] : Colors.grey[100],
      child: Text(
        message,
        style: TextStyle(color: isUser ? Colors.white : Colors.black),
      ),
    );
  }
}
