import 'package:flutter/material.dart';


class WaterButtons extends StatelessWidget {
  final Function(int) onAddWater;


  const WaterButtons({super.key, required this.onAddWater});


  @override
  Widget build(BuildContext context) {
   return Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    // Option 1: A Small Glass (250ml)
    GestureDetector(
      onTap: () => onAddWater(250),
      child: Column(
        children: const [
          Icon(Icons.local_drink, color: Color(0xFFAAF0D1), size: 40),
          Text("Glass", style: TextStyle(color: Colors.white70)),
        ],
      ),
    ),
    
    // Option 2: A Standard Bottle (500ml)
    GestureDetector(
      onTap: () => onAddWater(500),
      child: Column(
        children: const [
          Icon(Icons.water_drop, color: Color(0xFFAAF0D1), size: 40),
          Text("Bottle", style: TextStyle(color: Colors.white70)),
        ],
      ),
    ),

    // Option 3: Large Sipper (1000ml)
    GestureDetector(
      onTap: () => onAddWater(1000),
      child: Column(
        children: const [
          Icon(Icons.bolt, color: Color(0xFFAAF0D1), size: 40),
          Text("Sipper", style: TextStyle(color: Colors.white70)),
        ],
      ),
    ),
  ],
);
  }
}
