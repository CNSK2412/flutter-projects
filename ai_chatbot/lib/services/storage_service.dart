import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _key = 'chatHistory';

  /// Save chat messages to local storage
  static Future<void> saveMessages(List<Map<String, String>> messages) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, jsonEncode(messages));
    } catch (e) {
      print("Error saving messages: $e");
    }
  }

  /// Load chat messages from local storage
  static Future<List<Map<String, String>>> loadMessages() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? stored = prefs.getString(_key);
      return stored != null
          ? List<Map<String, String>>.from(jsonDecode(stored))
          : [];
    } catch (e) {
      print("Error loading messages: $e");
      return [];
    }
  }

  /// Clear chat history
  static Future<void> clearMessages() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (e) {
      print("Error clearing messages: $e");
    }
  }
}
