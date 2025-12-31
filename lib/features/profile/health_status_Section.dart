import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/user_profile.dart';
import '../../core/services/calculator_engine.dart';

class HealthStatusSection extends StatelessWidget {
  final UserProfile? user; // Allows null for "Not set up" state

  const HealthStatusSection({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<CalculatorEngine>();

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
            Expanded(
              child: Text(
                "Profile not set up. Tap profile to start!", 
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      );
    }

    final UserProfile safeUser = user!; 

    // -----------------------------------------------------------
    // 3. CALCULATE STATS
    // -----------------------------------------------------------
    int eatenCals = engine.currentCalories.toInt(); 
    int eatenProtein = engine.currentProtein.toInt(); 
    
    // Prevent division by zero
    double proteinTarget = (safeUser.dailyProteinTarget > 0) 
        ? safeUser.dailyProteinTarget.toDouble() 
        : 100.0;
        
    double proteinProgress = (eatenProtein / proteinTarget).clamp(0.0, 1.0);
    
    final Color mint = const Color(0xFF7EE081);

    // -----------------------------------------------------------
    // 4. RENDER UI
    // -----------------------------------------------------------
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
                      // Now 'safeUser' works because we defined it above
                      child: Text("BMI ${safeUser.bmi.toStringAsFixed(1)}", 
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