import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import 'core/theme/theme_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/services/notification_service.dart';
import 'core/services/calculator_engine.dart';
import 'core/services/health_trivia_service.dart';
import 'core/services/streak_services.dart';
import 'core/services/water_reminder_scheduler.dart';

import 'firebase_options.dart';
import 'features/auth/login_screen.dart';
import 'features/menu_view/mess_logger_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/reports/summary_screen.dart';
import 'features/profile/profile_screen.dart';
import 'package:google_fonts/google_fonts.dart';


import 'package:flutter/material.dart';
import 'package:nutrimate_app/features/crossword/crossword_screen.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CalculatorEngine()),
        ChangeNotifierProvider(create: (_) => ThemeModeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

/*──────────────────────────────────────────────────────────*/

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeModeProvider>().mode;

    return MaterialApp(
      title: 'NutriMate',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const AuthWrapper(),
    );
  }
}

/*──────────────────────────────────────────────────────────*/

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF0B0F14),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFAAF0D1)),
            ),
          );
        }

        if (snapshot.hasData) {
          Provider.of<CalculatorEngine>(context, listen: false)
              .fetchInitialData();
          WaterReminderScheduler.scheduleEveryTwoHours();
          return const NeonWelcomeScreen();
        }

        return const LoginScreen();
      },
    );
  }
}

/*──────────────────────────────────────────────────────────*/
/* 🔮 GLASSMORPHISM CONTAINER */

class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.08),
                Colors.white.withOpacity(0.02),
              ],
            ),
            border: Border.all(color: Colors.white12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: child,
        ),
      ),
    );
  }
}
class NeonButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  const NeonButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedScale(
        scale: _hover ? 1.03 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: SizedBox(
          width: double.infinity, // 🔥 FULL WIDTH
          height: 68,             // 🔥 BIG CTA HEIGHT
          child: ElevatedButton.icon(
            icon: Icon(widget.icon, size: 22, color: widget.textColor),
            label: Text(
              widget.label,
              style: TextStyle(
                fontSize: 20,        // 🔥 BIG TEXT
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: widget.textColor,
              ),
            ),
            onPressed: widget.onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.color,
              elevation: _hover ? 22 : 14,
              shadowColor: widget.color.withOpacity(0.7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/*──────────────────────────────────────────────────────────*/

class NeonWelcomeScreen extends StatelessWidget {
  const NeonWelcomeScreen({super.key});
void _showTrivia(BuildContext context) {
  final trivia = HealthTrivia.getTodaysTrivia();
  bool showAnswer = false;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) {
      return StatefulBuilder(
        builder: (context, setState) {
          return GlassContainer(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 16),

                const Text(
                  "💡 DAILY HEALTH GK",
                  style: TextStyle(
                    letterSpacing: 2,
                    color: Colors.white54,
                    fontSize: 11,
                  ),
                ),

                const SizedBox(height: 18),

                // QUESTION
                Text(
                  trivia['q'] ?? "",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                // SHOW ANSWER BUTTON
                if (!showAnswer)
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        setState(() => showAnswer = true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.neonBlue,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 10,
                        shadowColor:
                            AppTheme.neonBlue.withOpacity(0.6),
                      ),
                      child: const Text(
                        "SHOW ANSWER",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),

                // ANSWER (revealed)
                if (showAnswer) ...[
                  const Divider(
                    height: 30,
                    color: Colors.white24,
                  ),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: showAnswer ? 1 : 0,
                    child: Text(
                      trivia['a'] ?? "",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFAAF0D1),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 10),
              ],
            ),
          );
        },
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final streakService = StreakService();

    return Consumer<CalculatorEngine>(
      builder: (context, engine, _) {
        final isProfileIncomplete =
            engine.weight == 0 || engine.height == 0;

        return Scaffold(
          backgroundColor: AppTheme.charcoal,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
  backgroundColor: Colors.transparent,
  elevation: 0,
  leading: IconButton(
    icon: const Icon(Icons.bar_chart, color: Colors.white70),
    onPressed: () => Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SummaryScreen()),
    ),
  ),
  title: null, // Removed the big GlassContainer from here
  centerTitle: true,
  actions: [
    // 🔥 NEW COMPACT STREAK ICON
    StreamBuilder<int>(
      stream: streakService.streakStream,
      builder: (_, snapshot) {
        final streak = snapshot.data ?? 0;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.local_fire_department, color: Colors.orangeAccent, size: 22),
            Text("$streak", style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        );
      },
    ),
    const SizedBox(width: 15),// Spacing between Streak and Bulb
    
    
    // 2. 🔥 ADD THIS: The Puzzle Icon
    IconButton(
      icon: const Icon(
        Icons.extension_rounded, // Puzzle piece icon
        color: Colors.greenAccent,
        size: 24,
      ),
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CrosswordScreen()),
      ),
    ),
    const SizedBox(width: 8),
    
    
    IconButton(
      icon: const Icon(
        Icons.lightbulb_outline,
        color: Colors.amberAccent,
        size: 24,
      ),
      onPressed: () => _showTrivia(context),
    ),
    const SizedBox(width: 12), // Padding from the right edge
  ],
),

          body: Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 1.2,
                colors: [
                  Color(0xFF1A1F2B),
                  Color(0xFF0B0F14),
                ],
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    const SizedBox(height: 100),       
                    Text(
                          "WELCOME TO\nNUTRIMATE",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.orbitron(
                            fontSize: 40,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 3,
                            color: const Color.fromARGB(255, 255, 252, 254),
                            shadows: [
                              Shadow(
                                blurRadius: 20,
                                color: const Color.fromARGB(255, 226, 110, 255),
                              ),
                            ],
                          ),
                        ),

                    const SizedBox(height: 12),
                   Text(
  "Logged in as ${user?.email}",
  style: GoogleFonts.montserrat (
    color: Colors.white54,
    fontSize: 15,
    letterSpacing: 8,
    fontWeight: FontWeight.w500,
  ),
),

                    const SizedBox(height: 40),

                    if (isProfileIncomplete)
                      GlassContainer(
                        child: Column(
                          children: [
                            const Icon(Icons.warning_amber_rounded,
                                color: Colors.redAccent),
                            const SizedBox(height: 10),
                            const Text(
                              "Profile incomplete.\nComplete setup to continue.",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 20),
                            NeonButton(
                              label: "COMPLETE SETUP",
                              icon: Icons.person_add,
                              color: Colors.greenAccent,
                              textColor: Colors.black,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const ProfileScreen()),
                              ),
                            ),
                          ],
                        ),
                      )
                    else ...[
                      NeonButton(
                        label: "OPEN DASHBOARD",
                        icon: Icons.dashboard_customize,
                        color: Colors.white,
                        textColor: Colors.black,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const HomeScreen()),
                        ),
                      ),
                      const SizedBox(height: 20),


                      


                      NeonButton(
                        label: "FUEL STATION",
                        icon: Icons.restaurant,
                        color: AppTheme.neonBlue,
                        textColor: Colors.black,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const MessLoggerScreen()),
                        ),
                        
                      ),
                    ],
                  const SizedBox(height: 32),
                  SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: OutlinedButton(
                          onPressed: () => FirebaseAuth.instance.signOut(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.neonPurple,
                            side: const BorderSide(color: AppTheme.neonPurple, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: const Text(
                            "SIGN OUT",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),

                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
