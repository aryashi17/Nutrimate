import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// --- SERVICE & CORE IMPORTS ---
import 'package:nutrimate_app/core/services/calculator_engine.dart';
import 'package:nutrimate_app/core/services/streak_services.dart';
import '../../core/models/user_profile.dart';
import '../../core/models/meal_log_entry.dart';
import '../../core/services/mess_menu_service.dart';


import 'package:nutrimate_app/features/hydration/health_insights_screen.dart';
import '../plate_mapper/plate_mapper_screen.dart';
import '../profile/profile_screen.dart';
import '../sick_bay/sick_bay_screen.dart';
import '../hydration/hydration_screen.dart';
import '../profile/health_status_Section.dart';
import '../menu/weekly_menu_screen.dart';
import 'package:nutrimate_app/features/scanner/ai_scanner_screen.dart';


class MessLoggerScreen extends StatefulWidget {
  const MessLoggerScreen({super.key});

  @override
  State<MessLoggerScreen> createState() => _MessLoggerScreenState();
}

class _MessLoggerScreenState extends State<MessLoggerScreen> {
  // --- COLOR PALETTE (Midnight Sapphire & Obsidian) ---
  final Color bgBlack = const Color(0xFF020408);
  final Color accentBlue = const Color(0xFF4A90E2);
  final Color electricBlue = const Color(0xFF00F2FF);
  final Color glassLayer = const Color(0xFF0D121C);
  final Color mutedText = const Color(0xFF6A768A);
  final Color cardDark = const Color(0xFF0A0F16);

  // --- STATE VARIABLES ---
  String selectedMeal = "Lunch";
  String? _hoveredMeal;
  int? _hoveredFoodRowIndex;
  bool _profileButtonHovered = false;
  bool _bottomActionHovered = false;
final Map<String, Map<String, String>> mealPlateOccupancy = {
  'Breakfast': {},
  'Lunch': {},
  'Snacks': {},
  'Dinner': {},
};

final Map<String, Map<String, double>> mealPlateFills = {
  'Breakfast': {},
  'Lunch': {},
  'Snacks': {},
  'Dinner': {},
};

  final TextEditingController _foodNameController = TextEditingController();

  Map<String, List<Map<String, dynamic>>> mealData = {};
  bool isMenuLoading = true;

  // Hover index for the horizontal actions
  int? _hoveredActionIndex;

  @override
  void initState() {
    super.initState();
    _determineInitialMeal();
    _loadTodayMenu();
  }

  // --- LOGIC METHODS ---

  Future<void> _loadTodayMenu() async {
    try {
      final service = MessMenuService();
      final menu = await service.getTodayMenu();

      // Normalize Firestore data → UI format
      menu.forEach((meal, items) {
        for (final item in items) {
          item['portion'] = (item['defaultPortion'] ?? 0.5).toDouble();
          item['icon'] = item['icon'] ?? Icons.restaurant_menu_rounded;
        }
      });

      setState(() {
        mealData = menu.map((k, v) => MapEntry(k, List<Map<String, dynamic>>.from(v)));
        isMenuLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Error loading menu: $e');
      setState(() => isMenuLoading = false);
    }
  }

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

  Stream<UserProfile?> get userStream {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((doc) => (doc.exists && doc.data() != null) ? UserProfile.fromMap(doc.data()!) : null);
  }

  Future<void> _logPlateToFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    List<Map<String, dynamic>> currentItems = mealData[selectedMeal] ?? [];
    double totalCalories = 0, totalProtein = 0, totalCarbs = 0, totalFat = 0;

    for (var item in currentItems) {
      double portion = (item['portion'] ?? 0.0).toDouble();
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
      await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('food_logs').add(logEntry.toMap());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$selectedMeal logged!"), backgroundColor: accentBlue),
        );
      }
    } catch (e) {
      debugPrint("Error logging: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text("Failed to log meal"), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  // --- UI BUILDERS ---

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      // backgroundColor: bgBlack,
        backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // RepaintBoundary isolates the heavy blur from the list scrolling
          RepaintBoundary(child: _buildBackgroundGlow()),

          StreamBuilder<UserProfile?>(
            stream: userStream,
            builder: (context, snapshot) {
              final userProfile = snapshot.data;

              return SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 8),
                    _buildDynamicHorizontalActions(),
                    const SizedBox(height: 8),
                    _buildElegantMealSelector(),

                    Expanded(
                      child: CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          if (userProfile != null)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                                child: HealthStatusSection(user: userProfile),
                              ),
                            ),

                          _buildSliverFoodList(),

                          const SliverToBoxAdapter(child: SizedBox(height: 120)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildFloatingBottomAction(),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundGlow() {
    return Stack(
      children: [
        Positioned(
          top: -50,
          right: -30,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accentBlue.withOpacity(0.08),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
              child: Container(),
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          left: -80,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF6B4EE0).withOpacity(0.05),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
              child: Container(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 8),
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [Colors.white, accentBlue.withOpacity(0.9)],
                ).createShader(bounds),
                child: const Text(
                  "NUTRIMATE",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                  ),
                ),
              ),
            ],
          ),
          _buildProfileButton(),
        ],
      ),
    );
  }

  Widget _buildProfileButton() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _profileButtonHovered = true),
      onExit: (_) => setState(() => _profileButtonHovered = false),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: accentBlue, width: 1),
            boxShadow: _profileButtonHovered
                ? [BoxShadow(color: accentBlue.withOpacity(0.25), blurRadius: 10, spreadRadius: 2)]
                : null,
          ),
          child: const CircleAvatar(
            radius: 20,
            backgroundColor: Colors.black,
            child: Icon(
              Icons.person_2_outlined,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  // --- HORIZONTAL ACTIONS ---
  Widget _buildDynamicHorizontalActions() {
    final actions = [
      {'icon': Icons.local_hospital_outlined, 'label': 'Sick Bay', 'color': const Color(0xFFFF4B4B)},
      {'icon': Icons.water_drop_outlined, 'label': 'Hydrate', 'color': const Color(0xFF00B0FF)},
      {'icon': Icons.save_alt_rounded, 'label': 'Log Cloud', 'color': accentBlue},
      {'icon': Icons.add_circle_outline, 'label': 'Add', 'color': const Color(0xFF00E676)},
      {'icon': Icons.calendar_month_outlined, 'label': 'Menu', 'color': Colors.orangeAccent},
    ];

    return SizedBox(
      height: 70,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: actions.length,
        itemBuilder: (context, index) {
          final a = actions[index];
          return _buildPillAction(a['icon'] as IconData, a['label'] as String, a['color'] as Color, index);
        },
      ),
    );
  }

  Widget _buildPillAction(IconData icon, String label, Color color, int index) {
    final bool isHovered = _hoveredActionIndex == index;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredActionIndex = index),
      onExit: (_) => setState(() => _hoveredActionIndex = null),
      child: GestureDetector(
        onTap: () async {
          HapticFeedback.mediumImpact();
          // handle actions by index
          switch (label) {
            case 'Sick Bay':
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SickBayScreen()));
              break;
            case 'Hydrate':
              Navigator.push(context, MaterialPageRoute(builder: (_) => const HydrationScreen()));
              break;
            case 'Log Cloud':
              await _logPlateToFirebase();
              break;
            case 'Add':
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AiScannerScreen(),
                ),
              );
              break;

            case 'Menu':
              Navigator.push(context, MaterialPageRoute(builder: (_) => const WeeklyMenuScreen()));
              break;
            default:
              break;
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.only(right: 12, top: 6, bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isHovered ? color.withOpacity(0.12) : glassLayer,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: isHovered ? color.withOpacity(0.9) : Colors.white.withOpacity(0.03)),
            boxShadow: isHovered
                ? [BoxShadow(color: color.withOpacity(0.25), blurRadius: 12, spreadRadius: 1)]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: isHovered ? Colors.white : color, size: 18),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  color: isHovered ? Colors.white : Colors.white.withOpacity(0.9),
                  fontSize: 13,
                  fontWeight: isHovered ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
        // onTap: () => setState(() => selectedMeal = meal),
        onTap: () {
  setState(() {
    selectedMeal = meal;

    // reset transient UI state (NOT plate data)
    _hoveredFoodRowIndex = null;
    _hoveredMeal = null;
  });
},

        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
          ),
          child: Text(
            meal,
            style: TextStyle(
              color: selected ? accentBlue : (hovered ? Colors.white : mutedText),
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSliverFoodList() {
    if (isMenuLoading) return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
    final items = mealData[selectedMeal] ?? [];
    if (items.isEmpty) return const SliverFillRemaining(child: Center(child: Text("No items", style: TextStyle(color: Colors.white54))));

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildModernFoodRow(items[index], index),
          childCount: items.length,
        ),
      ),
    );
  }

 Widget _buildModernFoodRow(Map<String, dynamic> item, int index) {
    bool hovered = _hoveredFoodRowIndex == index;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredFoodRowIndex = index),
      onExit: (_) => setState(() => _hoveredFoodRowIndex = null),
      child: AnimatedScale(
        scale: hovered ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: hovered ? glassLayer : cardDark.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: hovered ? accentBlue.withOpacity(0.5) : Colors.white.withOpacity(0.05)),
          ),
          child: InkWell(
            onTap: () => _handleFoodTap(item),
            child: Row(
              children: [
                Icon(item['icon'], color: accentBlue, size: 20),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['name'], style: const TextStyle(color: Colors.white, fontSize: 15)),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: item['portion'],
                        backgroundColor: Colors.white10,
                        valueColor: AlwaysStoppedAnimation(accentBlue),
                        minHeight: 3,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text("${(item['portion'] * 100).toInt()}%", style: TextStyle(color: mutedText, fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingBottomAction() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 24, 34),
      child: Align(
        alignment: Alignment.bottomRight,
        child: MouseRegion(
          onEnter: (_) => setState(() => _bottomActionHovered = true),
          onExit: (_) => setState(() => _bottomActionHovered = false),
          child: GestureDetector(
            onTap: () async {
              HapticFeedback.heavyImpact();
              await _logPlateToFirebase();
              Navigator.push(context, MaterialPageRoute(builder: (_) => const HealthInsightsScreen()));
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutBack,
              padding: EdgeInsets.symmetric(horizontal: _bottomActionHovered ? 26 : 22, vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [accentBlue, const Color(0xFF1B2E4B)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: accentBlue.withOpacity(_bottomActionHovered ? 0.4 : 0.2), blurRadius: 30, offset: const Offset(0, 10)),
                ],
                border: Border.all(color: electricBlue.withOpacity(0.2), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.query_stats_rounded, color: electricBlue, size: 22),
                  const SizedBox(width: 12),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('ANALYZE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.2, fontSize: 14)),
                      Text('PRECISION DATA', style: TextStyle(color: electricBlue.withOpacity(0.7), fontWeight: FontWeight.bold, fontSize: 9)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleFoodTap(Map<String, dynamic> item) async {
  try {
    final List<Map<String, dynamic>>? changes = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlateMapperScreen(
          mealType: selectedMeal,
          foodName: item['name'],
          initialFill: (item['portion'] ?? 0.0).toDouble(),
          existingOccupancy: mealPlateOccupancy[selectedMeal]!,
          existingFills: mealPlateFills[selectedMeal]!,
        ),
      ),
    );

    if (changes == null || changes.isEmpty) return;

    // ✅ Update meal-specific plate + portions
    setState(() {
      mealPlateOccupancy[selectedMeal]!.clear();
      mealPlateFills[selectedMeal]!.clear();

      for (final change in changes) {
        mealPlateOccupancy[selectedMeal]![change['section']] = change['food'];
        mealPlateFills[selectedMeal]![change['section']] = change['fill'];

        final mealItems = mealData[selectedMeal] ?? [];
        final i = mealItems.indexWhere((m) => m['name'] == change['food']);
        if (i != -1) {
          mealItems[i]['portion'] = change['fill'];
        }
      }
    });

    // ✅ Async side-effects (ONCE)
    await Provider.of<CalculatorEngine>(context, listen: false)
        .addFood(changes.first['food'], changes.first['fill'], selectedMeal);

    await StreakService().updateStreak();
  } catch (e) {
    debugPrint('Error in food tap: $e');
  }
}


  void _showDeleteDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: glassLayer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete?', style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('NO', style: TextStyle(color: mutedText))),
          TextButton(onPressed: () {
            setState(() => mealData[selectedMeal]!.removeAt(index));
            Navigator.pop(context);
          }, child: const Text('YES', style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
  }

  void _showEditSheet() {
    _foodNameController.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: glassLayer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _foodNameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(hintText: "What are you eating?", hintStyle: TextStyle(color: mutedText), border: InputBorder.none),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: accentBlue, minimumSize: const Size(double.infinity, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
              onPressed: () {
                final name = _foodNameController.text.trim();
                if (name.isNotEmpty) {
                  setState(() {
                    mealData.putIfAbsent(selectedMeal, () => <Map<String, dynamic>>[]);
                    mealData[selectedMeal]!.add({'name': name, 'icon': Icons.restaurant_menu_rounded, 'portion': 0.0});
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('ADD TO LIST', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
