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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hydration Tracker")),
     body: SingleChildScrollView(
     child:Column(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    // 1. Your existing numbers at the top
    Text(
      "${((_totalDrank / _goal) * 100).toInt()}%",
      style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: Color(0xFFAAF0D1)),
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
    Column(
  children: [
    const Text("Lost track?\n Or \n Someone forgot to ask before drinking from your bottle we are sorry to know that \n Drag to adjust:", style: TextStyle(color: Colors.white54)),
    Slider(
      value: _totalDrank.toDouble().clamp(0, _goal.toDouble()),
      min: 0,
      max: _goal.toDouble(),
      activeColor: const Color(0xFFAAF0D1),
      onChanged: (newValue) {
        setState(() {
          _totalDrank = newValue.toInt();
        });
      },
    ),
  ],
)
  ],
),
     ),
    );
  }
}
