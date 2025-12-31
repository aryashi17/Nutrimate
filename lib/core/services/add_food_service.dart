import '../models/food_item.dart';


class AddFoodService {
  
  Future<FoodItem> addManualFood({
    required String name,
    required double caloriesPer100g,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    return FoodItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      displayName: name,
      calPerGram: caloriesPer100g / 100, // Convert to per gram
      gramPerCup: 200, // Default estimate
      defaultSectionDensity: {'Default': 200},
    );
  }

 
  Future<FoodItem> scanFood() async {
    // Simulate scanning delay
    await Future.delayed(const Duration(seconds: 2));

    // Return a fake "Scanned" Apple
    return FoodItem(
      id: 'mock_scan_123',
      displayName: 'Green Apple (Scanned)',
      calPerGram: 0.52, // 52 kcal / 100g
      gramPerCup: 125,
      defaultSectionDensity: {'Whole': 180, 'Sliced': 125},
    );
  }
}