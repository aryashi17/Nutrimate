import 'dart:math';
import '../models/food_item.dart';
import 'add_food_service.dart';

class AddFoodServiceMock implements AddFoodService {
  final _rand = Random();

  @override
  Future<FoodItem> addManualFood({
    required String name,
    required double caloriesPer100g,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    return FoodItem(
      id: name.toLowerCase().replaceAll(" ", "_"),
      displayName: name,
      calPerGram: caloriesPer100g / 100.0,
      gramPerCup: 240, // reasonable default
      defaultSectionDensity: {
        "largest_compartment": 250,
        "small_bowl": 150,
        "circular_bowl": 120,
      },i
    );
  }

  @override
  Future<FoodItem> scanFood() async {
    await Future.delayed(const Duration(seconds: 1));

    return FoodItem(
      id: "banana",
      displayName: "Banana",
      calPerGram: 0.89,
      gramPerCup: 225,
      defaultSectionDensity: {
        "largest_compartment": 200,
        "small_bowl": 120,
      },
    );
  }
}
