import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nutrimate_app/core/services/calculator_engine.dart';
import '../widgets/water_button.dart'; 
import '../widgets/bottle_visual.dart';

class HydrationScreen extends StatefulWidget {
  const HydrationScreen({super.key});

  @override
  State<HydrationScreen> createState() => _HydrationScreenState();
}

class _HydrationScreenState extends State<HydrationScreen> {

  // Logic for status messages
  String _getFunnyStatus(int total, int goal, int completed) {
    if (completed > 0) {
      if (completed >= 3) return "Champion Level: Basically a Fish 🐟";
      return "On to bottle number ${completed + 1}! You're a pro! 🚀";
    }

    double progress = total / goal;
    if (progress >= 0.75) return "Look at you, Hydration Hero! 🦸";
    if (progress >= 0.50) return "Halfway! Your skin is glowing (probably) ✨";
    if (progress >= 0.25) return "Emotional Support Water Level: LOW ⚠️";
    return "Your kidneys are sending a search party 🔍";
  }

  @override
  Widget build(BuildContext context) {
    // This allows the screen to listen to the engine
final engine = context.watch<CalculatorEngine>();
    return Scaffold(
      appBar: AppBar(title: const Text("Hydration Tracker")),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Progress Gauge
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 180, 
                  height: 180,
                  child: CircularProgressIndicator(
                    value: (engine.totalDrank / engine.goal).clamp(0.0, 1.0),
                    strokeWidth: 10,
                    backgroundColor: Colors.white10,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4FC3F7)),
                  ),
                ),
                Text(
                  "${((engine.totalDrank / engine.goal) * 100).toInt()}%",
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Color(0xFFAAF0D1)),
                ),
              ],
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Text(
                _getFunnyStatus(engine.totalDrank, engine.goal, engine.bottlesCompleted),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, color: Colors.white, fontStyle: FontStyle.italic),
              ),
            ),

            Text(
              "${engine.totalDrank} / ${engine.goal} ml",
              style: const TextStyle(fontSize: 20, color: Colors.white54),
            ),

            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: 50), 
                BottleVisual(fillLevel: engine.totalDrank / engine.goal),
                // Reward Icons
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      engine.bottlesCompleted,
                      (index) => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.0),
                        child: Icon(Icons.local_drink_rounded, color: Color(0xFFAAF0D1), size: 28),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),
            
            // Call the engine's addWater method
            WaterButtons(onAddWater: (amount) => engine.addWater(amount)),
            
            const SizedBox(height: 20),
            
            ElevatedButton(
              onPressed: () => engine.resetHydration(),
              child: const Text("Reset Day"),
            ),
            
            // Manual Slider using engine data
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  const Text("Manual Adjustment", style: TextStyle(color: Color(0xFFAAF0D1))),
                  Slider(
                    value: engine.totalDrank.toDouble().clamp(0, engine.goal.toDouble()),
                    min: 0,
                    max: engine.goal.toDouble(),
                    activeColor: const Color(0xFFAAF0D1),
                    onChanged: (newValue) {
                      // Directly update engine
                      engine.totalDrank = newValue.toInt();
                      engine.notifyListeners(); 
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}