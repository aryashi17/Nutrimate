import 'models/food_item.dart';
import 'models/plate_model.dart';

// 1. Fake Food
final List<FoodItem> kDummyMenu = [
  FoodItem(
    id: 'rajma',
    displayName: 'Rajma',
    calPerGram: 1.4,
    gramPerCup: 250,
    defaultSectionDensity: {'largest_compartment': 300.0, 'small_bowl': 150.0},
  ),
  FoodItem(
    id: 'rice',
    displayName: 'Steamed Rice',
    calPerGram: 1.3,
    gramPerCup: 200,
    defaultSectionDensity: {'largest_compartment': 250.0, 'small_bowl': 120.0},
  ),
];

// 2. Fake Plate
final kPlateA = PlateModel(plateType: 'A', sections: [
  PlateSection(id: 'largest_compartment', label: 'Main', volumeFactor: 1.0),
  PlateSection(id: 'small_bowl', label: 'Bowl', volumeFactor: 0.4),
  PlateSection(id: 'circular_bowl', label: 'Round', volumeFactor: 0.25),
]);