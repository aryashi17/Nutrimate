import 'package:flutter/material.dart';
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
  int bottlesCompleted = 0;
bool isUnwell = false;

// Inside CalculatorEngine
bool isExamSeason = false; // Higher carb focus for brain power
bool isWorkoutDay = false; // Higher protein/hydration focus

void toggleSickMode() { isUnwell = !isUnwell; notifyListeners(); }
void toggleExamMode() { isExamSeason = !isExamSeason; notifyListeners(); }
void toggleWorkoutMode() { isWorkoutDay = !isWorkoutDay; notifyListeners(); }
  // --- USER PROFILE DATA ---
  double weight = 0.0; 
  double height = 0.0;
  int age = 0;          // <--- ADDED: Age Field
  String gender = 'Male'; // Default to Male to ensure math works

  // --- 1. DYNAMIC HYDRATION GOAL ---
  int get dynamicGoal {
    // Basic formula: 35ml per kg
    double baseGoal = weight * 35;
    
    // Adjust for gender 
    if (gender == 'Male') {
      baseGoal += 500; 
    }
    
    // Adjust for height 
    if (height > 180) {
      baseGoal += 300;
    }

    // Adjust for Age (Older adults often need reminders, but physiological need decreases slightly)
    // We will keep it simple for now, but you can add logic here.
    
    return baseGoal.toInt();
  }

  // Getter for UI access
int get goal {
    // Basic formula: 35ml per kg
    double baseGoal = weight * 35;
    
    if (gender == 'Male') baseGoal += 500; 
    if (height > 180) baseGoal += 300;
    
    int finalGoal = baseGoal.toInt();
    
    // Extra fluids for recovery if sick
    if (isUnwell) return finalGoal + 500; 
    
    return finalGoal;
  }
  // --- 2. DYNAMIC CALORIE & MACRO GOALS (Uses Age) ---
  
  // Calculate BMR (Mifflin-St Jeor Equation)
  double get bmr {
    if (weight == 0 || height == 0 || age == 0) return 2000.0; // Default if no data

    // Formula: (10 × weight) + (6.25 × height) - (5 × age) + s
    double base = (10 * weight) + (6.25 * height) - (5 * age);
    
    if (gender == 'Male') {
      return base + 5;
    } else {
      return base - 161;
    }
  }

  // Daily Maintenance Calories (Assuming Sedentary/Student lifestyle x 1.2)
  double get dailyCalorieGoal => bmr * 1.2;

  // Macro Goals based on Calorie Goal
  double get proteinGoal {
  double base = (weight * 1.8);
  // If it's a gym day, we need more repair fuel!
  if (isWorkoutDay) return base + 20; 
  // If sick, body focuses on recovery, not muscle building
  if (isUnwell) return base - 10;
  return base;
}

double get carbGoal {
  double base = (dailyCalorieGoal * 0.50) / 4;
  // Brain fuel for exams!
  if (isExamSeason) return base + 40; 
  return base;
}


  double get fatGoal => (dailyCalorieGoal * 0.25) / 9; // 25% of diet from fats, divide by 9 cal/g

  // --- 3. CURRENT PROGRESS VARIABLES ---
  double breakfastProtein = 0.0;
  double lunchProtein = 0.0;
  double snackProtein = 0.0;
  double dinnerProtein = 0.0;

  double get totalProtein => breakfastProtein + lunchProtein + snackProtein + dinnerProtein;
  double get currentProtein => totalProtein;
  double currentCarbs = 0.0;
  double currentCalories = 0.0;
  
  DateTime lastResetDate = DateTime.now();

  // --- 4. UPDATE LOCAL DATA ---
  void updateProfile({double? newWeight, double? newHeight, String? newGender, int? newAge}) {
    if (newWeight != null) weight = newWeight; 
    if (newHeight != null) height = newHeight;
    if (newGender != null) gender = newGender;
    if (newAge != null) age = newAge; // <--- ADDED: Handle Age update

    notifyListeners(); 
  }

  // --- 5. LOGIC: ADD WATER ---
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

  // --- 6. LOGIC: RESET FOR NEW DAY ---
  void checkAndResetForNewDay() {
    final now = DateTime.now();
    if (now.day != lastResetDate.day || now.month != lastResetDate.month) {
      // Clear meal specific data
      breakfastProtein = 0.0;
      lunchProtein = 0.0;
      snackProtein = 0.0;
      dinnerProtein = 0.0;
      
      currentCarbs = 0.0;
      currentCalories = 0.0;
      totalDrank = 0;
      bottlesCompleted = 0;
      lastResetDate = now;
      notifyListeners();
    }
  }

  // --- 7. FIREBASE: FETCH INITIAL DATA ---
  Future<void> fetchInitialData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final profileDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      
      if (profileDoc.exists) {
        final pData = profileDoc.data()!;
        
        weight = double.tryParse(pData['weightKg'].toString()) ?? 0.0;
        height = double.tryParse(pData['heightCm'].toString()) ?? 0.0;
        
        // Fix: Ensure Gender falls back to Male if missing
        gender = pData['gender']?.toString() ?? 'Male';
        
        // <--- ADDED: Fetch Age
        age = int.tryParse(pData['age'].toString()) ?? 0;
        
        notifyListeners(); 
      }
    } catch (e) {
      debugPrint("Error fetching data: $e");
    }
  }

  // --- 8. FIREBASE: SAVE PROFILE ---
  Future<void> saveProfileToFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'weightKg': weight,
        'heightCm': height,
        'gender': gender,
        'age': age, // <--- ADDED: Save Age to DB
      }, SetOptions(merge: true));
      
      print("Profile successfully synced!");
    } catch (e) {
      debugPrint("Error saving profile: $e");
    }
  }

  // --- 9. FIREBASE: SYNC WATER ---
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

  // --- 10. FOOD LOGGING LOGIC ---
  final Map<String, Map<String, double>> foodLibrary = {
    "Paneer": {"p": 25.0, "c": 10.0},
    "Rice": {"p": 5.0, "c": 45.0},
    "Dal": {"p": 12.0, "c": 25.0},
    "Eggs": {"p": 18.0, "c": 2.0},
    "Chicken": {"p": 30.0, "c": 0.0},
    "Oats": {"p": 10.0, "c": 50.0},
    "Roti": {"p": 4.0, "c": 20.0},
  };

  Future<void> addFood(String name, double portion, String mealType) async {
    checkAndResetForNewDay();
    
    final nutrients = foodLibrary.entries
        .firstWhere((e) => name.contains(e.key), 
        orElse: () => const MapEntry("Other", {"p": 10.0, "c": 30.0}))
        .value;

    double proteinToAdd = (nutrients["p"] ?? 0.0) * portion;
    
    if (mealType == 'Breakfast') breakfastProtein += proteinToAdd;
    else if (mealType == 'Lunch') lunchProtein += proteinToAdd;
    else if (mealType == 'Snacks') snackProtein += proteinToAdd;
    else if (mealType == 'Dinner') dinnerProtein += proteinToAdd;

    currentCarbs += (nutrients["c"] ?? 0.0) * portion;
    currentCalories += proteinToAdd * 4 + (nutrients["c"] ?? 0.0) * portion * 4;

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
          'totalProtein': totalProtein,
          'totalCarbs': currentCarbs,
          'totalCalories': currentCalories,
          'dateLabel': "${DateTime.now().day} ${MonthLabels.short[DateTime.now().month]}",
        }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('Error syncing food: $e');
    }
  }

  // --- 11. EMERGENCY FIX HELPER ---
  String getEmergencyFix() {
    final hour = DateTime.now().hour;
    // Calculate percentages to make logic more precise
    double proteinPercent = (proteinGoal > 0) ? (totalProtein / proteinGoal) : 1.0;
    double carbPercent = (carbGoal > 0) ? (currentCarbs / carbGoal) : 1.0;

    // PRIORITY 1: SICKNESS (Global Override)
    if (isUnwell) {
      return "🤒 Sick Bay Mode: Stick to Electrol & Dal Khichdi. Your body needs easy-to-digest fuel right now.";
    }

    // PRIORITY 2: EXAM SEASON (Brain Fuel focus)
    if (isExamSeason && carbPercent < 0.5 && hour < 18) {
      return "🧠 Study Mode: Your brain runs on glucose. Grab a fruit or some Oats from Nescafe to keep that focus sharp!";
    }

    // PRIORITY 3: CRITICAL DEFICITS (Regardless of time)
    if (proteinPercent < 0.3 && hour > 12) {
      return "🚨 Muscle Alert: You've barely hit 30% protein and half the day is gone. Get a double paneer/chicken serving at lunch ASAP.";
    }

    // PRIORITY 4: TIME-BASED CAMPUS SPECIFICS
    if (hour >= 21) { // Late Night
       if (proteinPercent < 0.8) {
         return "🌙 Late Night Recovery: Mess is closed. Grab a Peanut Butter sandwich or milk from the night canteen.";
       }
       return "✅ Recovery Ready: You've fueled well. Time for sleep!";
    }

    if (hour >= 16 && hour < 19) { // Snack Time
      if (isWorkoutDay) return "🏋️ Post-Gym: Grab some boiled eggs or a protein shake from the kiosk now!";
      return "☕ Tea Time: Pair your chai with roasted chana instead of biscuits for better macros.";
    }

    return "✅ Campus Fix: Your stats look solid for this time of day. Keep it steady!";
  }


}

class MonthLabels {
  static const Map<int, String> short = {
    1: 'Jan', 2: 'Feb', 3: 'Mar', 4: 'Apr', 5: 'May', 6: 'Jun',
    7: 'Jul', 8: 'Aug', 9: 'Sep', 10: 'Oct', 11: 'Nov', 12: 'Dec',
  };
}