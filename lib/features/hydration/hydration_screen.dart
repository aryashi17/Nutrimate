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
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final engine = Provider.of<CalculatorEngine>(context, listen: false);
   
    // 💡 Add this condition: Only show if the sizes are still at default/0
    // or if you add a 'isConfigured' bool to your engine.
    if (!engine.isHydrationConfigured) {
      _showSetupDialog(context, engine);
    }
  });


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
    if (progress >= 1.0) return "Hydration complete. Absolute legend";
    if (progress >= 0.75) return "Warning: May start speaking fluent Dolphin";
    if (progress >= 0.50) return "Your skin is starting to consider 'Glowing' mode";
    if (progress >= 0.25) return "Keep going, you’re becoming less of a cactus";
    return "Currently operating on 'Desert Mode'";
  }


  // --- DIALOGS ---


  void _showSetupDialog(BuildContext context, CalculatorEngine engine) {
    final glassController = TextEditingController(text: engine.customGlassMl.toString());
    final bottleController = TextEditingController(text: engine.customBottleMl.toString());
    final sipperController = TextEditingController(text: engine.customSipperMl.toString());


    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF203A43),
        title: const Text("Set Container Sizes (ml)", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(glassController, "Glass size (ml)"),
            _buildTextField(bottleController, "Bottle size (ml)"),
            _buildTextField(sipperController, "Sipper size (ml)"),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFAAF0D1)),
            onPressed: () {
              engine.updateContainerSizes(
                int.tryParse(glassController.text) ?? 250,
                int.tryParse(bottleController.text) ?? 500,
                int.tryParse(sipperController.text) ?? 1000,
              );
              Navigator.pop(context);
            },
            child: const Text("Save Sizes", style: TextStyle(color: Colors.black)),
          )
        ],
      ),
    );
  }


  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFFAAF0D1)),
      ),
    );
  }


  void _showResetConfirmation(BuildContext context, CalculatorEngine engine) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF203A43),
        title: const Text("Reset Day?", style: TextStyle(color: Colors.white)),
        content: const Text("This will clear your progress for today.", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              engine.resetHydration();
              setState(() => _showConfetti = true);
              Navigator.pop(context);
              Future.delayed(const Duration(seconds: 3), () {
                if (mounted) setState(() => _showConfetti = false);
              });
            },
            child: const Text("Reset", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final engine = context.watch<CalculatorEngine>();
    final progress = (engine.totalDrank / engine.goal).clamp(0.0, 1.0);


    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // 🌊 BACKGROUND GRADIENT
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  const Text("DAILY HYDRATION",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                 
                Expanded(
  child: Center(
    child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: AspectRatio(
        aspectRatio: 1.0, // 💡 This forces it to be a perfect circle
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Using a LayoutBuilder ensures the indicator fills the square
            LayoutBuilder(
              builder: (context, constraints) {
                return SizedBox(
                  width: constraints.maxWidth * 1.3, // Adjust size here
                  height: constraints.maxWidth * 1.3,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 15,
                    backgroundColor: Colors.white10,
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF4FC3F7)),
                  ),
                );
              },
            ),
                              Text("${(progress * 100).toInt()}%",
                                style: const TextStyle(fontSize: 55, fontWeight: FontWeight.bold, color: Color(0xFFAAF0D1))),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),


                  // 🧊 STATUS CARD
                  _GlassCard(
                    child: Column(
                      children: [
                        Text(_getFunnyStatus(engine.totalDrank, engine.goal, engine.bottlesCompleted),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 18, color: Colors.white, fontStyle: FontStyle.italic)),
                        const SizedBox(height: 8),
                        Text("${engine.totalDrank} / ${engine.goal} ml",
                          style: const TextStyle(fontSize: 16, color: Colors.white60)),
                      ],
                    ),
                  ),


                  const SizedBox(height: 20),


                  // 🍼 SIDE-BY-SIDE INTERACTIVE AREA
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          Expanded(flex: 1, child: WaterButtons(onAddWater: (amount) => engine.addWater(amount))),
                          Expanded(flex: 2, child: BottleVisual(fillLevel: progress)),
                          Expanded(
                            flex: 1,
                            child: SingleChildScrollView(
                              child: Column(
                                children: List.generate(
                                  engine.bottlesCompleted,
                                  (index) => const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 4),
                                    child: Icon(Icons.local_drink_rounded, color: Color(0xFFAAF0D1), size: 24),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),


                  // 🔁 RESET
                  TextButton(
                    onPressed: () => _showResetConfirmation(context, engine),
                    child: const Text("Reset Day", style: TextStyle(color: Colors.redAccent)),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
          if (_showConfetti) const GoalConfettiOverlay(),
        ],
      ),
    );
  }
}


// --- HELPER CLASSES ---


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
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 3))..forward();
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
        builder: (_, __) => CustomPaint(
          painter: _ConfettiPainter(progress: _controller.value),
          size: MediaQuery.of(context).size,
        ),
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
    for (int i = 0; i < 100; i++) {
      paint.color = Colors.primaries[i % Colors.primaries.length].withOpacity(1 - progress);
      final x = _rand.nextDouble() * size.width;
      final y = progress * size.height + _rand.nextDouble() * 200;
      canvas.drawCircle(Offset(x, y), 3, paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
