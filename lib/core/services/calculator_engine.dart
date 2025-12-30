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
  //int goal = 2000;
  int bottlesCompleted = 0;

double weight = 70.0; // Default
  String gender = 'Male';
  double height = 170.0;

  // Dynamic Goal Calculation
  int get dynamicGoal {
    // Basic formula: 35ml per kg
    double baseGoal = weight * 35;
    
    // Adjust for gender (Standard guideline: Men usually need slightly more)
    if (gender == 'Male') {
      baseGoal += 500; 
    }
    
    // Adjust for height (taller people require more hydration)
    if (height > 180) {
      baseGoal += 300;
    }

    return baseGoal.toInt();
  }

  // Replace your old goal variable with a getter
  int get goal => dynamicGoal;

  // Call this when you fetch user profile data from Firebase
 void updateProfile({double? newWeight, double? newHeight, String? newGender}) {
  // Use the correct variable names: weight and height
  if (newWeight != null) weight = newWeight; 
  if (newHeight != null) height = newHeight;
  if (newGender != null) gender = newGender;

  // You don't need _calculateWaterGoal() because you use a 'get' getter
  // for 'goal', which calculates automatically when the UI rebuilds.

  notifyListeners(); 
}
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

 Future<void> fetchInitialData() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  try {
    final profileDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    
    if (profileDoc.exists) {
      final pData = profileDoc.data()!;
      
      // Update these lines to match your Firebase screenshot names
      weight = double.tryParse(pData['weightKg'].toString()) ?? 70.0;
      height = double.tryParse(pData['heightCm'].toString()) ?? 170.0;
      
      // Look for gender, if missing in Firebase it stays 'Male'
      gender = pData['gender']?.toString() ?? 'Male';
      
      notifyListeners(); 
    }
    // ... rest of your code for logs ...
  } catch (e) {
    debugPrint("Error: $e");
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

  // Add this inside CalculatorEngine class
Future<void> saveProfileToFirebase() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

 try {
      // UPDATED TO MATCH YOUR DATABASE NAMES
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'weightKg': weight,
        'heightCm': height,
        'gender': gender,
      }, SetOptions(merge: true));
      print("Profile successfully synced!");
    } catch (e) {
    debugPrint("Error saving profile: $e");
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