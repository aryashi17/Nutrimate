import 'dart:math';
// Ensure this path matches where you created your enums file
import '../enums/app_enums.dart'; 

// =============================================================================
// 1. DATA MODEL: HEALTH GOALS
// =============================================================================
class HealthGoals {
  final int calories;
  final int waterMl;
  final int protein;
  final int carbs;
  final int fat;

  HealthGoals({
    required this.calories,
    required this.waterMl,
    required this.protein,
    required this.carbs,
    required this.fat,
  });
}

// =============================================================================
// 2. THE CALCULATOR CLASS
// =============================================================================
class HealthCalculator {

  // ---------------------------------------------------------------------------
  // PRIMARY FUNCTION: CALCULATE EVERYTHING (Used by Profile Form)
  // ---------------------------------------------------------------------------
  static HealthGoals? calculateGoals({
    required Gender? gender,
    required int? age,
    required double? heightCm,
    required double? weightKg,
    required ActivityLevel? activityLevel,
    required GoalType goalType,
  }) {
    // A. ERROR PREVENTION
    if (gender == null || age == null || heightCm == null || weightKg == null || activityLevel == null) {
      return null;
    }

    // B. Calculate BMR (Mifflin-St Jeor)
    // We convert the Enum to a String ('Male'/'Female') to reuse our helper function
    String genderStr = (gender == Gender.male) ? 'Male' : 'Female';
    int bmr = calculateBMR(genderStr, age, heightCm, weightKg);

    // C. Activity Multiplier (Reuse helper or inline)
    // We map the Enum to the String expected by calculateTDEE
    String activityStr = _mapActivityEnumToString(activityLevel);
    int tdee = calculateTDEE(bmr, activityStr);

    // D. Adjust for Goal
    // We map the GoalEnum to String
    String goalStr = _mapGoalEnumToString(goalType);
    int targetCalories = adjustCaloriesForGoal(tdee, goalStr);

    // E. Macros & Water
    Map<String, int> macros = calculateMacros(targetCalories, goalStr);
    int water = calculateWater(weightKg);

    return HealthGoals(
      calories: targetCalories,
      waterMl: water,
      protein: macros['protein'] ?? 0,
      carbs: macros['carbs'] ?? 0,
      fat: macros['fats'] ?? 0, // Note: Helper returns 'fats', model expects 'fat'
    );
  }

  // ---------------------------------------------------------------------------
  // HELPER 1: BMI Calculation
  // ---------------------------------------------------------------------------
  static double calculateBMI(double heightCm, double weightKg) {
    double heightM = heightCm / 100;
    if (heightM <= 0) return 0.0;
    return double.parse((weightKg / (heightM * heightM)).toStringAsFixed(1));
  }

  // ---------------------------------------------------------------------------
  // HELPER 2: BASIC METABOLIC RATE (Mifflin-St Jeor Formula)
  // ---------------------------------------------------------------------------
  static int calculateBMR(String gender, int age, double heightCm, double weightKg) {
    // Formula: (10 * weight) + (6.25 * height) - (5 * age) + s
    // s is +5 for males and -161 for females
    double bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * age);
    bmr += (gender == 'Male') ? 5 : -161;
    return bmr.round();
  }

  // ---------------------------------------------------------------------------
  // HELPER 3: TOTAL DAILY ENERGY EXPENDITURE (TDEE)
  // ---------------------------------------------------------------------------
  static int calculateTDEE(int bmr, String activityLevel) {
    double multiplier;
    switch (activityLevel) {
      case 'Sedentary': multiplier = 1.2; break;
      case 'Lightly Active': multiplier = 1.375; break;
      case 'Moderate': multiplier = 1.55; break;
      case 'Very Active': multiplier = 1.725; break;
      case 'Super Active': multiplier = 1.9; break;
      default: multiplier = 1.2;
    }
    return (bmr * multiplier).round();
  }

  // ---------------------------------------------------------------------------
  // HELPER 4: ADJUST CALORIES FOR GOAL
  // ---------------------------------------------------------------------------
  static int adjustCaloriesForGoal(int tdee, String goal) {
    if (goal == 'Weight Loss') return tdee - 500; // Caloric Deficit
    if (goal == 'Muscle Gain') return tdee + 300; // Caloric Surplus (Adjusted to safer +300)
    return tdee; // Maintain
  }

  // ---------------------------------------------------------------------------
  // HELPER 5: CALCULATE MACROS
  // ---------------------------------------------------------------------------
  static Map<String, int> calculateMacros(int targetCalories, String goal) {
    double proteinRatio = 0.30;
    double fatRatio = 0.25; // Adjusted slightly for balance
    double carbRatio = 0.45;

    if (goal == 'Muscle Gain') {
      proteinRatio = 0.35;
      carbRatio = 0.45;
      fatRatio = 0.20;
    } else if (goal == 'Weight Loss') {
      proteinRatio = 0.40;
      carbRatio = 0.35;
      fatRatio = 0.25;
    }

    int protein = (targetCalories * proteinRatio / 4).round();
    int fats = (targetCalories * fatRatio / 9).round();
    int carbs = (targetCalories * carbRatio / 4).round();

    return {
      'protein': protein,
      'fats': fats,
      'carbs': carbs,
    };
  }

  // ---------------------------------------------------------------------------
  // HELPER 6: WATER TARGET
  // ---------------------------------------------------------------------------
  static int calculateWater(double weightKg) {
    return (weightKg * 35).round();
  }

  // ---------------------------------------------------------------------------
  // HELPER 7: BODY FAT PERCENTAGE (US Navy Formula)
  // ---------------------------------------------------------------------------
  static double calculateBodyFat(String gender, double heightCm, double neckCm, double waistCm, double hipCm) {
    if (gender == 'Male') {
      return 495 / (1.0324 - 0.19077 * log(waistCm - neckCm) / ln10 + 0.15456 * log(heightCm) / ln10) - 450;
    } else {
      return 495 / (1.29579 - 0.35004 * log(waistCm + hipCm - neckCm) / ln10 + 0.22100 * log(heightCm) / ln10) - 450;
    }
  }

  // ---------------------------------------------------------------------------
  // HELPER 8: INTERNAL MAPPERS (Enum -> String)
  // ---------------------------------------------------------------------------
  static String _mapActivityEnumToString(ActivityLevel level) {
    switch (level) {
      case ActivityLevel.sedentary: return 'Sedentary';
      case ActivityLevel.light: return 'Lightly Active';
      case ActivityLevel.moderate: return 'Moderate';
      case ActivityLevel.high: return 'Very Active';
      case ActivityLevel.veryHigh: return 'Super Active';
    }
  }

  static String _mapGoalEnumToString(GoalType goal) {
    switch (goal) {
      case GoalType.lose: return 'Weight Loss';
      case GoalType.gain: return 'Muscle Gain';
      case GoalType.maintain: return 'Maintain';
    }
  }
}