import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

// Service & Core Imports
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/services/calculator_engine.dart';
import 'core/services/health_trivia_service.dart';
import 'core/services/streak_services.dart';

// Feature Imports
import 'features/auth/login_screen.dart';
import 'features/menu_view/mess_logger_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/reports/summary_screen.dart'; // Import for the charts icon

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
      home: const AuthWrapper(), // Changed to AuthWrapper to handle login stat
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
          // TRICK: Trigger data fetch here once user is confirmed
          Provider.of<CalculatorEngine>(context, listen: false).fetchInitialData();
          return const NeonWelcomeScreen();
        }
        return LoginScreen();
      },
    );
  }
}

class NeonWelcomeScreen extends StatelessWidget {
  const NeonWelcomeScreen({super.key});

  void _showTrivia(BuildContext context) {
    // FIX: Using null-aware operators to prevent red screen crash
    final trivia = HealthTrivia.getTodaysTrivia();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          border: Border.all(color: AppTheme.neonPurple.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            const Text("💡 DAILY HEALTH GK", style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 2)),
            const SizedBox(height: 15),
            // FIX: Prevent null pointer exception
            Text(trivia['q'] ?? "Loading...", textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(height: 30, color: Colors.white10),
            Text(trivia['a'] ?? "", textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFFAAF0D1), fontSize: 15)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // FIX: Remove '!' to prevent "Unexpected null value" error
    final user = FirebaseAuth.instance.currentUser;
    final streakService = StreakService();

    return Scaffold(
      backgroundColor: AppTheme.charcoal,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          // CHARTS ICON: Navigation for Member 4
          icon: const Icon(Icons.bar_chart, color: Colors.white70),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SummaryScreen())),
        ),
        title: Center(
          child: StreamBuilder<int>(
            stream: streakService.streakStream,
            builder: (context, snapshot) {
              int streakCount = snapshot.data ?? 0;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: streakCount > 0 ? Colors.orangeAccent : Colors.white24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.local_fire_department, color: streakCount > 0 ? Colors.orangeAccent : Colors.white24, size: 18),
                    const SizedBox(width: 4),
                    Text("$streakCount", style: TextStyle(color: streakCount > 0 ? Colors.orangeAccent : Colors.white24, fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
              );
            }
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.lightbulb_outline, color: Colors.amberAccent),
            onPressed: () => _showTrivia(context),
          ),
          const SizedBox(width: 10),
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
              // FIX: Safe access to email
              Text("Logged in as: ${user?.email ?? 'Guest'}", style: const TextStyle(color: Colors.white54, fontSize: 14)),
              const SizedBox(height: 50),
              _buildNeonButton(
                text: "ENTER MESS HALL",
                color: AppTheme.neonBlue,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MessLoggerScreen())),
              ),
              const SizedBox(height: 20),
              _buildNeonButton(
                text: "SETUP BODY PROFILE",
                color: const Color(0xFFAAF0D1),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())),
              ),
              const SizedBox(height: 40),
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