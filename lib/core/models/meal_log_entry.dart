import 'package:cloud_firestore/cloud_firestore.dart';

// 1. Rename class to PascalCase to match Dart conventions and your UI call
class MealLogEntry { 
  final String id;
  final String name;
  
  // 2. Change macros to double to fix "double can't be assigned to int" errors
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  
  final DateTime timestamp;

  MealLogEntry({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.timestamp,
  });

  // Factory to convert Firebase Data -> Object
  factory MealLogEntry.fromMap(Map<String, dynamic> map, String docId) {
    return MealLogEntry(
      id: docId,
      name: map['name'] ?? 'Unknown Meal',
      
      // 3. Update parsing logic to safely handle numbers as doubles
      // 'num' captures both int and double, then we force .toDouble()
      calories: (map['calories'] as num? ?? 0).toDouble(),
      protein: (map['protein'] as num? ?? 0).toDouble(),
      carbs: (map['carbs'] as num? ?? 0).toDouble(),
      fat: (map['fat'] as num? ?? 0).toDouble(),
      
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