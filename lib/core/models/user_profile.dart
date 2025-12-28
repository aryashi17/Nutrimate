class UserProfile {
  final String uid;
  final String gender;
  final int age;
  final double heightCm;
  final double weightKg;
  final String activityLevel;
  
  // --- NEW FIELDS (These are what you are missing!) ---
  final String goal; 
  final int dailyCarbTarget;
  final int dailyFatTarget;
  // ---------------------------------------------------

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
    this.dailyCalorieTarget = 2000,
    this.dailyProteinTarget = 100,
    this.dailyCarbTarget = 250,    // Default value
    this.dailyFatTarget = 60,      // Default value
    this.dailyWaterTarget = 3000,
  });

  // Convert to Map for Firestore
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

  // Create from Map (Reading from Firestore)
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] ?? '',
      gender: map['gender'] ?? 'Male',
      age: map['age'] ?? 20,
      heightCm: (map['heightCm'] ?? 170).toDouble(),
      weightKg: (map['weightKg'] ?? 70).toDouble(),
      activityLevel: map['activityLevel'] ?? 'Moderate',
      goal: map['goal'] ?? 'Maintain', // Loading the goal
      bmi: (map['bmi'] ?? 0.0).toDouble(),
      dailyCalorieTarget: map['dailyCalorieTarget'] ?? 2000,
      dailyProteinTarget: map['dailyProteinTarget'] ?? 100,
      dailyCarbTarget: map['dailyCarbTarget'] ?? 250, // Loading carbs
      dailyFatTarget: map['dailyFatTarget'] ?? 60,    // Loading fats
      dailyWaterTarget: map['dailyWaterTarget'] ?? 3000,
    );
  }
}