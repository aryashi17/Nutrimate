import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// IMPORTANT: Replace 'your_project_name' with the actual name in your pubspec.yaml
import 'package:nutrimate_app/features/menu_view/mess_logger_screen.dart';
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
      debugShowCheckedModeBanner: false, // Removes the debug banner for a cleaner look
      title: 'Nutrimate',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFAAF0D1), // Your Mint Green
        scaffoldBackgroundColor: const Color(0xFF121212), // Your Charcoal
        fontFamily: 'Inter', // Ensure this is in your pubspec.yaml or remove this line
      ),
      // We replaced the Scaffold placeholder with your actual Member 1 Screen
      home: const MessLoggerScreen(), 
    );
  }
}