import 'package:flutter/material.dart';
import '../models/food_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Add this import
import 'package:firebase_auth/firebase_auth.dart';    // Add this import

class CalcResult {
  final double grams;
  final double calories;
  CalcResult(this.grams, this.calories);
}

class CalculatorEngine extends ChangeNotifier{
  double currentProtein = 0.0;
  double currentCarbs = 0.0;
  DateTime lastResetDate = DateTime.now();

  void checkAndResetForNewDay() {
    final now = DateTime.now();
    // If today is a different day than the last time we logged food
    if (now.day != lastResetDate.day || now.month != lastResetDate.month) {
      currentProtein = 0.0;
      currentCarbs = 0.0;
      lastResetDate = now;
      notifyListeners(); // Updates the home page button and charts
    }
  }

  final double proteinGoal = 120.0;
  final double carbGoal = 250.0;
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
  // A library of nutrient values per full portion (1.0)
  final Map<String, Map<String, double>> foodLibrary = {
    "Paneer": {"p": 25.0, "c": 10.0},
    "Rice": {"p": 5.0, "c": 45.0},
    "Dal": {"p": 12.0, "c": 25.0},
    "Eggs": {"p": 18.0, "c": 2.0},
    "Chicken": {"p": 30.0, "c": 0.0},
    "Oats": {"p": 10.0, "c": 50.0},
    "Roti": {"p": 4.0, "c": 20.0},
  };
  Future<void> fetchInitialData() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final String dateId = DateTime.now().toIso8601String().split('T')[0];
  
  try {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('logs')
        .doc(dateId)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      // Update local variables with what's already in the cloud
      currentProtein = (data['totalProtein'] ?? 0.0).toDouble();
      currentCarbs = (data['totalCarbs'] ?? 0.0).toDouble();
      notifyListeners();
    }
  } catch (e) {
    debugPrint("Error fetching daily start: $e");
  }
}

  Future<void> addFood(String name, double portion) async { // Make this async
    checkAndResetForNewDay();
    
    final nutrients = foodLibrary.entries
        .firstWhere((e) => name.contains(e.key), 
        orElse: () => const MapEntry("Other", {"p": 10.0, "c": 30.0}))
        .value;

    currentProtein += (nutrients["p"] ?? 0.0) * portion;
    currentCarbs += (nutrients["c"] ?? 0.0) * portion;

    notifyListeners();

    // --- NEW: SYNC TO FIREBASE FOR CHARTS ---
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final String dateId = DateTime.now().toIso8601String().split('T')[0]; // e.g., "2023-10-27"
      
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('logs')
          .doc(dateId) // Use date as ID to overwrite/update the same day's total
          .set({
        'totalProtein': currentProtein,
        'totalCarbs': currentCarbs,
        'timestamp': DateTime.now().toIso8601String(),
        'dateLabel': "${DateTime.now().day} ${MonthLabels.short[DateTime.now().month]}",
        'water': 0.0, // Should be updated via HydrationScreen
      }, SetOptions(merge: true)); // Use merge to avoid overwriting water logs
    }
  }

  // Inside calculator_engine.dart

String getEmergencyFix() {
  final now = DateTime.now();
  // Only suggest "Last Minute Fixes" after 8 PM (20:00)
  if (now.hour < 20) return ""; 

  if (currentProtein < (proteinGoal * 0.6)) {
    return "🚨 LATE NIGHT PROTEIN FIX: Grab a Protein Shake or 3 Boiled Eggs at the kiosk now to prevent muscle fatigue tomorrow.";
  } else if (currentCarbs < (carbGoal * 0.6)) {
    return "🚨 ENERGY DEFICIT: Eat a Banana or a small bowl of Oats to avoid waking up with low blood sugar and 'brain fog'.";
  }
  return "✅ You're all set for tonight. Sleep well!";
}
}

class MonthLabels {
  static const Map<int, String> short = {
    1: 'Jan', 2: 'Feb', 3: 'Mar', 4: 'Apr', 5: 'May', 6: 'Jun',
    7: 'Jul', 8: 'Aug', 9: 'Sep', 10: 'Oct', 11: 'Nov', 12: 'Dec',
  };
}