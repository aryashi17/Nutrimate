class MealLogEntry {
  final String id;
  final DateTime timestamp;
  final String plateType;
  // List of {sectionId, foodId, fillFraction, calculatedGrams, calculatedCals}
  final List<Map<String, dynamic>> selections; 

  MealLogEntry({
    required this.id,
    required this.timestamp,
    required this.plateType,
    required this.selections,
  });
}