import '../models/food_item.dart';

class CalcResult {
  final double grams;
  final double calories;
  CalcResult(this.grams, this.calories);
}

class CalculatorEngine {
  // The logic: (Fill % * Section Max Capacity for that Food)
  Future<CalcResult> calculate({
    required String sectionId,
    required double fillFraction, // 0.0 to 1.0
    required FoodItem food,
  }) async {
    // MOCK LOGIC for Day 1
    // In real version: use food.defaultSectionDensity[sectionId] * fillFraction
    await Future.delayed(const Duration(milliseconds: 50)); // Fake network lag
    
    // Fallback if density not mapped
    double maxGrams = food.defaultSectionDensity[sectionId] ?? 200.0; 
    double actualGrams = maxGrams * fillFraction;
    double actualCals = actualGrams * food.calPerGram;
    
    return CalcResult(actualGrams, actualCals);
  }
}