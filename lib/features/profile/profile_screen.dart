import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../../core/services/health_calculator.dart';
import '../../core/services/calculator_engine.dart';
import '../../core/models/user_profile.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _ageCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();

  bool _isEditing = true;
  bool _isLoading = true;
  UserProfile? _currentProfile;

  String _gender = 'Male';
  String _activityLevel = 'Moderate';
  String _goal = 'Maintain';

  final List<String> _goals = ['Weight Loss', 'Maintain', 'Muscle Gain'];
  final List<String> _activities = [
    'Sedentary',
    'Lightly Active',
    'Moderate',
    'Very Active',
    'Super Active'
  ];

  static const Color mint = Color(0xFFAAF0D1);
  static const Color cyan = Color(0xFF6EF3E6);
  static const Color deep = Color(0xFF0B0F14);

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /*──────────────────── DATA ────────────────────*/

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc =
        await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    if (doc.exists && doc.data() != null) {
      final profile = UserProfile.fromMap(doc.data()!);

      _ageCtrl.text = profile.age.toString();
      _heightCtrl.text = profile.heightCm.toString();
      _weightCtrl.text = profile.weightKg.toString();
      _gender = profile.gender;
      _activityLevel = _activities.contains(profile.activityLevel)
          ? profile.activityLevel
          : 'Moderate';
      _goal = _goals.contains(profile.goal) ? profile.goal : 'Maintain';

      Provider.of<CalculatorEngine>(context, listen: false)
          .updateProfile(
              newWeight: profile.weightKg,
              newHeight: profile.heightCm,
              newGender: profile.gender);

      setState(() {
        _currentProfile = profile;
        _isEditing = false;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  /*──────────────────── SAVE ────────────────────*/

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final user = FirebaseAuth.instance.currentUser!;
    final age = int.parse(_ageCtrl.text);
    final height = double.parse(_heightCtrl.text);
    final weight = double.parse(_weightCtrl.text);

    final bmi = HealthCalculator.calculateBMI(height, weight);
    final bmr = HealthCalculator.calculateBMR(_gender, age, height, weight);
    final tdee = HealthCalculator.calculateTDEE(bmr, _activityLevel);
    final targetCalories = HealthCalculator.adjustCaloriesForGoal(tdee, _goal);
    final macros = HealthCalculator.calculateMacros(targetCalories, _goal);
    final water = HealthCalculator.calculateWater(weight);

    final profile = UserProfile(
      uid: user.uid,
      gender: _gender,
      age: age,
      heightCm: height,
      weightKg: weight,
      activityLevel: _activityLevel,
      goal: _goal,
      bmi: bmi,
      dailyCalorieTarget: targetCalories,
      dailyProteinTarget: macros['protein']!,
      dailyCarbTarget: macros['carbs']!,
      dailyFatTarget: macros['fats']!,
      dailyWaterTarget: water,
    );

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set(profile.toMap());

    setState(() {
      _currentProfile = profile;
      _isEditing = false;
      _isLoading = false;
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Profile Updated")));

    if (Navigator.canPop(context)) Navigator.pop(context);
  }

  /*──────────────────── UI ────────────────────*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(_isEditing ? "Edit Profile" : "My Plan"),
        actions: [
          if (_currentProfile != null && !_isLoading)
            IconButton(
              icon: Icon(_isEditing ? Icons.close : Icons.edit),
              onPressed: () => setState(() => _isEditing = !_isEditing),
            ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: _logout,
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            radius: 1.6,
            center: Alignment.topCenter,
            colors: [
              Color(0xFF1A2233),
              deep,
            ],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: mint))
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 120, 18, 40),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _isEditing ? _editView() : _displayView(),
                ),
              ),
      ),
    );
  }

  /*──────────────────── DISPLAY ────────────────────*/

  Widget _displayView() {
    final p = _currentProfile!;
    return Column(
      children: [
        _heroCard(p),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 2.0, // 🔥 SMALLER
          children: [
            _stat("PROTEIN", "${p.dailyProteinTarget}g", Icons.fitness_center),
            _stat("CARBS", "${p.dailyCarbTarget}g", Icons.rice_bowl),
            _stat("FATS", "${p.dailyFatTarget}g", Icons.opacity),
            _stat(
                "WATER",
                "${(p.dailyWaterTarget / 1000).toStringAsFixed(1)}L",
                Icons.water_drop),
          ],
        ),
        const SizedBox(height: 14),
        _divider(),
        _detail("BMI", "${p.bmi}", Icons.monitor_weight),
        _detail("Activity", p.activityLevel, Icons.directions_run),
      ],
    );
  }

  Widget _heroCard(UserProfile p) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1, end: 1.03),
      duration: const Duration(seconds: 3),
      curve: Curves.easeInOut,
      builder: (_, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: _glass(
        glow: true,
        child: Column(
          children: [
            Text("DAILY GOAL (${p.goal.toUpperCase()})",
                style: const TextStyle(
                    color: Colors.white54, fontSize: 11, letterSpacing: 2)),
            const SizedBox(height: 4),
            ShaderMask(
              shaderCallback: (b) =>
                  const LinearGradient(colors: [mint, cyan])
                      .createShader(b),
              child: Text("${p.dailyCalorieTarget}",
                  style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: Colors.white)),
            ),
            const Text("Calories / Day",
                style: TextStyle(color: Colors.white54, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  /*──────────────────── EDIT ────────────────────*/

  Widget _editView() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _glass(
            child: Column(
              children: [
                _genderSelector(),
                const SizedBox(height: 12),
                _input("Age", _ageCtrl, "Years"),
                _input("Height", _heightCtrl, "cm"),
                _input("Weight", _weightCtrl, "kg"),
                const SizedBox(height: 10),
                _dropdown("Activity Level", _activityLevel, _activities,
                    (v) => setState(() => _activityLevel = v!)),
                const SizedBox(height: 10),
                _dropdown("Your Goal", _goal, _goals,
                    (v) => setState(() => _goal = v!)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: mint,
                foregroundColor: Colors.black,
                elevation: 10,
                shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text("GENERATE PLAN",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            ),
          ),
        ],
      ),
    );
  }

  /*──────────────────── COMPONENTS ────────────────────*/

  Widget _glass({required Widget child, bool glow = false}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(12), // 🔥 smaller
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
            boxShadow: glow
                ? [
                    BoxShadow(
                        color: mint.withOpacity(0.25),
                        blurRadius: 20,
                        spreadRadius: 2)
                  ]
                : [],
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.08),
                Colors.white.withOpacity(0.02),
              ],
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _stat(String label, String value, IconData icon) {
    return StatefulBuilder(builder: (_, setHover) {
      bool hovered = false;
      return MouseRegion(
        onEnter: (_) => setHover(() => hovered = true),
        onExit: (_) => setHover(() => hovered = false),
        child: AnimatedScale(
          scale: hovered ? 1.05 : 1,
          duration: const Duration(milliseconds: 180),
          child: _glass(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, size: 16, color: mint),
                Text(value,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                Text(label,
                    style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 9,
                        letterSpacing: 1.2)),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _detail(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white54),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.white54)),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            mint.withOpacity(0.4),
            Colors.transparent
          ],
        ),
      ),
    );
  }

  Widget _input(String label, TextEditingController c, String suffix) {
    return TextFormField(
      controller: c,
      validator: (v) => v!.isEmpty ? "Required" : null,
      style: const TextStyle(color: Colors.white),
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        labelStyle: const TextStyle(color: Colors.white54),
        enabledBorder:
            const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
        focusedBorder:
            const UnderlineInputBorder(borderSide: BorderSide(color: mint)),
      ),
    );
  }

  Widget _dropdown(String label, String value, List<String> items,
      ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: deep,
      decoration:
          InputDecoration(labelText: label, labelStyle: const TextStyle(color: mint)),
      items:
          items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _genderSelector() {
    return Row(
      children: ['Male', 'Female'].map((g) {
        final selected = _gender == g;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _gender = g),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 12),
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: selected ? mint : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                border:
                    Border.all(color: mint.withOpacity(selected ? 1 : 0.3)),
              ),
              child: Center(
                child: Text(g,
                    style: TextStyle(
                        color: selected ? Colors.black : Colors.white,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false);
  }
}
