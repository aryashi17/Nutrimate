import 'package:flutter/material.dart';

class AppTheme {
  // --- THE PALETTE ---
  // Deep Charcoal (almost black) for the background
  static const Color charcoal = Color(0xFF121212); 
  // Slightly lighter charcoal for Cards/Dialogs
  static const Color surfaceGrey = Color(0xFF1E1E1E); 
  
  // The Accents
  static const Color neonBlue = Color(0xFF00E5FF);   // Electric Cyan/Blue
  static const Color neonPurple = Color(0xFFBC13FE); // Vibrant Purple

  // --- THE THEME DATA ---
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: neonBlue, // Default primary color
    scaffoldBackgroundColor: charcoal,
    useMaterial3: true,
    fontFamily: 'Inter',

    // Define the Color Scheme (This controls default widget colors)
    colorScheme: const ColorScheme.dark(
      primary: neonBlue,
      secondary: Color.fromARGB(255, 72, 18, 93),
      surface: surfaceGrey,
      background: charcoal,
      onPrimary: Colors.black, // Text on Blue buttons should be black
      onSecondary: Colors.white, // Text on Purple buttons should be white
    ),
    
    // Default Button Styles (Neon Blue by default)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: neonBlue,
        foregroundColor: Colors.black, // Text color
        elevation: 8,
        shadowColor: neonBlue.withOpacity(0.5), // Glowing shadow
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),

    // Outlined Buttons (Purple Borders)
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color.fromARGB(255, 92, 40, 112),
        side: const BorderSide(color: Color.fromARGB(255, 65, 154, 102), width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    ),
    
    // Text Styles
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
    ),
  );
}