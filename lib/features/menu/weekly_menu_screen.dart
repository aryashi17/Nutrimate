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
  final Map<String, Map<String, List<Map<String, dynamic>>>> _cache = {};
  
  int selectedDayIndex = DateTime.now().weekday - 1;
  late TabController _tabController;
  late ScrollController _dayScrollController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _dayScrollController = ScrollController();
    _loadMenuForDay(days[selectedDayIndex]);
    
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelectedDay());
  }

  void _scrollToSelectedDay() {
    if (_dayScrollController.hasClients) {
      double offset = (selectedDayIndex * 90.0); 
      _dayScrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutQuart,
      );
    }
  }

  Future<void> _loadMenuForDay(String day) async {
    _scrollToSelectedDay();

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
      if (mounted) {
        setState(() {
          selectedDayIndex = days.indexOf(day);
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),
          // Added a small gap to prevent DaySelector from touching the AppBar
          const SliverToBoxAdapter(child: SizedBox(height: 10)),
          SliverToBoxAdapter(child: _buildDaySelector()),
          isLoading ? _buildShimmerEffect() : _buildMealContent(),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 90, // Balanced height
      floating: false,   // Keeps it stable
      pinned: true,
      backgroundColor: const Color(0xFF0A0A0A),
      elevation: 0,
      centerTitle: true,
      flexibleSpace: const FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: EdgeInsets.only(bottom: 62), // Pushes "MESS MENU" higher
        title: Text(
          "MESS MENU", 
          style: TextStyle(
            fontSize: 14, 
            fontWeight: FontWeight.w900, 
            letterSpacing: 4, 
            color: Colors.white
          )
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: TabBar(
          controller: _tabController,
          indicatorSize: TabBarIndicatorSize.label,
          indicator: const UnderlineTabIndicator(
            borderSide: BorderSide(width: 2, color: Color(0xFFB2FF59)),
            insets: EdgeInsets.symmetric(horizontal: 10),
          ),
          labelColor: const Color(0xFFB2FF59),
          unselectedLabelColor: Colors.white30,
          labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1),
          tabs: const [Tab(text: "BREAKFAST"), Tab(text: "LUNCH"), Tab(text: "DINNER")],
        ),
      ),
    );
  }

  Widget _buildDaySelector() {
    return SizedBox(
      height: 60, // Slightly slimmed down
      child: ListView.builder(
        controller: _dayScrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
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
      hasScrollBody: true, // Crucial: Prevents overflow and allows internal scrolling
      child: TabBarView(
        controller: _tabController,
        physics: const BouncingScrollPhysics(),
        children: ['Breakfast', 'Lunch', 'Dinner'].map((meal) {
          final items = _cache[days[selectedDayIndex]]?[meal] ?? [];
          if (items.isEmpty) return const Center(child: Text("Menu not updated", style: TextStyle(color: Colors.white24)));
          
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 15, 20, 40),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _MenuTile(name: items[index]['name'], index: index),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: Container(
            height: 65,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
        childCount: 6,
      ),
    );
  }
}

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
          HapticFeedback.lightImpact();
          widget.onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: widget.isSelected 
                ? const Color(0xFFB2FF59) 
                : (_isHovered ? Colors.white12 : const Color(0xFF1A1A1A)),
            borderRadius: BorderRadius.circular(12),
            boxShadow: widget.isSelected ? [
              BoxShadow(color: const Color(0xFFB2FF59).withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 2))
            ] : [],
          ),
          alignment: Alignment.center,
          child: Text(
            widget.label.toUpperCase(),
            style: TextStyle(
              color: widget.isSelected ? Colors.black : Colors.white60,
              fontWeight: FontWeight.w900,
              fontSize: 10,
              letterSpacing: 0.5
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
    return RepaintBoundary(
      child: TweenAnimationBuilder<double>(
        duration: Duration(milliseconds: 400 + (index * 60)),
        curve: Curves.easeOutQuint,
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) => Opacity(
          opacity: value,
          child: Transform.translate(offset: Offset(15 * (1 - value), 0), child: child),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: const Color(0xFF121212),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white.withOpacity(0.04)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(name, 
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500, letterSpacing: 0.2)),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.white.withOpacity(0.05), size: 12),
            ],
          ),
        ),
      ),
    );
  }
}