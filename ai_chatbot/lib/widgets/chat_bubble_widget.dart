import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';

class ChatBubbleWidget extends StatelessWidget {
  final String message;
  final bool isUser;

  const ChatBubbleWidget({
    super.key,
    required this.message,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    return ChatBubble(
      clipper: ChatBubbleClipper1(
        type: isUser ? BubbleType.sendBubble : BubbleType.receiverBubble,
      ),
      alignment: isUser ? Alignment.topRight : Alignment.topLeft,
      margin: const EdgeInsets.symmetric(vertical: 5),
      backGroundColor: isUser ? Colors.lightBlue[400] : Colors.grey[100],
      child: _formatMessage(message), // Apply formatted text
    );
  }

  /// Parses the message and applies:
  /// - **Bold Formatting** for (**text**)
  /// - • Bullet Points for (*) text
  Widget _formatMessage(String text) {
    List<TextSpan> spans = [];
    RegExp boldExp = RegExp(r'\*\*(.*?)\*\*'); // Detect (**bold**)
    RegExp bulletExp = RegExp(r'\(\*\)'); // Detect (*) correctly

    // Replace (*) with bullet point symbol (•)
    text = text.replaceAllMapped(bulletExp, (match) => "• ");

    int lastMatchEnd = 0;
    Iterable<Match> matches = boldExp.allMatches(text);

    for (Match match in matches) {
      // Add normal text before bold match
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(text: text.substring(lastMatchEnd, match.start)));
      }
      // Add bold text
      spans.add(
        TextSpan(
          text: match.group(1), // Extract text inside (** **)
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );
      lastMatchEnd = match.end;
    }

    // Add remaining normal text
    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd)));
    }

    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 14,
          color: isUser ? Colors.white : Colors.black,
        ),
        children: spans,
      ),
    );
  }
}
