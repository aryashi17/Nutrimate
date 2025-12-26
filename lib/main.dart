import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/calculator_engine.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => CalculatorEngine()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nutrimate',
      home: Scaffold(
        appBar: AppBar(title: const Text('Plate App MVP')),
        body: const Center(child: Text('Member 1, 3, 4: Start coding in your folders!')),
      ),
    );
  }
}