import 'package:cloud_firestore/cloud_firestore.dart';
import './mess_menu_service.dart';
import '../models/sick_bay_result.dart';

class SickBayService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Get today's menu as list of food names
  Future<List<String>> getTodaysMenu() async {
    final menu = await MessMenuService().getTodayMenu();

    return menu.values
        .expand((meal) => meal)
        .map((item) => item['name'] as String)
        .toList();
  }

  /// TEMP deterministic logic (replace with Gemini later)
  Future<SickBayResult> analyzeSickness({
    required String description,
    required List<String> selectedAilments,
    required List<String> todaysMenu,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    if (selectedAilments.contains("Fever")) {
      return SickBayResult(
        eat: ["Curd", "Plain Rice", "Khichdi"],
        avoid: ["Fried Food", "Cold Drinks"],
        care: [
          "Take rest",
          "Drink warm fluids",
          "Consult doctor if persists"
        ],
        severity: "mild",
      );
    }

    if (selectedAilments.contains("Stomach Pain")) {
      return SickBayResult(
        eat: ["Banana", "Curd"],
        avoid: ["Spicy Food", "Street Food"],
        care: ["Stay hydrated"],
        severity: "moderate",
      );
    }

    return SickBayResult(
      eat: ["Home cooked food"],
      avoid: ["Junk food"],
      care: ["Monitor symptoms"],
      severity: "low",
    );
  }
}
