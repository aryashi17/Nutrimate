// import 'package:flutter/material.dart';
// import '../plate_mapper/plate_mapper_screen.dart';
// import '../profile/profile_screen.dart';
// import '../scanner/add_food_screen.dart';
// import '../sick_bay/sick_bay_screen.dart';
// import '../hydration/hydration_screen.dart';


// class MessLoggerScreen extends StatefulWidget {
//   const MessLoggerScreen({super.key});

//   @override
//   State<MessLoggerScreen> createState() => _MessLoggerScreenState();
// }

// class _MessLoggerScreenState extends State<MessLoggerScreen> {
//   final List<Map<String, dynamic>> todayMenu = [
//     {'name': 'Basmati Rice', 'icon': Icons.rice_bowl_rounded},
//     {'name': 'Dal Tadka', 'icon': Icons.soup_kitchen_rounded},
//     {'name': 'Paneer Masala', 'icon': Icons.restaurant_rounded},
//     {'name': 'Fresh Curd', 'icon': Icons.egg_alt_rounded},
//     {'name': 'Butter Roti', 'icon': Icons.flatware_rounded},
//     {'name': 'Salad', 'icon': Icons.eco_rounded},
//   ];

//   String getMealTime() {
//     final hour = DateTime.now().hour;
//     if (hour < 11) return "Breakfast";
//     if (hour < 16) return "Lunch";
//     if (hour < 20) return "Snacks";
//     return "Dinner";
//   }

//   IconData getMealIcon() {
//     final meal = getMealTime();
//     if (meal == "Breakfast") return Icons.wb_twilight_rounded;
//     if (meal == "Lunch") return Icons.wb_sunny_rounded;
//     return Icons.dark_mode_rounded;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//   backgroundColor: const Color(0xFF121212),

//   appBar: AppBar(
//   backgroundColor: Colors.transparent,
//   elevation: 0,

//   // 👤 PROFILE (LEFT)
//   leading: IconButton(
//     icon: const Icon(Icons.person_outline, color: Colors.white),
//     onPressed: () {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (_) => const ProfileScreen()),
//       );
//     },
//   ),

//   // ➕ 🏥 💧 (RIGHT)
//   actions: [
//     // ➕ ADD / SCAN (PRIMARY)
//     Padding(
//       padding: const EdgeInsets.only(right: 4),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(12),
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (_) => const AddFoodScreen()),
//           );
//         },
//         child: Container(
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: const Color(0xFFAAF0D1),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: const Icon(Icons.add, color: Colors.black, size: 22),
//         ),
//       ),
//     ),

//     // 🏥 SICK BAY
//     IconButton(
//       icon: const Icon(
//         Icons.local_hospital_outlined,
//         color: Colors.white,
//       ),
//       onPressed: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (_) => const SickBayScreen()),
//         );
//       },
//     ),

//     // 💧 HYDRATION
//     IconButton(
//       icon: const Icon(Icons.water_drop_outlined, color: Colors.white),
//       onPressed: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (_) => const HydrationScreen()),
//         );
//       },
//     ),
//   ],
// ),

//   body: SafeArea(
//     child: Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const SizedBox(height: 10), // reduced because AppBar exists
//           _buildHeader(),
//           const SizedBox(height: 30),
//           const Text(
//             "TODAY'S PLATE",
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 14,
//               fontWeight: FontWeight.bold,
//               letterSpacing: 2,
//             ),
//           ),
//           const SizedBox(height: 15),
//           Expanded(child: _buildBentoGrid()),
//         ],
//       ),
//     ),
//   ),

//   floatingActionButton: _buildEditButton(),
// );
//   }

//   Widget _buildHeader() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [Color(0xFF1E1E1E), Color(0xFF2D2D2D)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(30),
//         border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
//       ),
//       child: Row(
//         children: [
//           Icon(getMealIcon(), size: 50, color: const Color(0xFFAAF0D1)),
//           const SizedBox(width: 20),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 getMealTime(),
//                 style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold),
//               ),
//               const Text(
//                 "Tuesday, Oct 24",
//                 style: TextStyle(color: Colors.white70, fontSize: 14),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBentoGrid() {
//     return GridView.builder(
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         crossAxisSpacing: 15,
//         mainAxisSpacing: 15,
//         childAspectRatio: 1.1,
//       ),
//       itemCount: todayMenu.length,
//       itemBuilder: (context, index) {
//         return _BentoCard(
//           label: todayMenu[index]['name'],
//           icon: todayMenu[index]['icon'],
//         );
//       },
//     );
//   }

//   Widget _buildEditButton() {
//     return FloatingActionButton.extended(
//       backgroundColor: const Color(0xFFAAF0D1),
//       onPressed: () => _showEditSheet(),
//       icon: const Icon(Icons.edit_note_rounded, color: Colors.black),
//       label: const Text("Edit Menu",
//           style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
//     );
//   }

//   void _showEditSheet() {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: const Color(0xFF1E1E1E),
//       shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
//       builder: (context) => Padding(
//         padding: const EdgeInsets.all(30),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text("Community Edit",
//                 style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold)),
//             const SizedBox(height: 20),
//             TextField(
//               style: const TextStyle(color: Colors.white),
//               decoration: InputDecoration(
//                 hintText: "What's being served instead?",
//                 hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
//                 filled: true,
//                 fillColor: Colors.white.withValues(alpha: 0.05),
//                 border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(15),
//                     borderSide: BorderSide.none),
//               ),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFFAAF0D1),
//                 minimumSize: const Size(double.infinity, 50),
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(15)),
//               ),
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//               child: const Text("Update for Everyone",
//                   style: TextStyle(color: Colors.black)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _BentoCard extends StatefulWidget {
//   final String label;
//   final IconData icon;
//   const _BentoCard({required this.label, required this.icon});

//   @override
//   State<_BentoCard> createState() => _BentoCardState();
// }

// class _BentoCardState extends State<_BentoCard> {
//   double _scale = 1.0;

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         debugPrint("Tapped ${widget.label}");
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => const PlateMapperScreen(),
//           ),
//         );
//       },
//       onTapDown: (_) => setState(() => _scale = 0.95),
//       onTapUp: (_) => setState(() => _scale = 1.0),
//       onTapCancel: () => setState(() => _scale = 1.0),
//       child: AnimatedScale(
//         scale: _scale,
//         duration: const Duration(milliseconds: 100),
//         child: Container(
//           decoration: BoxDecoration(
//             color: const Color(0xFF1E1E1E),
//             borderRadius: BorderRadius.circular(25),
//             border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
//           ),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(widget.icon,
//                   size: 40,
//                   color: const Color(0xFFAAF0D1).withValues(alpha: 0.8)),
//               const SizedBox(height: 10),
//               Text(
//                 widget.label.toUpperCase(),
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   color: Colors.white.withValues(alpha: 0.6),
//                   fontSize: 10,
//                   letterSpacing: 1.1,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import '../plate_mapper/plate_mapper_screen.dart';
import '../profile/profile_screen.dart';
import '../scanner/add_food_screen.dart';
import '../sick_bay/sick_bay_screen.dart';
import '../hydration/hydration_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/models/user_profile.dart';
import '../profile/health_status_Section.dart'; 
import '../../core/models/user_profile.dart';
import '../../core/models/meal_log_entry.dart';

// Enhanced Mess Logger Screen
// - Improved visual design and palette
// - Responsive grid
// - Visual portion indicators
// - Keeps connection to PlateMapper and Hydration screens
// - Awaits PlateMapper result (if provided) and updates tile portion

class MessLoggerScreen extends StatefulWidget {
  const MessLoggerScreen({super.key});

  @override
  State<MessLoggerScreen> createState() => _MessLoggerScreenState();
}

class _MessLoggerScreenState extends State<MessLoggerScreen> {
  // Color system (classy, health-oriented)
  final Color bgDark = const Color(0xFF0E1512);
  final Color cardDark = const Color(0xFF17201B);
  final Color mint = const Color(0xFF7EE081);
  final Color amber = const Color(0xFFF4C430);
  final Color waterBlue = const Color(0xFF4FC3F7);
  Future<void> _logPlateToFirebase() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;
List<dynamic> mySelectedItems = []; // Or List<MenuItem> if you have a model
  String selectedMealType = "Lunch";  // Or specific default value
  // 1. Calculate totals from your current plate widgets
  // (Assuming you have variables tracking these, or iterate through your selected items)
double totalCalories = 0;
double totalProtein = 0;
double totalCarbs = 0;
double totalFat = 0;

  // EXAMPLE: Iterate through your visible/selected items
  // You likely have a list of food items for the meal. Loop through them:
  for (var item in mySelectedItems) {
     totalCalories += item.calories;
     totalProtein += item.protein;
     totalCarbs += item.carbs;
     totalFat += item.fat;
  }

  // 2. Create the Log Entry
  // We save the WHOLE MEAL as one entry (e.g., "Lunch - Mess Hall")
  final logEntry = MealLogEntry(
    id: '', // Firestore will generate this
    name: "Mess Hall - $selectedMealType", // e.g. "Mess Hall - Lunch"
    calories: totalCalories,
    protein: totalProtein,
    carbs: totalCarbs,
    fat: totalFat,
    timestamp: DateTime.now(),
  );

  // 3. Save to the SHARED collection 'food_logs'
  try {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('food_logs') // <--- CRITICAL: Must match Home Screen
        .add(logEntry.toMap());

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Plate logged to Dashboard!")),
      );
      Navigator.pop(context); // Go back to Dashboard to see the update
    }
  } catch (e) {
    print("Error logging mess meal: $e");
  }
}
  // Paste this inside _MessLoggerScreenState, before build()
Stream<UserProfile?> get userStream {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return const Stream.empty();
  return FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots()
      .map((doc) => (doc.exists && doc.data() != null) ? UserProfile.fromMap(doc.data()!) : null);
}
  // Today menu now stores a `portion` (0.0 - 1.0) to visualise fullness
  final List<Map<String, dynamic>> todayMenu = [
    {'name': 'Basmati Rice', 'icon': Icons.rice_bowl_rounded, 'portion': 0.5},
    {'name': 'Dal Tadka', 'icon': Icons.soup_kitchen_rounded, 'portion': 0.65},
    {'name': 'Paneer Masala', 'icon': Icons.restaurant_rounded, 'portion': 0.35},
    {'name': 'Fresh Curd', 'icon': Icons.egg_alt_rounded, 'portion': 0.25},
    {'name': 'Butter Roti', 'icon': Icons.flatware_rounded, 'portion': 0.6},
    {'name': 'Salad', 'icon': Icons.eco_rounded, 'portion': 0.8},
  ];

  String getMealTime() {
    final hour = DateTime.now().hour;
    if (hour < 11) return "Breakfast";
    if (hour < 16) return "Lunch";
    if (hour < 20) return "Snacks";
    return "Dinner";
  }

  IconData getMealIcon() {
    final meal = getMealTime();
    if (meal == "Breakfast") return Icons.wb_twilight_rounded;
    if (meal == "Lunch") return Icons.wb_sunny_rounded;
    return Icons.dark_mode_rounded;
  }

  // Simple aggregate: average portion across items to show meal completion
  double get mealCompletion {
    if (todayMenu.isEmpty) return 0.0;
    final total = todayMenu.fold<double>(0.0, (p, e) => p + (e['portion'] as double));
    return (total / todayMenu.length).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxis = width > 720 ? 3 : (width > 480 ? 2 : 2);

    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.person_outline, color: Colors.white),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) =>  ProfileScreen())),
        ),
        title: Row(
          children: [
            Text(
              'Nutrimate',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                fontSize: 18,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(getMealIcon(), size: 16, color: mint),
                  const SizedBox(width: 8),
                  Text(getMealTime(), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Add Food
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddFoodScreen())),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: mint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.add, color: Colors.black, size: 22),
              ),
            ),
          ),

          IconButton(
            icon: const Icon(Icons.local_hospital_outlined, color: Colors.white),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SickBayScreen())),
          ),

          // Small Hydration chip (shows progress + navigates)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HydrationScreen())),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(Icons.water_drop, color: waterBlue, size: 18),
                    const SizedBox(width: 8),
                    // small mini circular indicator
                    SizedBox(
                      height: 22,
                      width: 22,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: 0.4, // TODO: replace with real hydration value
                            strokeWidth: 2.2,
                            valueColor: AlwaysStoppedAnimation<Color>(waterBlue),
                            backgroundColor: Colors.white10,
                          ),
                          const Icon(Icons.local_drink_outlined, size: 12, color: Colors.white70),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right, color: Colors.white54, size: 18),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<UserProfile?>(
        stream: userStream, // Listens to the helper we added in step 2
        builder: (context, snapshot) {
          final userProfile = snapshot.data;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- 1. NEW STATUS SECTION (BMI, Calories, Protein) ---
                  HealthStatusSection(user: userProfile),
                  const SizedBox(height: 18),

                  // --- 2. EXISTING HERO CARD (Meal Completion) ---
                  // Kept this so you don't lose the "Meal Progress" feature
                  _buildHeroCard(),
                  const SizedBox(height: 18),

                  // --- 3. EXISTING GRID HEADER ---
                  const Text(
                    "TODAY'S PLATE",
                    style: TextStyle(color: Colors.white70, fontSize: 13, letterSpacing: 1.6),
                  ),
                  const SizedBox(height: 12),

                  // --- 4. EXISTING FOOD GRID ---
                  Expanded(
                    child: GridView.builder(
                      padding: EdgeInsets.zero,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxis, // Uses the variable from your build method
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 1.05,
                      ),
                      itemCount: todayMenu.length,
                      itemBuilder: (context, index) {
                        final item = todayMenu[index];
                        return FoodTile(
                          name: item['name'] as String,
                          icon: item['icon'] as IconData,
                          portion: item['portion'] as double,
                          mint: mint,
                          cardDark: cardDark,
                          onTap: () async {
                            final result = await Navigator.push<Map<String, dynamic>>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PlateMapperScreen(foodName: item['name'] as String),
                              ),
                            );

                            if (result != null && result.containsKey('fill')) {
                              setState(() {
                                todayMenu[index]['portion'] = (result['fill'] as double).clamp(0.0, 1.0);
                              });
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: mint,
        onPressed: _showEditSheet,
        icon: const Icon(Icons.edit_note_rounded, color: Colors.black),
        label: const Text('Edit Menu', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildHeroCard() {
    final percent = mealCompletion;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [cardDark, cardDark.withOpacity(0.95)]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Row(
        children: [
          // Circular meal completion
          SizedBox(
            height: 72,
            width: 72,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 72,
                  width: 72,
                  child: CircularProgressIndicator(
                    value: percent,
                    strokeWidth: 8,
                    valueColor: AlwaysStoppedAnimation<Color>(mint),
                    backgroundColor: Colors.white12,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${(percent * 100).toInt()}%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const Text('done', style: TextStyle(color: Colors.white54, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
              
          // Title + date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  getMealTime(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_readableDate()}',
                  style: const TextStyle(color: Colors.white60, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Text(
                  _mealHint(percent),
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),

          // Quick actions
          Column(
            children: [
              IconButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HydrationScreen())),
                icon: Icon(Icons.water_drop, color: waterBlue),
              ),
              const SizedBox(height: 6),
              IconButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddFoodScreen())),
                icon: Icon(Icons.fastfood, color: amber),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _readableDate() {
    final dt = DateTime.now();
    final month = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ][dt.month];
    return '${dt.day} $month ${dt.year}';
  }

  String _mealHint(double percent) {
    if (percent > 0.8) return 'You\'re well on track — great portioning!';
    if (percent > 0.5) return 'Good job — just a little more to feel full.';
    return 'Consider adding a small portion of protein or veggies.';
  }

  void _showEditSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: cardDark,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Community Edit', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "What's being served instead?",
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.03),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: mint, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Update for Everyone'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
            ],
          ),
        );
      },
    );
  }
}

// -----------------------
// FoodTile: visual, animated, interactive
// -----------------------
class FoodTile extends StatefulWidget {
  final String name;
  final IconData icon;
  final double portion; // 0..1
  final Color mint;
  final Color cardDark;
  final VoidCallback? onTap;

  const FoodTile({required this.name, required this.icon, required this.portion, required this.mint, required this.cardDark, this.onTap, super.key});

  @override
  State<FoodTile> createState() => _FoodTileState();
}

class _FoodTileState extends State<FoodTile> with SingleTickerProviderStateMixin {
  double _scale = 1.0;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 160));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final portion = (widget.portion).clamp(0.0, 1.0);
    final barColor = portion >= 0.7 ? widget.mint : (portion >= 0.4 ? Colors.amber : Colors.redAccent);

    return GestureDetector(
      onTap: () async {
        _controller.forward().then((_) => _controller.reverse());
        widget.onTap?.call();
      },
      onTapDown: (_) => setState(() => _scale = 0.97),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            color: widget.cardDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.03)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 6)),
            ],
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 36, color: widget.mint.withOpacity(0.95)),
              const SizedBox(height: 10),
              Text(widget.name, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 10),

              // Visual portion bar (custom)
              Container(
                height: 10,
                decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
                child: Stack(
                  children: [
                    FractionallySizedBox(
                      widthFactor: portion,
                      child: Container(
                        decoration: BoxDecoration(color: barColor, borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Text('${(portion * 100).toInt()}%', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 6),
              Text(
                _subscriptForPortion(portion),
                style: TextStyle(color: Colors.white60, fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _subscriptForPortion(double p) {
    if (p >= 0.75) return 'Generous portion';
    if (p >= 0.45) return 'Moderate portion';
    if (p >= 0.2) return 'Small portion';
    return 'Light / taste only';
  }
}
