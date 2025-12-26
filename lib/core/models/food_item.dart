class FoodItem {
  final String id;
  final String displayName;
  final double calPerGram;
  final double gramPerCup; // Optional helpful metric
  // Map of sectionId -> grams when section is full (density factor)
  final Map<String, double> defaultSectionDensity; 

  FoodItem({
    required this.id,
    required this.displayName,
    required this.calPerGram,
    required this.gramPerCup,
    required this.defaultSectionDensity,
  });
}