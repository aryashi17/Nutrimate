import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WeeklyMenuScreen extends StatefulWidget {
  const WeeklyMenuScreen({super.key});

  @override
  State<WeeklyMenuScreen> createState() => _WeeklyMenuScreenState();
}

class _WeeklyMenuScreenState extends State<WeeklyMenuScreen> with SingleTickerProviderStateMixin {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final List<String> days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
  
  // CACHE: Stores data locally to prevent re-fetching and "loading flicker"
  final Map<String, Map<String, List<Map<String, dynamic>>>> _cache = {};
  
  int selectedDayIndex = DateTime.now().weekday - 1;
  late TabController _tabController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadMenuForDay(days[selectedDayIndex]);
  }

  Future<void> _loadMenuForDay(String day) async {
    if (_cache.containsKey(day)) {
      setState(() => selectedDayIndex = days.indexOf(day));
      return;
    }

    setState(() => isLoading = true);
    try {
      final snap = await _db.collection('mess_menu').doc('week_2025_01').collection(day).doc(day).get();
      if (snap.exists) {
        final data = snap.data()!;
        _cache[day] = {
          'Breakfast': List<Map<String, dynamic>>.from(data['breakfast'] ?? []),
          'Lunch': List<Map<String, dynamic>>.from(data['lunch'] ?? []),
          'Dinner': List<Map<String, dynamic>>.from(data['dinner'] ?? []),
        };
      }
    } finally {
      setState(() {
        selectedDayIndex = days.indexOf(day);
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A), // Deep obsidian black
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(child: _buildDaySelector()),
          isLoading 
            ? const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: Color(0xFFB2FF59))))
            : _buildMealContent(),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      backgroundColor: const Color(0xFF0A0A0A),
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 60),
        title: const Text("MESS MENU", 
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 3, color: Colors.white)),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: TabBar(
          controller: _tabController,
          indicator: const UnderlineTabIndicator(
            borderSide: BorderSide(width: 3, color: Color(0xFFB2FF59)),
            insets: EdgeInsets.symmetric(horizontal: 40),
          ),
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
          tabs: const [Tab(text: "BREAKFAST"), Tab(text: "LUNCH"), Tab(text: "DINNER")],
        ),
      ),
    );
  }

  Widget _buildDaySelector() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: days.length,
        itemBuilder: (context, index) => _DayButton(
          label: days[index],
          isSelected: selectedDayIndex == index,
          onTap: () => _loadMenuForDay(days[index]),
        ),
      ),
    );
  }

  Widget _buildMealContent() {
    return SliverFillRemaining(
      child: TabBarView(
        controller: _tabController,
        children: ['Breakfast', 'Lunch', 'Dinner'].map((meal) {
          final items = _cache[days[selectedDayIndex]]?[meal] ?? [];
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _MenuTile(name: items[index]['name'], index: index),
          );
        }).toList(),
      ),
    );
  }
}

// --- SUB-WIDGETS FOR PERFORMANCE ---

class _DayButton extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DayButton({required this.label, required this.isSelected, required this.onTap});

  @override
  State<_DayButton> createState() => _DayButtonState();
}

class _DayButtonState extends State<_DayButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          widget.onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(right: 10),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: widget.isSelected 
                ? const Color(0xFFB2FF59) 
                : (_isHovered ? Colors.white12 : Colors.transparent),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isSelected ? const Color(0xFFB2FF59) : Colors.white10,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            widget.label.substring(0, 3).toUpperCase(),
            style: TextStyle(
              color: widget.isSelected ? Colors.black : Colors.white70,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final String name;
  final int index;
  const _MenuTile({required this.name, required this.index});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary( // Optimizes scroll performance
      child: TweenAnimationBuilder<double>(
        duration: Duration(milliseconds: 300 + (index * 50)),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) => Opacity(
          opacity: value,
          child: Transform.translate(offset: Offset(10 * (1 - value), 0), child: child),
        ),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF151515),
            borderRadius: BorderRadius.circular(15),
            border: const Border(left: BorderSide(color: Color(0xFFB2FF59), width: 3)),
          ),
          child: Text(name, style: const TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 0.5)),
        ),
      ),
    );
  }
}