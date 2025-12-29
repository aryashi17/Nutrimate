import 'package:flutter/material.dart';
import '../../core/models/user_profile.dart';

class HealthStatusSection extends StatelessWidget {
  final UserProfile? user; // This allows it to receive 'null' initially

  const HealthStatusSection({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // -----------------------------------------------------------
    // 1. HANDLE NULL CASE (Show "Setup Profile" card)
    // -----------------------------------------------------------
    if (user == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF17201B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.amber.withOpacity(0.5)),
        ),
        child: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.amber),
            SizedBox(width: 12),
            Text("Profile not set up. Tap profile to start!", 
                style: TextStyle(color: Colors.white70)),
          ],
        ),
      );
    }

    // -----------------------------------------------------------
    // 2. CREATE 'SAFE' USER (The Fix for your Red Errors)
    // -----------------------------------------------------------
    // Since we passed the check above, we know 'user' is not null here.
    // We create 'safeUser' using '!' to tell Dart "Trust me, this exists".
    final safeUser = user!; 

    // Now use 'safeUser' for all calculations below!
    
    // Mock Data (Replace with real DB data later)
    int eatenCals = 1250; 
    int eatenProtein = 60; 
    
    // Prevent division by zero
    double proteinTarget = (safeUser.dailyProteinTarget > 0) 
        ? safeUser.dailyProteinTarget.toDouble() 
        : 100.0;
        
    double proteinProgress = (eatenProtein / proteinTarget).clamp(0.0, 1.0);
    
    final Color mint = const Color(0xFF7EE081);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF17201B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          // --- PROTEIN CIRCLE ---
          SizedBox(
            height: 55,
            width: 55,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: proteinProgress,
                  strokeWidth: 6,
                  valueColor: AlwaysStoppedAnimation<Color>(mint),
                  backgroundColor: Colors.white10,
                ),
                Text("${(proteinProgress * 100).toInt()}%", 
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 20),

          // --- STATS TEXT ---
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text("DAILY GOAL", 
                        style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 1.2)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                          color: mint.withOpacity(0.2), 
                          borderRadius: BorderRadius.circular(4)),
                      // Use 'safeUser' here safely
                      child: Text("BMI ${safeUser.bmi}", 
                          style: TextStyle(color: mint, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(text: "$eatenCals", 
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      // Use 'safeUser' here safely
                      TextSpan(text: " / ${safeUser.dailyCalorieTarget} kcal", 
                          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}