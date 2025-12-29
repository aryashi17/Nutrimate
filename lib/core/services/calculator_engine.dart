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
  // --- HYDRATION DATA ---
  int totalDrank = 0;
  int goal = 2000;
  int bottlesCompleted = 0;

  // --- MACRO DATA ---
  double currentProtein = 0.0;
  double currentCarbs = 0.0;
  final double proteinGoal = 120.0;
  final double carbGoal = 250.0;
  DateTime lastResetDate = DateTime.now();

  // --- LOGIC: ADD WATER ---
  void addWater(int amount) {
    checkAndResetForNewDay();
    totalDrank += amount;
    
    if (totalDrank >= goal) {
      bottlesCompleted++;
      totalDrank = 0; 
    }
    
    notifyListeners();
    syncWaterToFirebase();
  }

  void resetHydration() {
    totalDrank = 0;
    bottlesCompleted = 0;
    notifyListeners();
    syncWaterToFirebase();
  }

  // --- LOGIC: RESET FOR NEW DAY ---
  void checkAndResetForNewDay() {
    final now = DateTime.now();
    if (now.day != lastResetDate.day || now.month != lastResetDate.month) {
      currentProtein = 0.0;
      currentCarbs = 0.0;
      totalDrank = 0;
      bottlesCompleted = 0;
      lastResetDate = now;
      notifyListeners();
    }
  }

  // --- FIREBASE SYNC ---
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
        currentProtein = (data['totalProtein'] ?? 0.0).toDouble();
        currentCarbs = (data['totalCarbs'] ?? 0.0).toDouble();
        // Load saved water progress
        totalDrank = (data['water'] ?? 0).toInt();
        bottlesCompleted = (data['bottlesCompleted'] ?? 0).toInt();
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error fetching initial data: $e");
    }
  }

  Future<void> syncWaterToFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    final String dateId = DateTime.now().toIso8601String().split('T')[0];
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('logs')
        .doc(dateId)
        .set({
      'water': totalDrank,
      'bottlesCompleted': bottlesCompleted,
      'timestamp': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
  }

  // --- FOOD LOGGING LOGIC ---
  final Map<String, Map<String, double>> foodLibrary = {
    "Paneer": {"p": 25.0, "c": 10.0},
    "Rice": {"p": 5.0, "c": 45.0},
    "Dal": {"p": 12.0, "c": 25.0},
    "Eggs": {"p": 18.0, "c": 2.0},
    "Chicken": {"p": 30.0, "c": 0.0},
    "Oats": {"p": 10.0, "c": 50.0},
    "Roti": {"p": 4.0, "c": 20.0},
  };

  Future<void> addFood(String name, double portion) async {
    checkAndResetForNewDay();
    
    final nutrients = foodLibrary.entries
        .firstWhere((e) => name.contains(e.key), 
        orElse: () => const MapEntry("Other", {"p": 10.0, "c": 30.0}))
        .value;

    currentProtein += (nutrients["p"] ?? 0.0) * portion;
    currentCarbs += (nutrients["c"] ?? 0.0) * portion;

    notifyListeners();
    syncFoodToFirebase();
  }

  Future<void> syncFoodToFirebase() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final String dateId = DateTime.now().toIso8601String().split('T')[0];
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('logs')
            .doc(dateId)
            .set({
          'totalProtein': currentProtein,
          'totalCarbs': currentCarbs,
          'dateLabel': "${DateTime.now().day} ${MonthLabels.short[DateTime.now().month]}",
        }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('Error syncing food: $e');
    }
  }

  String getEmergencyFix() {
    final now = DateTime.now();
    if (now.hour < 20) return ""; 
    if (currentProtein < (proteinGoal * 0.6)) return "🚨 LATE NIGHT PROTEIN FIX: Grab a Protein Shake!";
    if (currentCarbs < (carbGoal * 0.6)) return "🚨 ENERGY DEFICIT: Eat a Banana!";
    return "✅ You're all set for tonight.";
  }
}

class MonthLabels {
  static const Map<int, String> short = {
    1: 'Jan', 2: 'Feb', 3: 'Mar', 4: 'Apr', 5: 'May', 6: 'Jun',
    7: 'Jul', 8: 'Aug', 9: 'Sep', 10: 'Oct', 11: 'Nov', 12: 'Dec',
  };
}