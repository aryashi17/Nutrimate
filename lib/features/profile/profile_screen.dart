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
  
  final TextEditingController _ageCtrl = TextEditingController();
  final TextEditingController _heightCtrl = TextEditingController();
  final TextEditingController _weightCtrl = TextEditingController();

  bool _isEditing = true;
  bool _isLoading = true;
  UserProfile? _currentProfile;

  String _gender = 'Male';
  String _activityLevel = 'Moderate';
  String _goal = 'Maintain';

  // These lists must match exactly what is in the dropdown logic below
  final List<String> _goals = ['Weight Loss', 'Maintain', 'Muscle Gain'];
  final List<String> _activities = ['Sedentary', 'Lightly Active', 'Moderate', 'Very Active', 'Super Active'];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data() != null) {
          final profile = UserProfile.fromMap(doc.data()!);
          if (mounted) {
            setState(() {
              _currentProfile = profile;
              _ageCtrl.text = profile.age.toString();
              _heightCtrl.text = profile.heightCm.toString();
              _weightCtrl.text = profile.weightKg.toString();
              _gender = profile.gender;
              
              // --- CRASH FIX: DATA SANITIZATION ---
              // If the database has "Light" but our list has "Lightly Active", the app crashes.
              // This logic forces a fallback to "Moderate" if the value isn't found.
              
              if (_activities.contains(profile.activityLevel)) {
                _activityLevel = profile.activityLevel;
              } else {
                // Determine a safe default if the DB value is invalid/old
                _activityLevel = 'Moderate'; 
                // Optional: print debug log
                // debugPrint("Warning: Activity level '${profile.activityLevel}' not found in list. Defaulting to Moderate.");
              }

              if (_goals.contains(profile.goal)) {
                 _goal = profile.goal;
              } else {
                 _goal = 'Maintain';
              }
         

              _isEditing = false;
              _isLoading = false;
            });
            
            // Sync Engine so Dashboard gets the data immediately
             _syncEngine(profile.weightKg, profile.heightCm, profile.gender);
          }
        } else {
          // No profile found, user must create one
          setState(() => _isLoading = false);
        }
      } catch (e) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Helper to update the Provider Engine
  void _syncEngine(double weight, double height, String gender) {
     if (!mounted) return; // Safety check
     final engine = Provider.of<CalculatorEngine>(context, listen: false);
     engine.updateProfile(
       newWeight: weight, 
       newHeight: height, 
       newGender: gender
     );
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      int age = int.parse(_ageCtrl.text);
      double height = double.parse(_heightCtrl.text);
      double weight = double.parse(_weightCtrl.text);

      // 1. Calculate Base Stats
      double bmi = HealthCalculator.calculateBMI(height, weight);
      int bmr = HealthCalculator.calculateBMR(_gender, age, height, weight);
      int tdee = HealthCalculator.calculateTDEE(bmr, _activityLevel);
      
      // 2. Adjust for Goal
      int targetCalories = HealthCalculator.adjustCaloriesForGoal(tdee, _goal);
      
      // 3. Calculate Macros
      Map<String, int> macros = HealthCalculator.calculateMacros(targetCalories, _goal);
      
      int water = HealthCalculator.calculateWater(weight);

      UserProfile profile = UserProfile(
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

      // Save to Firebase
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(profile.toMap());

      // Update the Engine Provider
      if (mounted) {
        _syncEngine(weight, height, _gender);
      }

      if (mounted) {
        setState(() {
          _currentProfile = profile;
          _isEditing = false;
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile Updated!")));
        
        // If we came from the "Complete Setup" button, go back to dashboard
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => LoginScreen()), (r) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(_isEditing ? "Edit Profile" : "My Plan", style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (!_isLoading && _currentProfile != null)
            IconButton(
              icon: Icon(_isEditing ? Icons.close : Icons.edit, color: Colors.white),
              onPressed: () => setState(() => _isEditing = !_isEditing),
            ),
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout, color: Colors.redAccent)),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFFAAF0D1)))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: _isEditing ? _buildEditForm() : _buildDisplayView(),
          ),
    );
  }

  // --- VIEW MODE ---
  Widget _buildDisplayView() {
    final p = _currentProfile!;
    final mint = const Color(0xFFAAF0D1);
    
    return Column(
      children: [
        // Hero Card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [mint.withOpacity(0.2), const Color(0xFF1E1E1E)]),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: mint.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Text("DAILY GOAL (${p.goal.toUpperCase()})", style: const TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 2)),
              const SizedBox(height: 8),
              Text("${p.dailyCalorieTarget}", style: TextStyle(color: mint, fontSize: 48, fontWeight: FontWeight.bold)),
              const Text("Calories / Day", style: TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        // Macros Grid
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard("PROTEIN", "${p.dailyProteinTarget}g", Icons.fitness_center, Colors.blueAccent),
            _buildStatCard("CARBS", "${p.dailyCarbTarget}g", Icons.rice_bowl, Colors.orange),
            _buildStatCard("FATS", "${p.dailyFatTarget}g", Icons.opacity, Colors.yellow),
            _buildStatCard("WATER", "${(p.dailyWaterTarget/1000).toStringAsFixed(1)}L", Icons.water_drop, Colors.cyan),
          ],
        ),
        
        const SizedBox(height: 24),
        // Details List
        _buildDetailRow("BMI", "${p.bmi}", Icons.monitor_weight),
        _buildDetailRow("Activity", p.activityLevel, Icons.directions_run),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.white54, size: 18),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.white54)),
          const Spacer(),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // --- EDIT MODE ---
  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Let's build your plan.", style: TextStyle(color: Colors.white54)),
          const SizedBox(height: 20),
          
          Row(children: [_genderButton("Male"), const SizedBox(width: 20), _genderButton("Female")]),
          const SizedBox(height: 20),
          
          _buildInput("Age", _ageCtrl, "Years"),
          _buildInput("Height", _heightCtrl, "cm"),
          _buildInput("Weight", _weightCtrl, "kg"),
          
          const SizedBox(height: 20),
          _buildDropdown("Activity Level", _activityLevel, _activities, (val) => setState(() => _activityLevel = val!)),
          const SizedBox(height: 20),
          _buildDropdown("Your Goal", _goal, _goals, (val) => setState(() => _goal = val!)),
          
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFAAF0D1), foregroundColor: Colors.black),
              child: const Text("GENERATE PLAN", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController ctrl, String suffix) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(color: Colors.white),
        validator: (v) => v!.isEmpty ? "Required" : null,
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

  Widget _buildDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFFAAF0D1), fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: const Color(0xFF1E1E1E),
              style: const TextStyle(color: Colors.white),
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _genderButton(String val) {
    bool isSelected = _gender == val;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _gender = val),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFAAF0D1) : const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(child: Text(val, style: TextStyle(color: isSelected ? Colors.black : Colors.white, fontWeight: FontWeight.bold))),
        ),
      ),
    );
  }
}