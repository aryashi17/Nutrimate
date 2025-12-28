import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

// --- IMPORTS (Ensure these paths match your project) ---
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/services/calculator_engine.dart'; // Or health_calculator.dart if you renamed it
import 'features/auth/login_screen.dart';
import 'features/menu_view/mess_logger_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/dashboard/dashboard_screen.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        // Ensure you have this provider if your app uses it, otherwise remove
        Provider(create: (_) => CalculatorEngine()), 
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
      // We point 'home' to the AuthWrapper to decide where to go
      home: const AuthWrapper(),
    );
  }
}

// 2. THE GATEKEEPER (AuthWrapper)
// Decides: Are we logged in? 
// Yes -> Show NeonWelcomeScreen (The Hub)
// No  -> Show LoginScreen
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
          return const NeonWelcomeScreen();
        }
        // C. Not Logged In -> Go to Login
        return const LoginScreen();
      },
    );
  }
}

// 3. THE CENTRAL HUB (NeonWelcomeScreen)
// This is your main menu. I added a button for "Dashboard" so HomeScreen isn't lost.
// 3. THE CENTRAL HUB (NeonWelcomeScreen)
class NeonWelcomeScreen extends StatelessWidget {
  const NeonWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    // final primaryColor = const Color(0xFFAAF0D1); // Mint (No longer needed for the removed button)
    final secondaryColor = AppTheme.neonBlue;

    return Scaffold(
      backgroundColor: AppTheme.charcoal,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- HEADER ---
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
              Text(
                "Logged in as: ${user?.email ?? 'Student'}",
                style: const TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 50),

              // --- BUTTON 1: DASHBOARD ---
              _buildMenuButton(
                context, 
                label: "OPEN DASHBOARD",
                color: Colors.white, 
                textColor: Colors.black,
                icon: Icons.dashboard_customize,
                destination: const HomeScreen(),
              ),

              const SizedBox(height: 20),

              // --- BUTTON 2: MESS HALL ---
              _buildMenuButton(
                context, 
                label: "FUEL STATION",
                color: secondaryColor,
                textColor: Colors.black,
                icon: Icons.restaurant,
                destination: const MessLoggerScreen(),
              ),
              
              const SizedBox(height: 40),

              // --- BUTTON 3: LOGOUT ---
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
                  child: const Text(
                    "SIGN OUT",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget to make buttons look consistent
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

  // Helper widget to make buttons look consistent
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
