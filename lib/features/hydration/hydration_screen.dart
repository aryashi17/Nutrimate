// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:nutrimate_app/core/services/calculator_engine.dart';
// import '../widgets/water_button.dart'; 
// import '../widgets/bottle_visual.dart';

// class HydrationScreen extends StatefulWidget {
//   const HydrationScreen({super.key});

//   @override
//   State<HydrationScreen> createState() => _HydrationScreenState();
// }

// class _HydrationScreenState extends State<HydrationScreen> {

//   // Logic for status messages
//   String _getFunnyStatus(int total, int goal, int completed) {
//     if (completed > 0) {
//       if (completed >= 3) return "Champion Level: Basically a Fish 🐟";
//       return "On to bottle number ${completed + 1}! You're a pro! 🚀";
//     }

//     double progress = total / goal;
//     if (progress >= 0.75) return "Look at you, Hydration Hero! 🦸";
//     if (progress >= 0.50) return "Halfway! Your skin is glowing (probably) ✨";
//     if (progress >= 0.25) return "Emotional Support Water Level: LOW ⚠️";
//     return "Your kidneys are sending a search party 🔍";
//   }

//   @override
//   Widget build(BuildContext context) {
//     // This allows the screen to listen to the engine
// final engine = context.watch<CalculatorEngine>();
//     return Scaffold(
//       appBar: AppBar(title: const Text("Hydration Tracker")),
//       body: SingleChildScrollView(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const SizedBox(height: 20),
//             // Progress Gauge
//             Stack(
//               alignment: Alignment.center,
//               children: [
//                 SizedBox(
//                   width: 180, 
//                   height: 180,
//                   child: CircularProgressIndicator(
//                     value: (engine.totalDrank / engine.goal).clamp(0.0, 1.0),
//                     strokeWidth: 10,
//                     backgroundColor: Colors.white10,
//                     valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4FC3F7)),
//                   ),
//                 ),
//                 Text(
//                   "${((engine.totalDrank / engine.goal) * 100).toInt()}%",
//                   style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Color(0xFFAAF0D1)),
//                 ),
//               ],
//             ),
            
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
//               child: Text(
//                 _getFunnyStatus(engine.totalDrank, engine.goal, engine.bottlesCompleted),
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(fontSize: 18, color: Colors.white, fontStyle: FontStyle.italic),
//               ),
//             ),

//             Text(
//               "${engine.totalDrank} / ${engine.goal} ml",
//               style: const TextStyle(fontSize: 20, color: Colors.white54),
//             ),

//             const SizedBox(height: 30),

//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 const SizedBox(width: 50), 
//                 BottleVisual(fillLevel: engine.totalDrank / engine.goal),
//                 // Reward Icons
//                 Padding(
//                   padding: const EdgeInsets.only(left: 20),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: List.generate(
//                       engine.bottlesCompleted,
//                       (index) => const Padding(
//                         padding: EdgeInsets.symmetric(vertical: 4.0),
//                         child: Icon(Icons.local_drink_rounded, color: Color(0xFFAAF0D1), size: 28),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 30),
            
//             // Call the engine's addWater method
//             WaterButtons(onAddWater: (amount) => engine.addWater(amount)),
            
//             const SizedBox(height: 20),
            
//             ElevatedButton(
//               onPressed: () => engine.resetHydration(),
//               child: const Text("Reset Day"),
//             ),
            
//             // Manual Slider using engine data
//             Container(
//               margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
//               padding: const EdgeInsets.all(15),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.05),
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               child: Column(
//                 children: [
//                   const Text("Manual Adjustment", style: TextStyle(color: Color(0xFFAAF0D1))),
//                   Slider(
//                     value: engine.totalDrank.toDouble().clamp(0, engine.goal.toDouble()),
//                     min: 0,
//                     max: engine.goal.toDouble(),
//                     activeColor: const Color(0xFFAAF0D1),
//                     onChanged: (newValue) {
//                       // Directly update engine
//                       engine.totalDrank = newValue.toInt();
//                       engine.notifyListeners(); 
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nutrimate_app/core/services/calculator_engine.dart';
import '../widgets/water_button.dart';
import '../widgets/bottle_visual.dart';

class HydrationScreen extends StatefulWidget {
  const HydrationScreen({super.key});

  @override
  State<HydrationScreen> createState() => _HydrationScreenState();
}

class _HydrationScreenState extends State<HydrationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _showConfetti = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      lowerBound: 0.95,
      upperBound: 1.05,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _getFunnyStatus(int total, int goal, int completed) {
    double progress = total / goal;
    if (progress >= 1.0) return "Hydration complete. Absolute legend 💧";
    if (progress >= 0.75) return "Hydration Hero 🦸";
    if (progress >= 0.50) return "Halfway there ✨";
    if (progress >= 0.25) return "Drink water, bestie ⚠️";
    return "Your kidneys are worried 🔍";
  }

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<CalculatorEngine>();
    final progress = (engine.totalDrank / engine.goal).clamp(0.0, 1.0);

    return Scaffold(
      body: Stack(
        children: [
          // 🌊 MAIN UI
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0F2027),
                  Color(0xFF203A43),
                  Color(0xFF2C5364),
                ],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    const Text(
                      "HYDRATION",
                      style: TextStyle(
                        letterSpacing: 3,
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 🔵 PROGRESS RING
                    ScaleTransition(
                      scale: _pulseController,
                      child: SizedBox(
                        width: 200,
                        height: 200,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 12,
                              backgroundColor: Colors.white10,
                              valueColor: const AlwaysStoppedAnimation(
                                Color(0xFF4FC3F7),
                              ),
                            ),
                            TweenAnimationBuilder<int>(
                              tween: IntTween(
                                begin: 0,
                                end: (progress * 100).toInt(),
                              ),
                              duration: const Duration(milliseconds: 800),
                              builder: (_, value, __) => Text(
                                "$value%",
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFAAF0D1),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 🧊 STATUS CARD
                    _GlassCard(
                      child: Column(
                        children: [
                          Text(
                            _getFunnyStatus(
                              engine.totalDrank,
                              engine.goal,
                              engine.bottlesCompleted,
                            ),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "${engine.totalDrank} / ${engine.goal} ml",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white60,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // 🍼 OLD BOTTLE DESIGN (UNCHANGED)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        BottleVisual(fillLevel: progress),
                        const SizedBox(width: 20),
                        Column(
                          children: List.generate(
                            engine.bottlesCompleted,
                            (index) => const Padding(
                              padding: EdgeInsets.symmetric(vertical: 6),
                              child: Icon(
                                Icons.local_drink_rounded,
                                color: Color(0xFFAAF0D1),
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // ➕ WATER BUTTONS
                    WaterButtons(
                      onAddWater: (amount) => engine.addWater(amount),
                    ),

                    const SizedBox(height: 16),

                    // 🔁 RESET (CONFETTI TRIGGER)
                    TextButton(
                      onPressed: () {
                        engine.resetHydration();
                        setState(() => _showConfetti = true);

                        Future.delayed(const Duration(seconds: 3), () {
                          if (mounted) {
                            setState(() => _showConfetti = false);
                          }
                        });
                      },
                      child: const Text(
                        "Reset Day",
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 🎚 MANUAL SLIDER
                    _GlassCard(
                      child: Column(
                        children: [
                          const Text(
                            "Manual Adjustment",
                            style: TextStyle(
                              color: Color(0xFFAAF0D1),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Slider(
                            value: engine.totalDrank
                                .toDouble()
                                .clamp(0, engine.goal.toDouble()),
                            min: 0,
                            max: engine.goal.toDouble(),
                            activeColor: const Color(0xFFAAF0D1),
                            onChanged: (v) {
                              engine.totalDrank = v.toInt();
                              engine.notifyListeners();
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),

          // 🎉 CONFETTI (ONLY ON RESET)
          if (_showConfetti) const GoalConfettiOverlay(),
        ],
      ),
    );
  }
}

/// 🧊 GLASS CARD
class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: child,
    );
  }
}

/// 🎉 CONFETTI OVERLAY
class GoalConfettiOverlay extends StatefulWidget {
  const GoalConfettiOverlay({super.key});

  @override
  State<GoalConfettiOverlay> createState() => _GoalConfettiOverlayState();
}

class _GoalConfettiOverlayState extends State<GoalConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          return CustomPaint(
            painter: _ConfettiPainter(progress: _controller.value),
            size: MediaQuery.of(context).size,
          );
        },
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final double progress;
  final Random _rand = Random();

  _ConfettiPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (int i = 0; i < 150; i++) {
      paint.color = Colors.primaries[i % Colors.primaries.length]
          .withOpacity(1 - progress);

      final x = _rand.nextDouble() * size.width;
      final y = progress * size.height + _rand.nextDouble() * 200;

      canvas.drawCircle(Offset(x, y), 3, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
