import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For HapticFeedback
import 'package:provider/provider.dart';
import 'package:nutrimate_app/core/services/calculator_engine.dart';


class WaterButtons extends StatelessWidget {
  final Function(int) onAddWater;


  const WaterButtons({super.key, required this.onAddWater});


  void _showAmountDialog(BuildContext context, String type, int userCustomSize) {
    int currentAdjustment = userCustomSize;


    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF203A43),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text("Add $type", style: const TextStyle(color: Colors.white)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("$currentAdjustment ml",
                    style: const TextStyle(
                      color: Color(0xFFAAF0D1),
                      fontSize: 32,
                      fontWeight: FontWeight.bold
                    )),
                  const SizedBox(height: 10),
                  const Text("How much did you actually drink?",
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 10),
                  Slider(
                    value: currentAdjustment.toDouble(),
                    min: 0,
                    max: userCustomSize.toDouble(),
                    // 💡 Snap to every 50ml or 25ml for a better feel
                    divisions: userCustomSize > 0 ? (userCustomSize / 25).round() : 1,
                    activeColor: const Color(0xFFAAF0D1),
                    inactiveColor: Colors.white10,
                    onChanged: (value) {
                      HapticFeedback.selectionClick(); // Tiny vibrate while sliding
                      setState(() => currentAdjustment = value.toInt());
                    },
                  ),
                  const Text("Slide left if you didn't finish the container",
                    style: TextStyle(color: Colors.white38, fontSize: 11)),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel", style: TextStyle(color: Colors.white60)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFAAF0D1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact(); // Success tap
                    onAddWater(currentAdjustment);
                    Navigator.pop(context);
                  },
                  child: const Text("Add", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final engine = context.watch<CalculatorEngine>();


    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Space out vertically
      children: [
        _buildQuickAdd(context, "Glass", Icons.local_drink, engine.customGlassMl),
        const SizedBox(height: 15),
        _buildQuickAdd(context, "Bottle", Icons.water_drop, engine.customBottleMl),
        const SizedBox(height: 15),
        _buildQuickAdd(context, "Sipper", Icons.bolt, engine.customSipperMl),
      ],
    );
  }


  Widget _buildQuickAdd(BuildContext context, String label, IconData icon, int amount) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        _showAmountDialog(context, label, amount);
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05), // Subtle button background
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFFAAF0D1), size: 36),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
            Text("$amount ml", style: const TextStyle(color: Colors.white38, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
