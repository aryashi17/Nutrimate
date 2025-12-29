import 'package:flutter/material.dart';
import '../widgets/water_button.dart'; 
import '../widgets/bottle_visual.dart';

class HydrationScreen extends StatefulWidget {
  const HydrationScreen({super.key});

  @override
  State<HydrationScreen> createState() => _HydrationScreenState();
}

class _HydrationScreenState extends State<HydrationScreen> {
  int _totalDrank = 0; 
  // This _goal can now be changed based on user profile (e.g., weight/height)
  int _goal = 2000; 
  int _bottlesCompleted = 0; 

  void _addWater(int amount) {
    setState(() {
      _totalDrank += amount;
      
      // If the current bottle is full, add a reward icon and reset for the next one
      if (_totalDrank >= _goal) {
        _bottlesCompleted++;
        _totalDrank = 0; 
        _showSuccessSnackBar();
      }
    });
  }

  void _showSuccessSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Bottle Finished! New icon added. 🍾"),
        backgroundColor: Colors.cyan,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showThirstWarning() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("I've noticed you're thirsty, are you feeling okay?"),
        backgroundColor: Colors.orangeAccent,
        duration: Duration(seconds: 3),
      ),
    );
  }

  // UPDATED: Funny Status now changes based on how many bottles were already finished
  String _getFunnyStatus() {
    if (_bottlesCompleted > 0) {
      if (_bottlesCompleted >= 3) return "Champion Level: Basically a Fish 🐟";
      return "On to bottle number ${_bottlesCompleted + 1}! You're a pro! 🚀";
    }

    double progress = _totalDrank / _goal;
    if (progress >= 0.75) return "Look at you, Hydration Hero! 🦸";
    if (progress >= 0.50) return "Halfway! Your skin is glowing (probably) ✨";
    if (progress >= 0.25) return "Emotional Support Water Level: LOW ⚠️";
    return "Your kidneys are sending a search party 🔍"; // Only shows for 1st bottle
  }

  @override
  Widget build(BuildContext context) {
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
                    value: (_totalDrank / _goal).clamp(0.0, 1.0),
                    strokeWidth: 10,
                    backgroundColor: Colors.white10,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4FC3F7)),
                  ),
                ),
                Text(
                  "${((_totalDrank / _goal) * 100).toInt()}%",
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Color(0xFFAAF0D1)),
                ),
              ],
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Text(
                _getFunnyStatus(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, color: Colors.white, fontStyle: FontStyle.italic),
              ),
            ),

            Text(
              "$_totalDrank / $_goal ml",
              style: const TextStyle(fontSize: 20, color: Colors.white54),
            ),

            const SizedBox(height: 30),

            // BOTTLE AREA: Main bottle in middle, icons on the right
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: 50), // Balance for the icons on the right
                
                BottleVisual(fillLevel: _totalDrank / _goal),

                // Vertical column of reward icons
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      _bottlesCompleted,
                      (index) => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.0),
                        child: Icon(
                          Icons.local_drink_rounded, 
                          color: Color(0xFFAAF0D1),
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),
            
            // Interaction Buttons
            WaterButtons(onAddWater: _addWater),
            
            const SizedBox(height: 20),
            
            ElevatedButton(
              onPressed: () => setState(() {
                _totalDrank = 0;
                _bottlesCompleted = 0; // Fully reset the day
              }),
              child: const Text("Reset Day"),
            ),
            
            // MANUAL OVERRIDE SECTION
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  const Text(
                    "My bottle had a leak, or I'm just bad at tracking. Don't judge.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFFAAF0D1), fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Slider(
                    value: _totalDrank.toDouble().clamp(0, _goal.toDouble()),
                    min: 0,
                    max: _goal.toDouble(),
                    activeColor: const Color(0xFFAAF0D1),
                    inactiveColor: Colors.white10,
                    onChanged: (newValue) {
                      setState(() {
                        _totalDrank = newValue.toInt();
                      });
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