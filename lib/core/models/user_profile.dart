class UserProfile {
  final String uid;
  final String gender;
  final int age;
  final double heightCm;
  final double weightKg;
  final String activityLevel;
  
  final String goal; 
  final int dailyCarbTarget;
  final int dailyFatTarget;
  
  final double bmi;
  final int dailyCalorieTarget;
  final int dailyProteinTarget;
  final int dailyWaterTarget;

  UserProfile({
    required this.uid,
    required this.gender,
    required this.age,
    required this.heightCm,
    required this.weightKg,
    required this.activityLevel,
    this.goal = 'Maintain',        // Default value
    this.bmi = 0.0,
    this.dailyCalorieTarget = 0,
    this.dailyProteinTarget = 0,
    this.dailyCarbTarget = 0,    // Default value
    this.dailyFatTarget = 0,      // Default value
    this.dailyWaterTarget = 0,
  });


  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'gender': gender,
      'age': age,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'activityLevel': activityLevel,
      'goal': goal,                 // Saving the goal
      'bmi': bmi,
      'dailyCalorieTarget': dailyCalorieTarget,
      'dailyProteinTarget': dailyProteinTarget,
      'dailyCarbTarget': dailyCarbTarget, // Saving carbs
      'dailyFatTarget': dailyFatTarget,   // Saving fats
      'dailyWaterTarget': dailyWaterTarget,
    };
  }

  
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] ?? '',
      gender: map['gender'] ?? 'Male',
      age: map['age'] ?? 0,
      heightCm: (map['heightCm'] ?? 0),
      weightKg: (map['weightKg'] ?? 0),
      activityLevel: map['activityLevel'] ?? 'Moderate',
      goal: map['goal'] ?? 'Maintain', // Loading the goal
      bmi: (map['bmi'] ?? 0.0).toDouble(),
      dailyCalorieTarget: map['dailyCalorieTarget'] ?? 0,
      dailyProteinTarget: map['dailyProteinTarget'] ?? 0,
      dailyCarbTarget: map['dailyCarbTarget'] ?? 0, // Loading carbs
      dailyFatTarget: map['dailyFatTarget'] ?? 0,    // Loading fats
      dailyWaterTarget: map['dailyWaterTarget'] ?? 0,
    );
  }
}