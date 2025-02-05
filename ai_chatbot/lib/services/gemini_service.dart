import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  static const String apiKey = "AIzaSyAb-2DWfPETV6zyFwntQ3U8uzN47AkCzO0";
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
