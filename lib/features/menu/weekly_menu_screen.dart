import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WeeklyMenuScreen extends StatefulWidget {
  const WeeklyMenuScreen({super.key});

  @override
  State<WeeklyMenuScreen> createState() => _WeeklyMenuScreenState();
}

class _WeeklyMenuScreenState extends State<WeeklyMenuScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final List<String> days = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday'
  ];

  int selectedDayIndex = DateTime.now().weekday - 1;
  late TabController _tabController;

  Map<String, List<Map<String, dynamic>>> dayMenu = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadMenuForDay(days[selectedDayIndex]);
  }

  Future<void> _loadMenuForDay(String day) async {
    setState(() => isLoading = true);

    try {
      final snap = await _db
          .collection('mess_menu')
          .doc('week_2025_01')
          .collection(day)
          .doc(day)
          .get();

      final data = snap.data()!;

      setState(() {
        dayMenu = {
          'Breakfast': List<Map<String, dynamic>>.from(data['breakfast']),
          'Lunch': List<Map<String, dynamic>>.from(data['lunch']),
          'Dinner': List<Map<String, dynamic>>.from(data['dinner']),
        };
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading weekly menu: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        title: const Text("Weekly Mess Menu"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFB2FF59),
          tabs: const [
            Tab(text: "Breakfast"),
            Tab(text: "Lunch"),
            Tab(text: "Dinner"),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildDaySelector(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildMealList('Breakfast'),
                      _buildMealList('Lunch'),
                      _buildMealList('Dinner'),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelector() {
    return SizedBox(
      height: 56,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        itemBuilder: (context, index) {
          final selected = index == selectedDayIndex;
          return GestureDetector(
            onTap: () {
              setState(() => selectedDayIndex = index);
              _loadMenuForDay(days[index]);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFFB2FF59).withOpacity(0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected
                      ? const Color(0xFFB2FF59)
                      : Colors.white24,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                days[index].toUpperCase(),
                style: TextStyle(
                  color: selected
                      ? const Color(0xFFB2FF59)
                      : Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMealList(String meal) {
    final items = dayMenu[meal] ?? [];

    if (items.isEmpty) {
      return const Center(
        child: Text(
          "No items",
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white10),
          ),
          child: Text(
            item['name'],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
          ),
        );
      },
    );
  }
}
