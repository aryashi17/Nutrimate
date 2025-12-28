import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/models/user_profile.dart';
import '../../core/models/meal_log_entry.dart'; // <--- USING THE MASTER MODEL
import '../profile/profile_screen.dart';
import '../scanner/add_food_screen.dart'; 

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  DateTime get _startOfDay {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final mint = const Color(0xFFAAF0D1);

    if (user == null) return const Scaffold(body: Center(child: Text("Please Login")));

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Welcome Back,", style: TextStyle(color: Colors.white54, fontSize: 14)),
            Text("Let's crush it!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.white),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
          ),
        ],
      ),
      // 1. First Stream: Get User GOALS
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: mint));
          }
          if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
            return const Center(child: Text("Profile not found."));
          }

          UserProfile profile = UserProfile.fromMap(userSnapshot.data!.data() as Map<String, dynamic>);

          // 2. Second Stream: Get Food Logs for TODAY
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .collection('food_logs') // <--- ENSURE ALL LOGS SAVE HERE
                .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(_startOfDay))
                .snapshots(),
            builder: (context, foodSnapshot) {
              
              int currentCalories = 0;
              int currentProtein = 0;
              int currentCarbs = 0;
              int currentFat = 0;

              if (foodSnapshot.hasData && foodSnapshot.data!.docs.isNotEmpty) {
                for (var doc in foodSnapshot.data!.docs) {
                  // HERE IS THE FIX: Use MealLogEntry safely
                  var food =meal_log_entry.fromMap(doc.data() as Map<String, dynamic>, doc.id);
                  currentCalories += food.calories;
                  currentProtein += food.protein;
                  currentCarbs += food.carbs;
                  currentFat += food.fat;
                }
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCalorieCard(profile, currentCalories, mint),
                    const SizedBox(height: 25),
                    const Text("Today's Macros", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(child: _buildMacroCard("Protein", currentProtein, profile.dailyProteinTarget, Colors.blueAccent)),
                        const SizedBox(width: 15),
                        Expanded(child: _buildMacroCard("Carbs", currentCarbs, profile.dailyCarbTarget, Colors.orangeAccent)),
                        const SizedBox(width: 15),
                        Expanded(child: _buildMacroCard("Fat", currentFat, profile.dailyFatTarget, Colors.redAccent)),
                      ],
                    ),
                    const SizedBox(height: 25),
                    _buildWaterCard(profile.dailyWaterTarget, mint),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // --- WIDGET HELPERS ---
  Widget _buildCalorieCard(UserProfile profile, int current, Color color) {
    double progress = profile.dailyCalorieTarget > 0 ? current / profile.dailyCalorieTarget : 0;
    int remaining = profile.dailyCalorieTarget - current;
    if (remaining < 0) remaining = 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          SizedBox(
            height: 100, width: 100,
            child: Stack(
              children: [
                Center(child: CircularProgressIndicator(
                  value: progress > 1 ? 1 : progress, 
                  strokeWidth: 10, 
                  backgroundColor: Colors.white10, 
                  color: color
                )),
                Center(child: Icon(Icons.local_fire_department, color: color, size: 40)),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Calories Left", style: TextStyle(color: Colors.white54, fontSize: 14)),
              Text("$remaining", style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
              Text("Goal: ${profile.dailyCalorieTarget}", style: const TextStyle(color: Colors.white38, fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMacroCard(String label, int current, int target, Color color) {
    double progress = target == 0 ? 0 : current / target;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("$current / $target g", style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          LinearProgressIndicator(value: progress > 1 ? 1 : progress, backgroundColor: Colors.white10, color: color),
        ],
      ),
    );
  }

  Widget _buildWaterCard(int targetMl, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blue.shade900.withValues(alpha: 0.4), const Color(0xFF1E1E1E)]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Hydration", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              Text("Goal: ${(targetMl / 1000).toStringAsFixed(1)}L", style: const TextStyle(color: Colors.white54)),
            ],
          ),
          const Icon(Icons.water_drop, color: Colors.blue, size: 30),
        ],
      ),
    );
  }
}