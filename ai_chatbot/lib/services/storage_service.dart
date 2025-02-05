import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static Future<void> saveMessages(List<Map<String, String>> messages) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('chatHistory', jsonEncode(messages));
  }

  static Future<List<Map<String, String>>> loadMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? stored = prefs.getString('chatHistory');
    return stored != null ? List<Map<String, String>>.from(jsonDecode(stored)) : [];
  }
}
