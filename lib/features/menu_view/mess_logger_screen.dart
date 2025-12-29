import 'package:flutter/material.dart';
import 'package:nutrimate_app/core/services/calculator_engine.dart';
import 'package:nutrimate_app/core/services/streak_services.dart';
import 'package:nutrimate_app/features/hydration/health_insights_screen.dart';
import 'package:provider/provider.dart';
import '../plate_mapper/plate_mapper_screen.dart';
import '../profile/profile_screen.dart';
import '../sick_bay/sick_bay_screen.dart';
import '../hydration/hydration_screen.dart';
import 'package:nutrimate_app/features/reports/summary_screen.dart';

class MessLoggerScreen extends StatefulWidget {
  const MessLoggerScreen({super.key});

  @override
  State<MessLoggerScreen> createState() => _MessLoggerScreenState();
}

class _MessLoggerScreenState extends State<MessLoggerScreen> {
  // Theme Colors
  final Color bgDark = const Color(0xFF080C0B);
  final Color surface = const Color(0xFF121A16);
  final Color mint = const Color(0xFF7EE081);
  final Color waterBlue = const Color(0xFF4FC3F7);
  final Color amber = const Color(0xFFF4C430);
  final Color coral = const Color(0xFFFF6B6B);

  String selectedMeal = "Lunch";
  
  // GLOBAL PLATE MEMORY
  Map<String, String> globalPlateOccupancy = {}; 
  Map<String, double> globalPlateFills = {};

  final TextEditingController _foodNameController = TextEditingController();

  // Dynamic Data Store
  final Map<String, List<Map<String, dynamic>>> mealData = {
    'Breakfast': [
      {'name': 'Oats', 'icon': Icons.breakfast_dining, 'portion': 0.8},
      {'name': 'Eggs', 'icon': Icons.egg, 'portion': 0.4},
      {'name': 'Milk', 'icon': Icons.coffee_rounded, 'portion': 0.9},
    ],
    'Lunch': [
      {'name': 'Rice', 'icon': Icons.rice_bowl_rounded, 'portion': 0.6},
      {'name': 'Dal', 'icon': Icons.soup_kitchen_rounded, 'portion': 0.7},
      {'name': 'Paneer', 'icon': Icons.restaurant_rounded, 'portion': 0.3},
      {'name': 'Roti', 'icon': Icons.flatware_rounded, 'portion': 0.5},
      {'name': 'Curd', 'icon': Icons.egg_alt_rounded, 'portion': 0.2},
      {'name': 'Salad', 'icon': Icons.eco_rounded, 'portion': 0.8},
    ],
    'Snacks': [
      {'name': 'Tea', 'icon': Icons.emoji_food_beverage, 'portion': 0.5},
      {'name': 'Samosa', 'icon': Icons.fastfood, 'portion': 0.3},
    ],
    'Dinner': [
      {'name': 'Soup', 'icon': Icons.waves, 'portion': 0.9},
      {'name': 'Sabzi', 'icon': Icons.dinner_dining, 'portion': 0.6},
    ],
  };

  @override
  void dispose() {
    _foodNameController.dispose();
    super.dispose();
  }

  double get mealCompletion {
    final items = mealData[selectedMeal] ?? [];
    if (items.isEmpty) return 0.0;
    return items.fold<double>(0.0, (p, e) => p + e['portion']) / items.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.person_outline, color: Colors.white),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
        ),
        title: const Text('NUTRIMATE', 
          style: TextStyle(letterSpacing: 3, fontWeight: FontWeight.w900, fontSize: 14, color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined, color: Colors.orangeAccent),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SummaryScreen())),
          ),
          _buildActionBtn('Sick Bay', coral, Icons.local_hospital_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SickBayScreen()))),
          _buildActionBtn('Hydration', waterBlue, Icons.water_drop_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HydrationScreen()))),
        ],
      ),
      body: Column(
        children: [
          _buildMealSelector(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCompactHero(),
                  const SizedBox(height: 24),
                  const Text("TODAY'S PLATE", style: TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildBentoGrid(),
                ],
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: Container(
    padding: const EdgeInsets.all(12),
    color: bgDark,
    child: ElevatedButton(
      onPressed: () {
        // Navigates to the Gap Analysis screen you built
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HealthInsightsScreen()),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orangeAccent, // Match your target UI
        foregroundColor: Colors.black,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Text(
        "VIEW DIET GAP & WARNINGS",
        style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1),
      ),
    ),
  ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: mint,
        onPressed: () => _showEditSheet(),
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text("Add Food", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildActionBtn(String label, Color color, IconData icon, VoidCallback tap) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: ElevatedButton.icon(
        onPressed: tap,
        icon: Icon(icon, size: 18),
        label: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }

  Widget _buildMealSelector() {
    final meals = ['Breakfast', 'Lunch', 'Snacks', 'Dinner'];
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: meals.length,
        itemBuilder: (context, index) {
          bool isSelected = selectedMeal == meals[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(meals[index]),
              selected: isSelected,
              onSelected: (v) => setState(() => selectedMeal = meals[index]),
              selectedColor: mint,
              backgroundColor: surface,
              labelStyle: TextStyle(color: isSelected ? Colors.black : Colors.white60, fontWeight: FontWeight.bold, fontSize: 12),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }

  Widget _buildCompactHero() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(24)),
      child: Row(
        children: [
          _buildRadialProgress(mealCompletion, 60),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(selectedMeal, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                Text(_readableDate(), style: const TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBentoGrid() {
    final items = mealData[selectedMeal] ?? [];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.7,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return GestureDetector(
          onTap: () async {
            final List<Map<String, dynamic>>? changes = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PlateMapperScreen(
                  foodName: item['name'],
                  initialFill: item['portion'],
                  existingOccupancy: globalPlateOccupancy,
                  existingFills: globalPlateFills,
                ),
              ),
            );

            if (changes != null) {
              setState(() {
                globalPlateOccupancy.clear();
                globalPlateFills.clear();
                for (final change in changes) {
                  globalPlateOccupancy[change['section']] = change['food'];
                  globalPlateFills[change['section']] = change['fill'];
                  
                  final mealItems = mealData[selectedMeal]!;
                  final i = mealItems.indexWhere((m) => m['name'] == change['food']);
                  if (i != -1) mealItems[i]['portion'] = change['fill'];

                  // --- ADD THIS POINT HERE ---
        // This sends the data to your CalculatorEngine for the charts
        Provider.of<CalculatorEngine>(context, listen: false)
            .addFood(change['food'], change['fill']);
                }
              });

              await StreakService().updateStreak();
              Navigator.push(
      context, 
      MaterialPageRoute(builder: (_) => const HealthInsightsScreen())
    );
            }
          },
          onLongPress: () => _showDeleteDialog(index),
          child: Container(
            decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(16)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildRadialProgress(item['portion'], 35, icon: item['icon']),
                const SizedBox(height: 6),
                Text(item['name'], style: const TextStyle(fontSize: 10, color: Colors.white70), textAlign: TextAlign.center),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRadialProgress(double value, double size, {IconData? icon}) {
    return SizedBox(
      height: size, width: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(value: value, strokeWidth: 3, backgroundColor: Colors.white10, valueColor: AlwaysStoppedAnimation(mint)),
          if (icon != null) Icon(icon, size: size * 0.5, color: Colors.white)
          else Text("${(value * 100).toInt()}%", style: const TextStyle(color: Colors.white, fontSize: 10)),
        ],
      ),
    );
  }

  String _readableDate() {
    final dt = DateTime.now();
    return "${dt.day} ${_getMonth(dt.month)} ${dt.year}";
  }

  String _getMonth(int m) => ["", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"][m];

  void _showDeleteDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surface,
        title: const Text('Delete?', style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () {
            setState(() => mealData[selectedMeal]!.removeAt(index));
            Navigator.pop(context);
          }, child: Text('Delete', style: TextStyle(color: coral))),
        ],
      ),
    );
  }

  void _showEditSheet() {
    _foodNameController.clear();
    showModalBottomSheet(
      context: context,
      backgroundColor: surface,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _foodNameController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: "Food name", hintStyle: TextStyle(color: Colors.white24))),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: mint, minimumSize: const Size(double.infinity, 50)),
              onPressed: () {
                if (_foodNameController.text.isNotEmpty) {
                  setState(() => mealData[selectedMeal]!.add({'name': _foodNameController.text, 'icon': Icons.restaurant, 'portion': 0.0}));
                  Navigator.pop(context);
                }
              },
              child: const Text("Add Item", style: TextStyle(color: Colors.black)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}