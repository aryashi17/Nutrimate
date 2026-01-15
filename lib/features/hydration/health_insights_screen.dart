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


    final proteinPercent = engine.proteinGoal > 0 ? (engine.totalProtein / engine.proteinGoal) : 0.0;
final carbPercent = engine.carbGoal > 0 ? (engine.currentCarbs / engine.carbGoal) : 0.0;
Color energyColor = (carbPercent < 0.3) ? Colors.orangeAccent : Colors.blueAccent;

  Color fixColor = const Color(0xFFAAF0D1); // Default Mint
  if (proteinPercent < 0.4) {
    fixColor = Colors.redAccent; // Urgent
  } else if (proteinPercent < 0.7) {
    fixColor = Colors.orangeAccent; // Warning
  }
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

            const SizedBox(height: 40), // Spacing for status bar
          
          // --- C. EMPTY STATE / MOTIVATION TEXT ---
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              engine.totalProtein == 0 && engine.currentCarbs == 0
                  ? "Your digital thali is empty! 🍽️\nHead to breakfast to start your fuel graph."
                  : "Keep pushing toward your targets!",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 14, fontStyle: FontStyle.italic),
            ),
          ),
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
      style: const TextStyle(color: Color(0xFF7EE081), fontSize: 16),
    ),

    const SizedBox(height: 25), // Spacing

// --- INSERT THIS BLOCK HERE ---
const Text(
  "SELECT CURRENT VIBE",
  style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2),
),
const SizedBox(height: 12),
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    _buildVibeChip(engine.isExamSeason, "📚 Exams", engine.toggleExamMode, Colors.blueAccent),
    const SizedBox(width: 10),
    _buildVibeChip(engine.isWorkoutDay, "💪 Gym", engine.toggleWorkoutMode, Colors.greenAccent),
    const SizedBox(width: 10),
    _buildVibeChip(engine.isUnwell, "🤒 Sick", engine.toggleSickMode, Colors.orangeAccent),
  ],
),
// --- END OF INSERTION ---

            const SizedBox(height: 20),
            _buildMealChecklist(engine), 
    const SizedBox(height: 20),

// Inside the Column, before the charts:
_buildInfoCard(
  "Campus Food Fix 🥪",
  emergencyMessage, // This variable was created at the top of build()
  fixColor,        // This variable was created at the top of build()
),
            // PROTEIN CHART
            MacroBar(
              label: "TOTAL DAILY PROTEIN",
              current: engine.totalProtein,
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


            // Inside health_insights_screen.dart Column

// PROTEIN RISK ALERT
_buildInfoCard(
  "Protein Deficiency Risks ⚠️",
  engine.totalProtein < (engine.proteinGoal * 0.4)
      ? "Critical Low! Lack of protein can lead to muscle wasting."
      : "Your protein intake is protecting your muscle mass.",
  // Use fixColor here too for consistency!
  proteinPercent < 0.4 ? Colors.redAccent : Colors.greenAccent, 
),

_buildInfoCard(
  "Energy Analysis ⚡",
  engine.currentCarbs < (engine.carbGoal * 0.3)
      ? "Low Energy Alert: You may experience 'brain fog' during lectures."
      : "Glucose levels are stable. You have enough fuel for mental focus.",
  energyColor, // Use the variable you created at the top!
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
      _mealStatus("Breakfast", engine.breakfastProtein > 0), 
      _mealStatus("Lunch", engine.lunchProtein > 0),
      _mealStatus("Snacks", engine.snackProtein > 0),
      _mealStatus("Dinner", engine.dinnerProtein > 0),
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

  Widget _buildVibeChip(bool isActive, String label, VoidCallback onTap, Color activeColor) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? activeColor.withOpacity(0.15) : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isActive ? activeColor : Colors.white10,
          width: 1.5,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? activeColor : Colors.white60,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}
}