enum Gender { male, female }
enum ActivityLevel { sedentary, light, moderate, high, veryHigh }
enum GoalType { lose, maintain, gain }

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

class HealthCalculator {
  /// Returns [HealthGoals] or null if required data is missing.
  static HealthGoals? calculateGoals({
    required Gender? gender,
    required int? age,
    required double? heightCm,
    required double? weightKg,
    required ActivityLevel? activityLevel,
    required GoalType goalType,
  }) {
    // 1. ERROR PREVENTION: Strict check for missing data
    // If any field is null, we return null immediately. No defaults allowed.
    if (gender == null ||
        age == null ||
        heightCm == null ||
        weightKg == null ||
        activityLevel == null) {
      return null;
    }

    // 2. Calculate BMR (Mifflin-St Jeor Equation)
    double bmr;
    if (gender == Gender.male) {
      bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * age) + 5;
    } else {
      bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * age) - 161;
    }

    // 3. Activity Level Multiplier
    double multiplier;
    switch (activityLevel) {
      case ActivityLevel.sedentary:
        multiplier = 1.2;
        break;
      case ActivityLevel.light:
        multiplier = 1.375;
        break;
      case ActivityLevel.moderate:
        multiplier = 1.55;
        break;
      case ActivityLevel.high:
        multiplier = 1.725;
        break;
      case ActivityLevel.veryHigh:
        multiplier = 1.9;
        break;
    }

    double tdee = bmr * multiplier;

    // 4. Adjust for Goal
    double targetCalories = tdee;
    if (goalType == GoalType.lose) {
      targetCalories -= 500;
    } else if (goalType == GoalType.gain) {
      targetCalories += 500;
    }

    // 5. Calculate Macros & Water
    // Water: ~35ml per kg of body weight
    int waterGoal = (weightKg * 35).round();

    // Macros Split: 30% Protein, 40% Carbs, 30% Fat
    // 1g Protein = 4 cal, 1g Carb = 4 cal, 1g Fat = 9 cal
    int proteinGrams = ((targetCalories * 0.30) / 4).round();
    int carbsGrams = ((targetCalories * 0.40) / 4).round();
    int fatGrams = ((targetCalories * 0.30) / 9).round();

    return HealthGoals(
      calories: targetCalories.round(),
      waterMl: waterGoal,
      protein: proteinGrams,
      carbs: carbsGrams,
      fat: fatGrams,
    );
  }
}