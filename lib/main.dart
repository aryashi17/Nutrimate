import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

// --- SERVICE & CORE IMPORTS ---
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/services/calculator_engine.dart';
import 'core/services/health_trivia_service.dart';
import 'core/services/streak_services.dart';

// --- FEATURE IMPORTS ---
import 'features/auth/login_screen.dart';
import 'features/menu_view/mess_logger_screen.dart';
import '../features/dashboard/dashboard_screen.dart'; 
import 'features/reports/summary_screen.dart';
import 'features/profile/profile_screen.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        // Using ChangeNotifierProvider to allow UI updates from CalculatorEngine
        ChangeNotifierProvider(create: (_) => CalculatorEngine()),
      ],
      child: const MyApp(),
    ),
  );
}

// 1. THE APP ROOT
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutriMate',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
    );
  }
}

// 2. THE GATEKEEPER (AuthWrapper)
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // A. Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF121212),
            body: Center(child: CircularProgressIndicator(color: Color(0xFFAAF0D1))),
          );
        }
        // B. Logged In -> Go to The Hub
        if (snapshot.hasData) {
          // TRICK: Trigger data fetch here once user is confirmed
          Provider.of<CalculatorEngine>(context, listen: false).fetchInitialData();
          return const NeonWelcomeScreen();
        }
        // C. Not Logged In -> Go to Login
        return const LoginScreen();
      },
    );
  }
}


class NeonWelcomeScreen extends StatelessWidget {
  const NeonWelcomeScreen({super.key});

  void _showTrivia(BuildContext context) {
    
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
    final user = FirebaseAuth.instance.currentUser;
    final secondaryColor = AppTheme.neonBlue;
    final streakService = StreakService();

    // 1. LISTEN TO THE ENGINE
    // We use Consumer here so this screen rebuilds if the profile data changes
    return Consumer<CalculatorEngine>(
      builder: (context, engine, child) {
        
        // 2. CHECK IF PROFILE IS INCOMPLETE
        // Assuming 0 or 0.0 means "not set yet"
        bool isProfileIncomplete = engine.weight == 0 || engine.height == 0;

        return Scaffold(
          backgroundColor: AppTheme.charcoal,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.bar_chart, color: Colors.white70),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SummaryScreen())),
            ),
            title: Center(
              // ... (Your existing streak code remains exactly the same) ...
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
            child: SingleChildScrollView(
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
                        Shadow(blurRadius: 20.0, color: AppTheme.neonPurple.withValues(alpha: 0.7), offset: Offset.zero),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text("Logged in as: ${user?.email ?? 'Guest'}", style: const TextStyle(color: Colors.white54, fontSize: 14)),
                  const SizedBox(height: 50),

                  // 3. CONDITIONAL RENDERING
                  if (isProfileIncomplete) ...[
                    // --- OPTION A: PROFILE INCOMPLETE -> SHOW SETUP BUTTON ---
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.1),
                        border: Border.all(color: Colors.redAccent),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
                          SizedBox(width: 10),
                          Expanded(child: Text("Profile incomplete. Please set up your body metrics to use the tools.", style: TextStyle(color: Colors.white70))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildMenuButton(
                      context,
                      label: "COMPLETE SETUP",
                      color: Colors.greenAccent, // Bright color to encourage clicking
                      textColor: Colors.black,
                      icon: Icons.person_add,
                      destination: const ProfileScreen(), 
                    ),
                  ] else ...[
                    // --- OPTION B: PROFILE COMPLETE -> SHOW NORMAL MENU ---
                    _buildMenuButton(
                      context,
                      label: "OPEN DASHBOARD",
                      color: Colors.white,
                      textColor: Colors.black,
                      icon: Icons.dashboard_customize,
                      destination: const HomeScreen(),
                    ),
                    const SizedBox(height: 20),
                    _buildMenuButton(
                      context,
                      label: "FUEL STATION",
                      color: secondaryColor,
                      textColor: Colors.black,
                      icon: Icons.restaurant,
                      destination: const MessLoggerScreen(),
                    ),
                  ],

                  const SizedBox(height: 40),
                  
                  // --- LOGOUT (Always visible) ---
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => FirebaseAuth.instance.signOut(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.neonPurple,
                        side: const BorderSide(color: AppTheme.neonPurple, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("SIGN OUT", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuButton(BuildContext context, {
    required String label,
    required Color color,
    required Color textColor,
    required IconData icon,
    required Widget destination,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon, color: textColor),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destination),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          padding: const EdgeInsets.symmetric(vertical: 18),
          elevation: 10,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          shadowColor: color.withValues(alpha: 0.5),
        ),
        label: Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.0),
        ),
      ),
    );
  }
}