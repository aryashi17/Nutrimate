import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nutrimate_app/core/services/health_trivia_service.dart';
import 'package:nutrimate_app/core/services/streak_services.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/services/calculator_engine.dart';
import 'features/auth/login_screen.dart';
import 'features/menu_view/mess_logger_screen.dart';
import 'features/profile/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CalculatorEngine()),
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
      debugShowCheckedModeBanner: false,
      title: 'Nutrimate',
      theme: AppTheme.darkTheme,
      home: const NeonWelcomeScreen(), // Changed to AuthWrapper to handle login state
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) {
          return const NeonWelcomeScreen();
        }
        return LoginScreen();
      },
    );
  }
}

// CHANGED TO StatefulWidget to support the "unrolling" state
class NeonWelcomeScreen extends StatelessWidget {
  const NeonWelcomeScreen({super.key});

  // Small helper function to show the trivia as a sleek bottom sheet
  void _showTrivia(BuildContext context) {
    final trivia = HealthTrivia.getTodaysTrivia();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // Keeps it floating
      builder: (context) => Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          border: Border.all(color: AppTheme.neonPurple.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Only takes up needed space
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            const Text("💡 DAILY HEALTH GK", style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 2)),
            const SizedBox(height: 15),
            Text(trivia['q']!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(height: 30, color: Colors.white10),
            Text(trivia['a']!, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFFAAF0D1), fontSize: 15)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
final streakService = StreakService();

    return Scaffold(
      backgroundColor: AppTheme.charcoal,
      // Added an AppBar with just the lightbulb icon
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- STREAK COUNTER ---
            StreamBuilder<int>(
  stream: streakService.streakStream,
  builder: (context, snapshot) {
    int streakCount = snapshot.data ?? 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: streakCount > 0 ? Colors.orangeAccent : Colors.white24,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_fire_department, 
            color: streakCount > 0 ? Colors.orangeAccent : Colors.white24, 
            size: 18
          ),
          const SizedBox(width: 4),
          Text(
            "$streakCount",
            style: TextStyle(
              color: streakCount > 0 ? Colors.orangeAccent : Colors.white24,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
),
          ],
        ),
        actions: [
          // --- TRIVIA LIGHTBULB ---
          IconButton(
            icon: const Icon(Icons.lightbulb_outline, color: Colors.amberAccent),
            tooltip: "Daily Health GK",
            onPressed: () => _showTrivia(context),
          ),
          const SizedBox(width: 15),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "WELCOME TO\nNUTRIMATE",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 2.0,
                  height: 1.2,
                  shadows: [
                    Shadow(blurRadius: 10.0, color: AppTheme.neonPurple, offset: Offset.zero),
                    Shadow(blurRadius: 20.0, color: AppTheme.neonPurple.withOpacity(0.7), offset: Offset.zero),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Logged in as: ${user?.email ?? 'Student'}",
                style: const TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 50),

              // --- BUTTON 1: MESS HALL ---
              _buildNeonButton(
                text: "ENTER MESS HALL",
                color: AppTheme.neonBlue,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MessLoggerScreen())),
              ),
              const SizedBox(height: 20),

              // --- BUTTON 2: SETUP PROFILE ---
              _buildNeonButton(
                text: "SETUP BODY PROFILE",
                color: const Color(0xFFAAF0D1),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())),
              ),
              const SizedBox(height: 40),

              // --- LOGOUT ---
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => FirebaseAuth.instance.signOut(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.neonPurple,
                    side: const BorderSide(color: AppTheme.neonPurple, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  child: const Text("SIGN OUT", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper for consistent neon buttons
  Widget _buildNeonButton({required String text, required Color color, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shadowColor: color,
          elevation: 12,
        ),
        child: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
      ),
    );
  }
}