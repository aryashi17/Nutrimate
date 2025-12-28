import 'package:flutter/material.dart';

class BottleVisual extends StatelessWidget {
  final double fillLevel;

  const BottleVisual({super.key, required this.fillLevel});

  @override
  Widget build(BuildContext context) {
    // This is your team's Mint Green color code
    const Color mintGreen = Color(0xFFAAF0D1);

    return Column(
      children: [
        // 1. THE HANDLE
        Container(
          width: 60,
          height: 30,
          decoration: BoxDecoration(
            // Updated to use Mint Green with some transparency
            border: Border.all(color: mintGreen.withOpacity(0.5), width: 8),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
        ),
        // 2. THE CAP
        Container(
          width: 50,
          height: 20,
          color: Colors.grey.shade700, // Darker grey for the charcoal theme
        ),
        // 3. THE MAIN BODY (The wide gallon shape)
Container(
  width: 160,
  height: 220,
  // This tells the bottle to "trim" everything inside its 30px rounded corners
  clipBehavior: Clip.antiAlias, 
  decoration: BoxDecoration(
    color: const Color(0xFF1A1A1A), // Matches your new dark dashboard
    border: Border.all(color: const Color(0xFFAAF0D1), width: 3),
    borderRadius: BorderRadius.circular(30),
  ),
  child: Stack(
    alignment: Alignment.bottomCenter,
    children: [
      // The Water inside
      AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        width: 160, // Must be the same width as the bottle
        height: 220 * (fillLevel > 1.0 ? 1.0 : fillLevel),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.7),
          // REMOVE borderRadius from here entirely! 
          // If the water is a rectangle, the bottle's Clip.antiAlias 
          // will curve the bottom corners for you automatically.
        ),
      ),
      
      // Motivation Text Labels
      Positioned.fill(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const [
            Text("9 AM - GO!", style: TextStyle(fontSize: 10, color: Colors.white24)),
            Text("1 PM - DRINK MORE", style: TextStyle(fontSize: 10, color: Colors.white24)),
            Text("5 PM - ALMOST THERE", style: TextStyle(fontSize: 10, color: Colors.white24)),
          ],
        ),
      ),
    ],
  ),
),
],
    );
  }
}