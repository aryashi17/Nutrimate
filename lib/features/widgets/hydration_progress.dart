import 'package:flutter/material.dart';


class HydrationProgress extends StatelessWidget {
  final double progress; // Value between 0.0 and 1.0


  const HydrationProgress({super.key, required this.progress});


  @override
Widget build(BuildContext context) {
    return Column(
      children: [
        const Text("Today's Goal"),
        // This is the visual "Liquid" part of your tracker
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.blue.shade100,
          color: Colors.blue,
          minHeight: 20,
        ),
        Text("${(progress * 100).toInt()}% Drunk"),
      ],
    );
  }
}
