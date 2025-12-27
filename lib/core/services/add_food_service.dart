import '../models/food_item.dart';

abstract class AddFoodService {
  Future<FoodItem> addManualFood({
    required String name,
    required double caloriesPer100g,
  });

  Future<FoodItem> scanFood();
}
