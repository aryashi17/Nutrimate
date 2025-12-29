import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:firebase_auth/firebase_auth.dart';

// --- SERVICE & CORE IMPORTS ---
import 'package:nutrimate_app/core/services/calculator_engine.dart';
import 'package:nutrimate_app/core/services/streak_services.dart';
import '../../core/models/user_profile.dart';
import '../../core/models/meal_log_entry.dart';

// --- FEATURE IMPORTS ---
import 'package:nutrimate_app/features/hydration/health_insights_screen.dart';
import '../plate_mapper/plate_mapper_screen.dart';
import '../profile/profile_screen.dart';
import '../sick_bay/sick_bay_screen.dart';
import '../hydration/hydration_screen.dart';
import '../profile/health_status_Section.dart'; 


class MessLoggerScreen extends StatefulWidget {
  const MessLoggerScreen({super.key});

  @override
  State<MessLoggerScreen> createState() => _MessLoggerScreenState();
}

class _MessLoggerScreenState extends State<MessLoggerScreen> {
  // --- COLOR PALETTE (Ultra-Modern) ---
  final Color bgBlack = const Color(0xFF000000);
  final Color accentMint = const Color(0xFFB2FF59);
  final Color glassLayer = const Color(0xFF1A1A1A);
  final Color mutedText = const Color(0xFF8E8E93);
  final Color cardDark = const Color(0xFF17201B); 

  // --- STATE VARIABLES ---
  String selectedMeal = "Lunch";
  String? _hoveredMeal;
  Map<String, String> globalPlateOccupancy = {}; 
  Map<String, double> globalPlateFills = {};
  final TextEditingController _foodNameController = TextEditingController();

  // Categorized Meal Data (Merged Data Structure)
  final Map<String, List<Map<String, dynamic>>> mealData = {
    'Breakfast': [
      {'name': 'Oats', 'icon': Icons.breakfast_dining, 'portion': 0.8, 'calories': 150},
      {'name': 'Eggs', 'icon': Icons.egg, 'portion': 0.4, 'calories': 70},
      {'name': 'Milk', 'icon': Icons.coffee_rounded, 'portion': 0.9, 'calories': 120},
    ],
    'Lunch': [
      {'name': 'Rice', 'icon': Icons.rice_bowl_rounded, 'portion': 0.6, 'calories': 200},
      {'name': 'Dal', 'icon': Icons.soup_kitchen_rounded, 'portion': 0.7, 'calories': 180},
      {'name': 'Paneer', 'icon': Icons.restaurant_rounded, 'portion': 0.3, 'calories': 250},
      {'name': 'Roti', 'icon': Icons.flatware_rounded, 'portion': 0.5, 'calories': 100},
      {'name': 'Curd', 'icon': Icons.egg_alt_rounded, 'portion': 0.2, 'calories': 60},
      {'name': 'Salad', 'icon': Icons.eco_rounded, 'portion': 0.8, 'calories': 30},
    ],
    'Snacks': [
      {'name': 'Tea', 'icon': Icons.emoji_food_beverage, 'portion': 0.5, 'calories': 40},
      {'name': 'Samosa', 'icon': Icons.fastfood, 'portion': 0.3, 'calories': 200},
    ],
    'Dinner': [
      {'name': 'Soup', 'icon': Icons.waves, 'portion': 0.9, 'calories': 80},
      {'name': 'Sabzi', 'icon': Icons.dinner_dining, 'portion': 0.6, 'calories': 150},
    ],
  };

  @override
  void initState() {
    super.initState();
    _determineInitialMeal();
  }

  // --- LOGIC: Auto-detect meal time (From HEAD concept) ---
  void _determineInitialMeal() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 11) {
      selectedMeal = 'Breakfast';
    } else if (hour >= 11 && hour < 16) {
      selectedMeal = 'Lunch';
    } else if (hour >= 16 && hour < 19) {
      selectedMeal = 'Snacks';
    } else {
      selectedMeal = 'Dinner';
    }
  }

  // --- LOGIC: User Stream (Restored from HEAD) ---
  Stream<UserProfile?> get userStream {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();
    return FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots()
        .map((doc) => (doc.exists && doc.data() != null) ? UserProfile.fromMap(doc.data()!) : null);
  }

  // --- LOGIC: Save to Firebase (Restored from HEAD & Adapted) ---
  Future<void> _logPlateToFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    List<Map<String, dynamic>> currentItems = mealData[selectedMeal] ?? [];
    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;

    // Iterate through items to calculate totals based on portion
    for (var item in currentItems) {
      double portion = item['portion'] ?? 0.0;
      // Mock data if specific macros aren't in the map, scaling by portion
      totalCalories += (item['calories'] ?? 100) * portion;
      totalProtein += (item['protein'] ?? 5) * portion;
      totalCarbs += (item['carbs'] ?? 10) * portion;
      totalFat += (item['fat'] ?? 2) * portion;
    }

    final logEntry = MealLogEntry(
      id: '', 
      name: "Mess Hall - $selectedMeal", 
      calories: totalCalories,
      protein: totalProtein,
      carbs: totalCarbs,
      fat: totalFat,
      timestamp: DateTime.now(),
    );

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('food_logs')
          .add(logEntry.toMap());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$selectedMeal logged to Dashboard!"), backgroundColor: accentMint),
        );
      }
    } catch (e) {
      print("Error logging mess meal: $e");
    }
  }

  // --- LOGIC: Hero Card Math ---
  double get currentMealCompletion {
    final items = mealData[selectedMeal] ?? [];
    if (items.isEmpty) return 0.0;
    double totalPortion = items.fold(0.0, (sum, item) => sum + (item['portion'] as double));
    return (totalPortion / items.length).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgBlack,
      body: Stack(
        children: [
          // Background Gradient Glow
          Positioned(
            top: -100, right: -50,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentMint.withOpacity(0.08),
                border: Border.all(color: Colors.transparent),
              ),
              child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80), child: Container()),
            ),
          ),
          
          StreamBuilder<UserProfile?>(
            stream: userStream,
            builder: (context, snapshot) {
              final userProfile = snapshot.data;
              
              return SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    _buildDynamicHorizontalActions(),
                    
                    // 1. MERGED: Health Status (Was in HEAD, missed in new UI)
                    if (userProfile != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                        child: HealthStatusSection(user: userProfile),
                      ),
                    
                    // 2. MERGED: Hero Card (Restyled for new theme)
                    _buildHeroCard(),

                    const SizedBox(height: 5),
                    _buildElegantMealSelector(),
                    Expanded(child: _buildSmoothList()),
                    _buildFloatingBottomAction(),
                  ],
                ),
              );
            }
          ),
        ],
      ),
    );
  }

  // --- UI: Hero Card (Restyled) ---
  Widget _buildHeroCard() {
    final percent = currentMealCompletion;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: glassLayer,
        gradient: LinearGradient(
          colors: [glassLayer, glassLayer.withOpacity(0.8)], 
          begin: Alignment.topLeft, end: Alignment.bottomRight
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("MEAL PROGRESS", style: TextStyle(color: accentMint, fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                const Text("Plate Completion", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text("Based on your portion mapping", style: TextStyle(color: mutedText, fontSize: 12)),
              ],
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 60, height: 60,
                child: CircularProgressIndicator(
                  value: percent,
                  strokeWidth: 6,
                  backgroundColor: Colors.white10,
                  valueColor: AlwaysStoppedAnimation(accentMint),
                ),
              ),
              Text("${(percent * 100).toInt()}%", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          )
        ],
      ),
    );
  }

  // --- UI: Header ---
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("LOG YOUR", style: TextStyle(color: mutedText, fontSize: 10, letterSpacing: 4)),
              const Text("NUTRITION", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w200, letterSpacing: 2)),
            ],
          ),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: accentMint, width: 1)),
              child: const CircleAvatar(radius: 20, backgroundColor: Colors.black, child: Icon(Icons.person_2_outlined, color: Colors.white, size: 20)),
            ),
          )
        ],
      ),
    );
  }

  // --- UI: Horizontal Actions ---
  Widget _buildDynamicHorizontalActions() {
    return Container(
      height: 70,
      margin: const EdgeInsets.only(top: 5),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _buildPillAction(Icons.local_hospital_outlined, "Sick Bay", const Color(0xFFFF4B4B), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SickBayScreen()))),
          _buildPillAction(Icons.water_drop_outlined, "Hydrate", const Color(0xFF00B0FF), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HydrationScreen()))),
          _buildPillAction(Icons.save_alt_rounded, "Log Cloud", accentMint, () => _logPlateToFirebase()), // Logs to Firebase
          _buildPillAction(Icons.add_circle_outline, "Add", Colors.white, () => _showEditSheet()),
        ],
      ),
    );
  }

  Widget _buildPillAction(IconData icon, String label, Color color, VoidCallback tap) {
    return GestureDetector(
      onTap: tap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: glassLayer,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w300)),
          ],
        ),
      ),
    );
  }

  // --- UI: Meal Selector ---
  Widget _buildElegantMealSelector() {
    final meals = ['Breakfast', 'Lunch', 'Snacks', 'Dinner'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: meals.map((m) => _buildMealButton(m)).toList(),
      ),
    );
  }

  Widget _buildMealButton(String meal) {
    bool selected = selectedMeal == meal;
    bool hovered = _hoveredMeal == meal;
    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredMeal = meal),
      onExit: (_) => setState(() => _hoveredMeal = null),
      child: GestureDetector(
        onTap: () => setState(() => selectedMeal = meal),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? accentMint.withOpacity(0.1) : (hovered ? glassLayer.withOpacity(0.5) : Colors.transparent),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? accentMint : (hovered ? accentMint.withOpacity(0.5) : Colors.transparent),
              width: 1.5,
            ),
            boxShadow: hovered ? [BoxShadow(color: accentMint.withOpacity(0.2), blurRadius: 8)] : null,
          ),
          child: Column(
            children: [
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  color: selected ? accentMint : (hovered ? Colors.white : mutedText),
                  fontSize: selected ? 15 : 13,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
                child: Text(meal),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI: List ---
  Widget _buildSmoothList() {
    final items = mealData[selectedMeal] ?? [];
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: _buildModernFoodRow(item, index),
        );
      },
    );
  }

  Widget _buildModernFoodRow(Map<String, dynamic> item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: glassLayer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.03)),
      ),
      child: InkWell(
        onTap: () => _handleFoodTap(item),
        onLongPress: () => _showDeleteDialog(index),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(15)),
              child: Icon(item['icon'], color: accentMint, size: 18),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['name'], style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w400)),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: item['portion'],
                      minHeight: 4,
                      backgroundColor: Colors.white.withOpacity(0.05),
                      valueColor: AlwaysStoppedAnimation(accentMint),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Text("${(item['portion'] * 100).toInt()}%", style: TextStyle(color: mutedText, fontSize: 12)),
            const Icon(Icons.chevron_right_rounded, color: Colors.white12),
          ],
        ),
      ),
    );
  }

  // --- UI: Footer ---
  Widget _buildFloatingBottomAction() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: accentMint.withOpacity(0.9),
              boxShadow: [BoxShadow(color: accentMint.withOpacity(0.3), blurRadius: 20)],
            ),
            child: InkWell(
              onTap: () {
                 _logPlateToFirebase();
                 Navigator.push(context, MaterialPageRoute(builder: (_) => const HealthInsightsScreen()));
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("ANALYZE DIET GAP", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 13)),
                  SizedBox(width: 10),
                  Icon(Icons.arrow_forward_rounded, color: Colors.black, size: 18),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- EVENTS ---
  void _handleFoodTap(Map<String, dynamic> item) async {
    try {
      final List<Map<String, dynamic>>? changes = await Navigator.push(
        context, MaterialPageRoute(builder: (_) => PlateMapperScreen(
          foodName: item['name'], initialFill: item['portion'],
          existingOccupancy: globalPlateOccupancy, existingFills: globalPlateFills,
        )),
      );
      
      if (changes != null && changes.isNotEmpty) {
        setState(() {
          for (final change in changes) {
            globalPlateOccupancy[change['section']] = change['food'];
            globalPlateFills[change['section']] = change['fill'];
            
            final mealItems = mealData[selectedMeal]!;
            final i = mealItems.indexWhere((m) => m['name'] == change['food']);
            if (i != -1) mealItems[i]['portion'] = change['fill'];
          }
        });

        // Async updates
        try {
          await Provider.of<CalculatorEngine>(context, listen: false).addFood(item['name'], item['portion']);
          await StreakService().updateStreak();
        } catch (e) {
          print('Error updating calculator or streak: $e');
        }
      }
    } catch (e) {
      print('Error in food tap: $e');
    }
  }

  void _showDeleteDialog(int index) {
    showDialog(context: context, builder: (context) => AlertDialog(
      backgroundColor: glassLayer, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Delete?', style: TextStyle(color: Colors.white)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('NO', style: TextStyle(color: mutedText))),
        TextButton(onPressed: () { setState(() => mealData[selectedMeal]!.removeAt(index)); Navigator.pop(context); }, child: const Text('YES', style: TextStyle(color: Colors.redAccent))),
      ],
    ));
  }

  void _showEditSheet() {
    _foodNameController.clear();
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: glassLayer, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))), builder: (context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: _foodNameController, style: const TextStyle(color: Colors.white), decoration: InputDecoration(hintText: "What are you eating?", hintStyle: TextStyle(color: mutedText), border: InputBorder.none)),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: accentMint, minimumSize: const Size(double.infinity, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
          onPressed: () {
            if (_foodNameController.text.isNotEmpty) {
              setState(() => mealData[selectedMeal]!.add({'name': _foodNameController.text, 'icon': Icons.restaurant_menu_rounded, 'portion': 0.0}));
              Navigator.pop(context);
            }
          }, child: const Text("ADD TO LIST", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
        const SizedBox(height: 30),
      ]),
    ));
  }
}