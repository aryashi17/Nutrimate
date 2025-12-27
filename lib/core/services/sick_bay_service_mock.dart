import '../models/sick_bay_result.dart';

class SickBayServiceMock {
  /// Simulates fetching today's menu
  Future<List<String>> getTodaysMenu() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      "Basmati Rice",
      "Dal Tadka",
      "Paneer Masala",
      "Curd",
      "Roti",
    ];
  }

  /// Simulates Gemini / AI analysis
  Future<SickBayResult> analyzeSickness({
    required String description,
    required List<String> selectedAilments,
    required List<String> todaysMenu,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    // VERY SIMPLE deterministic logic (important)
    if (selectedAilments.contains("Fever")) {
      return SickBayResult(
        eat: ["Curd", "Rice Water", "Khichdi"],
        avoid: ["Fried Food", "Cold Drinks"],
        care: [
          "Take proper rest",
          "Drink warm fluids",
          "Consult doctor if fever persists",
        ],
        severity: "mild",
      );
    }

    if (selectedAilments.contains("Stomach Pain")) {
      return SickBayResult(
        eat: ["Banana", "Curd", "Plain Rice"],
        avoid: ["Spicy Food", "Street Food"],
        care: [
          "Avoid outside food",
          "Stay hydrated",
        ],
        severity: "moderate",
      );
    }

    // Default fallback
    return SickBayResult(
      eat: ["Home-cooked food"],
      avoid: ["Processed food"],
      care: ["Monitor symptoms"],
      severity: "low",
    );
  }
}
