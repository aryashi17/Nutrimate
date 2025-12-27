import 'package:flutter/material.dart';
import '../plate_mapper/plate_mapper_screen.dart';

class MessLoggerScreen extends StatefulWidget {
  const MessLoggerScreen({super.key});

  @override
  State<MessLoggerScreen> createState() => _MessLoggerScreenState();
}

class _MessLoggerScreenState extends State<MessLoggerScreen> {
  final List<Map<String, dynamic>> todayMenu = [
    {'name': 'Basmati Rice', 'icon': Icons.rice_bowl_rounded},
    {'name': 'Dal Tadka', 'icon': Icons.soup_kitchen_rounded},
    {'name': 'Paneer Masala', 'icon': Icons.restaurant_rounded},
    {'name': 'Fresh Curd', 'icon': Icons.egg_alt_rounded},
    {'name': 'Butter Roti', 'icon': Icons.flatware_rounded},
    {'name': 'Salad', 'icon': Icons.eco_rounded},
  ];

  String getMealTime() {
    final hour = DateTime.now().hour;
    if (hour < 11) return "Breakfast";
    if (hour < 16) return "Lunch";
    if (hour < 20) return "Snacks";
    return "Dinner";
  }

  IconData getMealIcon() {
    final meal = getMealTime();
    if (meal == "Breakfast") return Icons.wb_twilight_rounded;
    if (meal == "Lunch") return Icons.wb_sunny_rounded;
    return Icons.dark_mode_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildHeader(),
              const SizedBox(height: 30),
              const Text(
                "TODAY'S PLATE",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2),
              ),
              const SizedBox(height: 15),
              Expanded(child: _buildBentoGrid()),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildEditButton(),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1E1E), Color(0xFF2D2D2D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Icon(getMealIcon(), size: 50, color: const Color(0xFFAAF0D1)),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                getMealTime(),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold),
              ),
              const Text(
                "Tuesday, Oct 24",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBentoGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 1.1,
      ),
      itemCount: todayMenu.length,
      itemBuilder: (context, index) {
        return _BentoCard(
          label: todayMenu[index]['name'],
          icon: todayMenu[index]['icon'],
        );
      },
    );
  }

  Widget _buildEditButton() {
    return FloatingActionButton.extended(
      backgroundColor: const Color(0xFFAAF0D1),
      onPressed: () => _showEditSheet(),
      icon: const Icon(Icons.edit_note_rounded, color: Colors.black),
      label: const Text("Edit Menu",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
    );
  }

  void _showEditSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Community Edit",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "What's being served instead?",
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFAAF0D1),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Update for Everyone",
                  style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}

class _BentoCard extends StatefulWidget {
  final String label;
  final IconData icon;
  const _BentoCard({required this.label, required this.icon});

  @override
  State<_BentoCard> createState() => _BentoCardState();
}

class _BentoCardState extends State<_BentoCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        debugPrint("Tapped ${widget.label}");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PlateMapperScreen(),
          ),
        );
      },
      onTapDown: (_) => setState(() => _scale = 0.95),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon,
                  size: 40,
                  color: const Color(0xFFAAF0D1).withValues(alpha: 0.8)),
              const SizedBox(height: 10),
              Text(
                widget.label.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 10,
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}