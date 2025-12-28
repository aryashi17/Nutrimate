import 'dart:math';

class HealthCalculator {
  
  // ---------------------------------------------------------------------------
  // 1. BASIC METABOLIC RATE (Mifflin-St Jeor Formula)
  // ---------------------------------------------------------------------------
  static int calculateBMR(String gender, int age, double height, double weight) {
    double bmr;
    if (gender == 'Male') {
      // 10*weight + 6.25*height - 5*age + 5
      bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      // 10*weight + 6.25*height - 5*age - 161
      bmr = (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }
    return bmr.round();
  }

  // ---------------------------------------------------------------------------
  // 2. TOTAL DAILY ENERGY EXPENDITURE (TDEE)
  // ---------------------------------------------------------------------------
  static int calculateTDEE(int bmr, String activityLevel) {
    double multiplier;
    switch (activityLevel) {
      case 'Sedentary':
        multiplier = 1.2;
        break;
      case 'Lightly Active':
        multiplier = 1.375;
        break;
      case 'Moderate':
        multiplier = 1.55;
        break;
      case 'Very Active':
        multiplier = 1.725;
        break;
      case 'Super Active':
        multiplier = 1.9;
        break;
      default:
        multiplier = 1.2;
    }
    return (bmr * multiplier).round();
  }

  // ---------------------------------------------------------------------------
  // 3. DAILY WATER TARGET (in ml)
  // ---------------------------------------------------------------------------
  static int calculateWater(double weight) {
    // Standard rule: ~35ml per kg of body weight
    return (weight * 35).round();
  }

  // ---------------------------------------------------------------------------
  // 4. BODY FAT PERCENTAGE (US Navy Formula)
  // ---------------------------------------------------------------------------
  static double calculateBodyFat(String gender, double heightCm, double neckCm, double waistCm, double hipCm) {
    if (gender == 'Male') {
      // Male Formula: 495 / (1.0324 - 0.19077(log(waist-neck)) + 0.15456(log(height))) - 450
      return 495 / (1.0324 - 0.19077 * log(waistCm - neckCm) / ln10 + 0.15456 * log(heightCm) / ln10) - 450;
    } else {
      // Female Formula: 495 / (1.29579 - 0.35004(log(waist+hip-neck)) + 0.22100(log(height))) - 450
      return 495 / (1.29579 - 0.35004 * log(waistCm + hipCm - neckCm) / ln10 + 0.22100 * log(heightCm) / ln10) - 450;
    }
  }

  // ---------------------------------------------------------------------------
  // 5. FAT CATEGORY
  // ---------------------------------------------------------------------------
  static String getBodyFatCategory(String gender, double percent) {
    if (gender == 'Male') {
      if (percent < 6) return "Essential Fat";
      if (percent < 14) return "Athlete";
      if (percent < 18) return "Fitness";
      if (percent < 25) return "Average";
      return "Needs Attention";
    } else {
      if (percent < 14) return "Essential Fat";
      if (percent < 21) return "Athlete";
      if (percent < 25) return "Fitness";
      if (percent < 32) return "Average";
      return "Needs Attention";
    }
  }

  // ---------------------------------------------------------------------------
  // 6. DIET SUGGESTION
  // ---------------------------------------------------------------------------
  static String suggestDiet(String fatCategory, String activityLevel) {
    if (fatCategory == "Needs Attention") return "Low Carb / High Fiber";
    if (activityLevel == "Very Active" || activityLevel == "Super Active" || fatCategory == "Athlete") {
      return "High Protein / Carb Cycling";
    }
    return "Balanced Zone Diet";
  }
}