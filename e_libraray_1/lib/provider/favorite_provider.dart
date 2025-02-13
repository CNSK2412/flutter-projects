import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteProvider with ChangeNotifier {
  List<String> _favorites = [];

  List<String> get favorites => _favorites;

  // Load favorites from SharedPreferences
  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? savedFavorites = prefs.getStringList('favorites');
    if (savedFavorites != null) {
      _favorites = savedFavorites;
    }
    notifyListeners();
  }

  // Toggle favorite and save it to SharedPreferences
  Future<void> toggleFavorite(String book) async {
    final prefs = await SharedPreferences.getInstance();

    if (_favorites.contains(book)) {
      _favorites.remove(book);
    } else {
      _favorites.add(book);
    }

    // Save the updated favorites list to SharedPreferences
    await prefs.setStringList('favorites', _favorites);
    notifyListeners();
  }

  // Check if a book is a favorite
  bool isFavorite(String book) {
    return _favorites.contains(book);
  }
}
