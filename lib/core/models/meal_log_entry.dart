import 'package:cloud_firestore/cloud_firestore.dart';

class meal_log_entry {
  final String id;
  final String name;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final DateTime timestamp;

  meal_log_entry({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.timestamp,
  });

  // Factory to convert Firebase Data -> Object
  factory meal_log_entry.fromMap(Map<String, dynamic> map, String docId) {
    return meal_log_entry(
      id: docId,
      name: map['name'] ?? 'Unknown Meal',
      // SAFETY: Handle if data is missing or stored as String/Double
      calories: (map['calories'] as num? ?? 0).toInt(),
      protein: (map['protein'] as num? ?? 0).toInt(),
      carbs: (map['carbs'] as num? ?? 0).toInt(),
      fat: (map['fat'] as num? ?? 0).toInt(),
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Convert Object -> Firebase Data
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'timestamp': timestamp,
    };
  }
}