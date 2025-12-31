import 'package:cloud_firestore/cloud_firestore.dart';


class MealLogEntry { 
  final String id;
  final String name;
  
  
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

 
  factory MealLogEntry.fromMap(Map<String, dynamic> map, String docId) {
    return MealLogEntry(
      id: docId,
      name: map['name'] ?? 'Unknown Meal',
      
      
      calories: (map['calories'] as num? ?? 0).toDouble(),
      protein: (map['protein'] as num? ?? 0).toDouble(),
      carbs: (map['carbs'] as num? ?? 0).toDouble(),
      fat: (map['fat'] as num? ?? 0).toDouble(),
      
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

 
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