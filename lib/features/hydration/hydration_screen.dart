import 'package:flutter/material.dart';

class HydrationScreen extends StatelessWidget {
  const HydrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hydration")),
      body: const Center(
        child: Text("Hydration Tracker"),
      ),
    );
  }
}
