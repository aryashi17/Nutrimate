import 'package:flutter/material.dart';
import '../widgets/water_button.dart'; // Ensure this path matches your folder
import '../widgets/bottle_visual.dart';


class HydrationScreen extends StatefulWidget {
  const HydrationScreen({super.key});


  @override
  State<HydrationScreen> createState() => _HydrationScreenState();
}


class _HydrationScreenState extends State<HydrationScreen> {
  int _totalDrank = 0; // The "Gulp Counter" logic
  final int _goal = 2000; // Daily target in ml


  void _addWater(int amount) {
    setState(() {
      _totalDrank += amount;
    });
    // Check if they overdrank (Goal is 2000ml)
  if (_totalDrank > _goal) {
    _showThirstWarning();
  }
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
  String _getFunnyStatus() {
  double progress = _totalDrank / _goal;
  if (progress >= 1.0) return "Champion Level: Basically a Fish ";
  if (progress >= 0.75) return "Look at you, Hydration Hero! 🦸";
  if (progress >= 0.50) return "Halfway! Your skin is glowing (probably) ";
  if (progress >= 0.25) return "Emotional Support Water Level: LOW ⚠️";
  return "Your kidneys are sending a search party ";
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hydration Tracker")),
     body: SingleChildScrollView(
     child:Column(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    // 1. Your existing numbers at the top
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
        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4FC3F7)), // The Blue Gauge
      ),
    ),
    Text(
      "${((_totalDrank / _goal) * 100).toInt()}%",
      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Color(0xFFAAF0D1)),
    ),
  ],
),
    // NEW: Funny Status Text
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 20.0),
  child: Text(
    _getFunnyStatus(),
    textAlign: TextAlign.center,
    style: const TextStyle(fontSize: 18, color: Colors.white, fontStyle: FontStyle.italic),
  ),
),
    // Smaller ML counter right under it
    Text(
      "$_totalDrank / $_goal ml",
      style: const TextStyle(fontSize: 20, color: Colors.white54),
    ),
   
    const SizedBox(height: 30), // Space


    // 2. THE BOTTLE GOES HERE (IN THE MIDDLE)
    BottleVisual(fillLevel: _totalDrank / _goal),


    const SizedBox(height: 30), // Space


    // 3. Your buttons at the bottom
    WaterButtons(onAddWater: _addWater),
   
    const SizedBox(height: 20),
   
    ElevatedButton(
      onPressed: () => setState(() => _totalDrank = 0),
      child: const Text("Reset Day"),
    ),
    // --- MANUAL OVERRIDE SECTION ---
Container(
  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
  padding: const EdgeInsets.all(15),
  decoration: BoxDecoration(
    color: Colors.white.withOpacity(0.05), // Subtle dark card look
    borderRadius: BorderRadius.circular(15),
  ),
  child: Column(
    children: [
      const Text(
        "My bottle had a leak, or I'm just bad at tracking. Don't judge.", // Your funny line
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFFAAF0D1), // Mint green to match the theme
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      const SizedBox(height: 5),
      const Text(
        "Lost track? Or did someone drink from your bottle without asking?", 
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white54, fontSize: 12),
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
  ], // Closes the inner Column
        ), // Closes the Outer Column
      ), // Closes the SingleChildScrollView
    ); // Closes the Scaffold
  } // Closes the Widget build
} // Closes the _HydrationScreenState class