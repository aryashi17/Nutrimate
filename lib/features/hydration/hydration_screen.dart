import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../widgets/water_button.dart';
import '../widgets/bottle_visual.dart';

class HydrationScreen extends StatefulWidget {
  const HydrationScreen({super.key});

  @override
  State<HydrationScreen> createState() => _HydrationScreenState();
}

class _HydrationScreenState extends State<HydrationScreen> {
  int _totalDrank = 0;
  int _goal = 2000;

  User? get user => FirebaseAuth.instance.currentUser;

  String get _todayId {
    final now = DateTime.now();
    return "${now.year}-${now.month}-${now.day}";
  }

  DocumentReference<Map<String, dynamic>> get _todayDoc {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('daily_stats')
        .doc(_todayId);
  }

  @override
  void initState() {
    super.initState();
    _loadHydration();
  }

  Future<void> _loadHydration() async {
    final snap = await _todayDoc.get();

    if (!snap.exists) {
      await _todayDoc.set({
        'waterDrank': 0,
        'waterGoal': 2000,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return;
    }

    setState(() {
      _totalDrank = snap.data()!['waterDrank'] ?? 0;
      _goal = snap.data()!['waterGoal'] ?? 2000;
    });
  }

  Future<void> _addWater(int amount) async {
    final newValue = _totalDrank + amount;

    setState(() {
      _totalDrank = newValue;
    });

    await _todayDoc.update({
      'waterDrank': newValue,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (newValue > _goal) {
      _showThirstWarning();
    }
  }

  void _showThirstWarning() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("I've noticed you're thirsty, are you feeling okay?"),
        backgroundColor: Colors.orangeAccent,
        duration: Duration(seconds: 3),
      ),
    );
  }

  String _getFunnyStatus() {
    double progress = _totalDrank / _goal;
    if (progress >= 1.0) return "Champion Level: Basically a Fish ";
    if (progress >= 0.75) return "Look at you, Hydration Hero! 🦸";
    if (progress >= 0.50) return "Halfway! Your skin is glowing (probably) ";
    if (progress >= 0.25) return "Emotional Support Water Level: LOW ⚠️";
    return "Your kidneys are sending a search party ";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hydration Tracker")),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 180,
                  height: 180,
                  child: CircularProgressIndicator(
                    value: (_totalDrank / _goal).clamp(0.0, 1.0),
                    strokeWidth: 10,
                    backgroundColor: Colors.white10,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF4FC3F7),
                    ),
                  ),
                ),
                Text(
                  "${((_totalDrank / _goal) * 100).toInt()}%",
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFAAF0D1),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                _getFunnyStatus(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

            Text(
              "$_totalDrank / $_goal ml",
              style: const TextStyle(fontSize: 20, color: Colors.white54),
            ),

            const SizedBox(height: 30),

            BottleVisual(fillLevel: _totalDrank / _goal),

            const SizedBox(height: 30),

            WaterButtons(onAddWater: _addWater),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                setState(() => _totalDrank = 0);
                await _todayDoc.update({
                  'waterDrank': 0,
                  'updatedAt': FieldValue.serverTimestamp(),
                });
              },
              child: const Text("Reset Day"),
            ),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  const Text(
                    "My bottle had a leak, or I'm just bad at tracking. Don't judge.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFAAF0D1),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Lost track? Or did someone drink from your bottle without asking?",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  Slider(
                    value: _totalDrank.toDouble().clamp(0, _goal.toDouble()),
                    min: 0,
                    max: _goal.toDouble(),
                    activeColor: const Color(0xFFAAF0D1),
                    inactiveColor: Colors.white10,
                    onChanged: (newValue) async {
                      final value = newValue.toInt();
                      setState(() => _totalDrank = value);
                      await _todayDoc.update({
                        'waterDrank': value,
                        'updatedAt': FieldValue.serverTimestamp(),
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
