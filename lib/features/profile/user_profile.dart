class UserProfile {
  final String uid;
  final String gender; // 'Male' or 'Female'
  final int age;
  final double heightCm;
  final double weightKg;
  final String activityLevel; // 'Sedentary', 'Moderate', 'Active'
  
  // Calculated Goals
  final int dailyCalorieTarget;
  final int dailyProteinTarget;
  final int dailyWaterTarget; // in ml

  UserProfile({
    required this.uid,
    required this.gender,
    required this.age,
    required this.heightCm,
    required this.weightKg,
    required this.activityLevel,
    required this.dailyCalorieTarget,
    required this.dailyProteinTarget,
    required this.dailyWaterTarget,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'gender': gender,
      'age': age,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'activityLevel': activityLevel,
      'dailyCalorieTarget': dailyCalorieTarget,
      'dailyProteinTarget': dailyProteinTarget,
      'dailyWaterTarget': dailyWaterTarget,
    };
  }
}