import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedBottleVisual extends StatefulWidget {
  final double fillLevel;
  const AnimatedBottleVisual({super.key, required this.fillLevel});

  @override
  State<AnimatedBottleVisual> createState() => _AnimatedBottleVisualState();
}

class _AnimatedBottleVisualState extends State<AnimatedBottleVisual>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      height: 260,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Bottle outline
          Container(
            width: 90,
            height: 240,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.15),
                  Colors.white.withOpacity(0.02),
                ],
              ),
            ),
          ),

          // Water fill
          ClipRRect(
            borderRadius: BorderRadius.circular(36),
            child: AnimatedBuilder(
              animation: _waveController,
              builder: (_, __) {
                return CustomPaint(
                  painter: _WaterPainter(
                    fillLevel: widget.fillLevel,
                    wavePhase: _waveController.value,
                  ),
                  size: const Size(90, 240),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _WaterPainter extends CustomPainter {
  final double fillLevel;
  final double wavePhase;

  _WaterPainter({required this.fillLevel, required this.wavePhase});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF4FC3F7), Color(0xFF0288D1)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final waterHeight = size.height * (1 - fillLevel);

    path.moveTo(0, waterHeight);

    for (double x = 0; x <= size.width; x++) {
      path.lineTo(
        x,
        waterHeight +
            sin((x / size.width * 2 * pi) + (wavePhase * 2 * pi)) * 6,
      );
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WaterPainter oldDelegate) =>
      oldDelegate.fillLevel != fillLevel ||
      oldDelegate.wavePhase != wavePhase;
}
