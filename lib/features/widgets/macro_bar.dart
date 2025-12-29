import 'package:flutter/material.dart';

class MacroBar extends StatelessWidget {
  final String label;
  final double current;
  final double goal;
  final Color barColor;

  const MacroBar({
    super.key,
    required this.label,
    required this.current,
    required this.goal,
    required this.barColor,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate percentage (clamped between 0.0 and 1.0)
    double progress = (current / goal).clamp(0.0, 1.0);
    double remaining = goal - current;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              Text("${current.toInt()} / ${goal.toInt()}g", style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            remaining > 0 ? "${remaining.toInt()}g left to hit goal!" : "Goal Achieved! 🔥",
            style: TextStyle(color: barColor.withOpacity(0.8), fontSize: 11, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}