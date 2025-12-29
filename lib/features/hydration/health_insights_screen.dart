import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/calculator_engine.dart';
import '../widgets/macro_bar.dart';

class HealthInsightsScreen extends StatelessWidget {
  const HealthInsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // This connects to Member 2's data engine
    final engine = Provider.of<CalculatorEngine>(context);
                final emergencyMessage = engine.getEmergencyFix();

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: const Text("Diet Gap Analysis", style: TextStyle(color: Color(0xFFAAF0D1))),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [

            const Text(
      "DAILY NUTRIENT ACCUMULATION",
      style: TextStyle(
        letterSpacing: 2,
        fontWeight: FontWeight.bold,
        color: Colors.white54,
        fontSize: 12,
      ),
    ),
    Text(
      "Tracking your progress for ${DateTime.now().day} ${_getMonth(DateTime.now().month)}",
      style: const TextStyle(color: const Color(0xFF7EE081), fontSize: 16),
    ),
            const SizedBox(height: 20),
            

// Inside the Column, before the charts:
if (emergencyMessage.isNotEmpty)
  _buildInfoCard(
    "Last Minute Action 🏃‍♂️",
    emergencyMessage,
    Colors.redAccent,
  ),
            // PROTEIN CHART
            MacroBar(
              label: "TOTAL DAILY PROTEIN",
              current: engine.currentProtein,
              goal: engine.proteinGoal,
              barColor: const Color(0xFFAAF0D1), // Mint Green
            ),

            // CARBS CHART
            MacroBar(
              label: "TOTAL DAILY CARBS",
              current: engine.currentCarbs,
              goal: engine.carbGoal,
              barColor: const Color(0xFF4FC3F7), // Neon Blue
            ),

            

            const SizedBox(height: 30),

            // DYNAMIC RECOMMENDATIONS
            _buildInfoCard(
              "Campus Food Fix 🥪",
              engine.currentProtein < (engine.proteinGoal * 0.5)
                  ? "You've missed half your protein! Try a double serving of Paneer or a protein shake at the kiosk."
                  : "Great progress! Grab a handful of nuts to stay on track.",
              const Color(0xFFAAF0D1),
            ),

            // Inside health_insights_screen.dart Column

// PROTEIN RISK ALERT
_buildInfoCard(
  "Protein Deficiency Risks ⚠️",
  engine.currentProtein < (engine.proteinGoal * 0.4)
      ? "Critical Low! Lack of protein can lead to hair loss, muscle wasting, and a weakened immune system."
      : "Your protein intake is protecting your muscle mass and skin health. Keep it up!",
  engine.currentProtein < (engine.proteinGoal * 0.4) ? Colors.redAccent : Colors.greenAccent,
),

// CARBS/ENERGY RISK ALERT
_buildInfoCard(
  "Energy Analysis ⚡",
  engine.currentCarbs < (engine.carbGoal * 0.3)
      ? "Low Energy Alert: You may experience 'brain fog', extreme fatigue, and dizziness during lectures."
      : "Glucose levels are stable. You have enough fuel for mental focus.",
  engine.currentCarbs < (engine.carbGoal * 0.3) ? Colors.orangeAccent : Colors.blueAccent,
),
          ],
        ),
      ),
    );
  }
  
Widget _buildMealChecklist(CalculatorEngine engine) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _mealStatus("Breakfast", engine.currentProtein > 0), 
        _mealStatus("Lunch", engine.currentProtein > 30), // Example logic
        _mealStatus("Snacks", false),
        _mealStatus("Dinner", false),
      ],
    );
  }

  Widget _mealStatus(String label, bool isDone) {
    return Column(
      children: [
        Icon(isDone ? Icons.check_circle : Icons.radio_button_unchecked, 
             color: isDone ? Colors.green : Colors.white24),
        Text(label, style: TextStyle(color: isDone ? Colors.white : Colors.white24, fontSize: 10)),
      ],
    );
  }


  Widget _buildInfoCard(String title, String content, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(content, style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }
  String _getMonth(int m) => ["", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"][m];
}