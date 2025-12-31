import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/calculator_engine.dart';
import '../../core/services/health_calculator.dart';
import '../../core/enums/app_enums.dart';

class ProfileFormScreen extends StatefulWidget {
  const ProfileFormScreen({super.key});

  @override
  State<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends State<ProfileFormScreen> {
  // Controllers to grab text input
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  // Variables to store Dropdown selections
  Gender? _selectedGender;
  ActivityLevel? _selectedActivity;
  GoalType _selectedGoal = GoalType.lose;

  // Variable to show results (or null if not calculated yet)
  HealthGoals? _calculatedGoals;

  void _calculateAndSave() async {
    // 1. INPUT VALIDATION
    if (_ageController.text.isEmpty ||
        _heightController.text.isEmpty ||
        _weightController.text.isEmpty ||
        _selectedGender == null ||
        _selectedActivity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields to get your plan!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 2. PARSE DATA
    final int age = int.parse(_ageController.text);
    final double height = double.parse(_heightController.text);
    final double weight = double.parse(_weightController.text);
    final String genderString =
        _selectedGender == Gender.male ? 'Male' : 'Female';

    // 3. UPDATE THE ENGINE (Immediate UI update for other screens)
    final engine = Provider.of<CalculatorEngine>(context, listen: false);

    engine.updateProfile(
      newWeight: weight,
      newHeight: height,
      newGender: genderString,
    );

    // 4. PERFORM CALCULATIONS (Local display)
    final result = HealthCalculator.calculateGoals(
      gender: _selectedGender,
      age: age,
      heightCm: height,
      weightKg: weight,
      activityLevel: _selectedActivity,
      goalType: _selectedGoal,
    );

    setState(() {
      _calculatedGoals = result;
    });

    await engine.saveProfileToFirebase();

    // 6. GO BACK TO HYDRATION SCREEN
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- 1. DEFINE GOAL ITEMS ---
    final List<DropdownMenuItem<GoalType>> goalItems = const [
      DropdownMenuItem(
          value: GoalType.lose, child: Text("Lose Weight (-500 cal)")),
      DropdownMenuItem(
          value: GoalType.maintain, child: Text("Maintain Weight")),
      DropdownMenuItem(
          value: GoalType.gain, child: Text("Gain Muscle (+500 cal)")),
    ];

    // --- 2. DEFINE ACTIVITY ITEMS ---
    // We define this list here so we can check it for safety below
    final List<DropdownMenuItem<ActivityLevel>> activityItems = const [
      DropdownMenuItem(
          value: ActivityLevel.sedentary,
          child: Text("Sedentary (Office job, little movement)")),
      DropdownMenuItem(
          value: ActivityLevel.light,
          child: Text("Light (Exercise 1-3 days/week)")),
      DropdownMenuItem(
          value: ActivityLevel.moderate,
          child: Text("Moderate (Exercise 3-5 days/week)")),
      DropdownMenuItem(
          value: ActivityLevel.high,
          child: Text("Active (Exercise 6-7 days/week)")),
    ];

    // --- 3. SAFETY CHECKS (CRASH PREVENTION) ---

    if (!goalItems.any((item) => item.value == _selectedGoal)) {
      _selectedGoal = GoalType.lose;
    }
    if (_selectedActivity != null &&
        !activityItems.any((item) => item.value == _selectedActivity)) {
      _selectedActivity = ActivityLevel.sedentary;
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Setup Your Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
                "Tell us about yourself so we can calculate your exact needs."),
            const SizedBox(height: 20),
            const Text("Gender", style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<Gender>(
                    title: const Text('Male'),
                    value: Gender.male,
                    groupValue: _selectedGender,
                    onChanged: (val) => setState(() => _selectedGender = val),
                  ),
                ),
                Expanded(
                  child: RadioListTile<Gender>(
                    title: const Text('Female'),
                    value: Gender.female,
                    groupValue: _selectedGender,
                    onChanged: (val) => setState(() => _selectedGender = val),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: "Age (years)", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _heightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: "Height (cm)", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: "Weight (kg)", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),

            // --- UPDATED ACTIVITY DROPDOWN ---
            const Text("Activity Level",
                style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButtonFormField<ActivityLevel>(
              value: _selectedActivity,
              hint: const Text("Select your lifestyle"),
              items: activityItems, // Uses the list defined at top
              onChanged: (val) => setState(() => _selectedActivity = val),
              // Optional styling to match your dark theme preference if needed
              dropdownColor: const Color(0xFF1E1E1E),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 15),
              ),
            ),

            const SizedBox(height: 20),

            // --- UPDATED GOAL DROPDOWN ---
            const Text("My Goal", style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButtonFormField<GoalType>(
              value: _selectedGoal,
              items: goalItems, // Uses the list defined at top
              onChanged: (val) => setState(() => _selectedGoal = val!),
              dropdownColor: const Color(0xFF1E1E1E),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 15),
              ),
            ),

            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _calculateAndSave,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                backgroundColor: Colors.blueAccent,
              ),
              child: const Text("Calculate My Plan",
                  style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
            const SizedBox(height: 30),
            if (_calculatedGoals != null) ...[
              const Divider(thickness: 2),
              const Center(
                  child: Text("YOUR PERSONAL PLAN",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green))),
              const SizedBox(height: 15),
              _resultRow("Calories", "${_calculatedGoals!.calories} kcal"),
              _resultRow("Water", "${_calculatedGoals!.waterMl} ml"),
              _resultRow("Protein", "${_calculatedGoals!.protein} g"),
              _resultRow("Carbs", "${_calculatedGoals!.carbs} g"),
              _resultRow("Fat", "${_calculatedGoals!.fat} g"),
            ]
          ],
        ),
      ),
    );
  }

  Widget _resultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 18)),
          Text(value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}