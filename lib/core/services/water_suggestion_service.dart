import 'dart:math';

class WaterSuggestionService {
  static final List<String> _suggestions = [
    "Add lemon 🍋 to make it refreshing",
    "Add two spoons of Tang 🍊 for flavor",
    "Try cold infused water 🧊",
    "Add mint leaves 🌿",
    "Drink plain water 💧 — simple & healthy",
  ];

  static String getSuggestion() {
    final random = Random();
    return _suggestions[random.nextInt(_suggestions.length)];
  }
}
