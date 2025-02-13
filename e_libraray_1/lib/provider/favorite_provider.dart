import 'package:flutter/material.dart';

class FavoriteProvider with ChangeNotifier {
  final List<String> _favorites = [];

  List<String> get favorites => _favorites;

  void toggleFavorite(String book) {
    if (_favorites.contains(book)) {
      _favorites.remove(book);
    } else {
      _favorites.add(book);
    }
    notifyListeners();
  }

  bool isFavorite(String book) {
    return _favorites.contains(book);
  }
}
