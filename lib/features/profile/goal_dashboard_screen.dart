import 'package:flutter/material.dart';
import '../../core/services/health_calculator.dart'; 
import '../../core/enums/app_enums.dart';
// Make sure this import path matches your project structure
import 'package:nutrimate_app/features/reports/summary_screen.dart'; 

class GoalsDashboard extends StatelessWidget {
  // Assume these come from your User State / Provider / Database
  final Gender? userGender;
  final int? userAge;
  final double? userHeight;
  final double? userWeight;
  final ActivityLevel? userActivity;
  final GoalType userGoalType;

  const GoalsDashboard({
    super.key,
    required this.userGender,
    required this.userAge,
    required this.userHeight,
    required this.userWeight,
    required this.userActivity,
    this.userGoalType = GoalType.lose,
  });

  @override
  Widget build(BuildContext context) {
    // Attempt calculation
    final goals = HealthCalculator.calculateGoals(
      gender: userGender,
      age: userAge,
      heightCm: userHeight,
      weightKg: userWeight,
      activityLevel: userActivity,
      goalType: userGoalType,
    );

    // GUARD CLAUSE: If goals are null, show the "Setup" UI
    if (goals == null) {
      return _buildSetupCard(context);
    }

    // HAPPY PATH: Show the dashboard
    return Scaffold(
      appBar: AppBar(title: const Text("Your Daily Plan")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 1. Calories Card
              _buildStatCard("Calories", "${goals.calories} kcal", Colors.orange),
              const SizedBox(height: 10),
              
              // 2. Water Card
              _buildStatCard("Water", "${goals.waterMl} ml", Colors.blue),
              const SizedBox(height: 20),
              
              // 3. Macros Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMacro("Protein", "${goals.protein}g"),
                  _buildMacro("Carbs", "${goals.carbs}g"),
                  _buildMacro("Fats", "${goals.fat}g"),
                ],
              ),

              const SizedBox(height: 30), // Spacing before the new button

              // 4. NEW FEATURE: Summary Card
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SummaryScreen()));
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    // Gradient for a premium look
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6A11CB), Color(0xFF2575FC)], 
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2575FC).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.insights, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 20),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "View Summary",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Check your daily progress",
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSetupCard(BuildContext context) {
    return Center(
      child: Card(
        color: Colors.red.shade50,
        margin: const EdgeInsets.all(20),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded, size: 50, color: Colors.red),
              const SizedBox(height: 10),
              const Text(
                "Profile Incomplete",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "We cannot calculate your personalized health goals without your exact weight, height, and age.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                   
                },
                child: const Text("Complete Profile Now"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(color: color, fontSize: 16)),
          Text(value, style: TextStyle(color: color, fontSize: 28, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildMacro(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}