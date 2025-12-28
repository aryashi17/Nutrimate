import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nutrimate_app/features/profile/user_profile.dart';
import '../../core/services/health_calculator.dart';
import '../../core/models/user_profile.dart';
import '../auth/login_screen.dart'; // Import your login screen
import 'activity_chat_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String gender = 'Male';
  final TextEditingController _ageCtrl = TextEditingController();
  final TextEditingController _heightCtrl = TextEditingController();
  final TextEditingController _weightCtrl = TextEditingController();
  String activityLevel = 'Moderate';
  bool _isLoading = false; // Add loading state

  // --- LOGOUT FUNCTION ---
  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      // Navigate back to Login Screen and remove all previous routes
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) =>  LoginScreen()),
        (route) => false,
      );
    }
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true); // Start loading

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No user logged in!"))
      );
      setState(() => _isLoading = false);
      return;
    }

    try {
      int age = int.parse(_ageCtrl.text);
      double height = double.parse(_heightCtrl.text);
      double weight = double.parse(_weightCtrl.text);

      int bmr = HealthCalculator.calculateBMR(gender, age, height, weight);
      int tdee = HealthCalculator.calculateTDEE(bmr, activityLevel);
      int water = HealthCalculator.calculateWater(weight);

      UserProfile profile = UserProfile(
        uid: user.uid,
        gender: gender,
        age: age,
        heightCm: height,
        weightKg: weight,
        activityLevel: activityLevel,
        dailyCalorieTarget: tdee,
        dailyProteinTarget: (weight * 1.8).toInt(),
        dailyWaterTarget: water,
      );

      // Save to Firebase
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(profile.toMap(), SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Plan Generated Successfully!"))
        );
        Navigator.pop(context); // Go back to previous screen
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"))
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false); // Stop loading
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Your Body Profile", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // --- LOGOUT BUTTON ---
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            tooltip: "Logout",
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Let's calibrate your nutrition plan.", style: TextStyle(color: Colors.white54)),
              const SizedBox(height: 30),

              Row(
                children: [
                  _genderButton("Male"),
                  const SizedBox(width: 20),
                  _genderButton("Female"),
                ],
              ),
              const SizedBox(height: 20),

              _buildInput("Age", _ageCtrl, "Years"),
              _buildInput("Height", _heightCtrl, "cm"),
              _buildInput("Weight", _weightCtrl, "kg"),

              const SizedBox(height: 30),
              const Text("ACTIVITY LEVEL", style: TextStyle(color: Color(0xFFAAF0D1), fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              
              // Activity Level Selector
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0xFFAAF0D1)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(activityLevel, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        TextButton.icon(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ActivityChatScreen(
                              onLevelSelected: (level) => setState(() => activityLevel = level),
                            )));
                          },
                          icon: const Icon(Icons.chat_bubble_outline, color: Color(0xFFAAF0D1)),
                          label: const Text("Talk to AI Trainer", style: TextStyle(color: Color(0xFFAAF0D1))),
                        ),
                      ],
                    ),
                    const Text("Not sure? Tap 'Talk to AI Trainer' and describe your day!", style: TextStyle(color: Colors.white38, fontSize: 12)),
                  ],
                ),
              ),

              const SizedBox(height: 50),
              
              // --- GENERATE BUTTON ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile, // Disable if loading
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFAAF0D1), 
                    foregroundColor: Colors.black
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.black) 
                    : const Text("GENERATE MY PLAN", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController ctrl, String suffix) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        style: const TextStyle(color: Colors.white),
        validator: (val) => (val == null || val.isEmpty) ? "Required" : null, // Added validation logic
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white54),
          suffixText: suffix,
          enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFAAF0D1))),
        ),
      ),
    );
  }

  Widget _genderButton(String val) {
    bool isSelected = gender == val;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => gender = val),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFAAF0D1) : const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              val,
              style: TextStyle(color: isSelected ? Colors.black : Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}