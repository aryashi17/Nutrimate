import 'package:flutter/material.dart';
import '../models/food_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CalcResult {
  final double grams;
  final double calories;
  CalcResult(this.grams, this.calories);
}

class CalculatorEngine extends ChangeNotifier {
  double currentProtein = 0.0;
  double currentCarbs = 0.0;

  double proteinGoal = 120.0;
  double carbGoal = 250.0;

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _todayId {
    final now = DateTime.now();
    return "${now.year}-${now.month}-${now.day}";
  }

  // ---------------------------
  // FOOD CALCULATION (UNCHANGED)
  // ---------------------------
  Future<CalcResult> calculate({
    required String sectionId,
    required double fillFraction,
    required FoodItem food,
  }) async {
    await Future.delayed(const Duration(milliseconds: 50));
    double maxGrams = food.defaultSectionDensity[sectionId] ?? 200.0;
    double actualGrams = maxGrams * fillFraction;
    double actualCals = actualGrams * food.calPerGram;
    return CalcResult(actualGrams, actualCals);
  }

  // ---------------------------
  // FOOD LIBRARY (UNCHANGED)
  // ---------------------------
  final Map<String, Map<String, double>> foodLibrary = {
    "Paneer": {"p": 25.0, "c": 10.0},
    "Rice": {"p": 5.0, "c": 45.0},
    "Dal": {"p": 12.0, "c": 25.0},
    "Eggs": {"p": 18.0, "c": 2.0},
    "Chicken": {"p": 30.0, "c": 0.0},
    "Oats": {"p": 10.0, "c": 50.0},
    "Roti": {"p": 4.0, "c": 20.0},
  };

  // ---------------------------
  // LOAD DAILY DATA FROM FIRESTORE
  // ---------------------------
  Future<void> fetchInitialData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // Load goals from profile
      final profile = await _db.collection('users').doc(user.uid).get();
      if (profile.exists) {
        proteinGoal = (profile['dailyProteinTarget'] ?? proteinGoal).toDouble();
        carbGoal = (profile['dailyCarbTarget'] ?? carbGoal).toDouble();
      }

      // Load today's totals
      final doc = await _db
          .collection('users')
          .doc(user.uid)
          .collection('daily_stats')
          .doc(_todayId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        currentProtein = (data['protein'] ?? 0).toDouble();
        currentCarbs = (data['carbs'] ?? 0).toDouble();
      }

      notifyListeners();
    } catch (e) {
      debugPrint("CalculatorEngine: fetch error $e");
    }
  }

  // ---------------------------
  // ADD FOOD + SYNC TO FIRESTORE
  // ---------------------------
  Future<void> addFood(String name, double portion) async {
    final nutrients = foodLibrary.entries
        .firstWhere(
          (e) => name.contains(e.key),
          orElse: () => const MapEntry("Other", {"p": 10.0, "c": 30.0}),
        )
        .value;

    currentProtein += (nutrients["p"] ?? 0.0) * portion;
    currentCarbs += (nutrients["c"] ?? 0.0) * portion;

    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _db
          .collection('users')
          .doc(user.uid)
          .collection('daily_stats')
          .doc(_todayId)
          .set({
        'protein': currentProtein,
        'carbs': currentCarbs,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("CalculatorEngine: sync error $e");
    }
  }

  // ---------------------------
  // HEALTH INSIGHTS LOGIC
  // ---------------------------
  String getEmergencyFix() {
    final now = DateTime.now();
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
    1: 'Jan',
    2: 'Feb',
    3: 'Mar',
    4: 'Apr',
    5: 'May',
    6: 'Jun',
    7: 'Jul',
    8: 'Aug',
    9: 'Sep',
    10: 'Oct',
    11: 'Nov',
    12: 'Dec',
  };
}
