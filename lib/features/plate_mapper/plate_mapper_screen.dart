import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PlateMapperScreen extends StatefulWidget {
  final String? foodName;
  final double initialFill;
  final Map<String, String> existingOccupancy;
  final Map<String, double> existingFills;

  const PlateMapperScreen({
    super.key,
    this.foodName,
    this.initialFill = 0.0,
    required this.existingOccupancy,
    required this.existingFills,
  });

  @override
  State<PlateMapperScreen> createState() => _PlateMapperScreenState();
}

class _PlateMapperScreenState extends State<PlateMapperScreen> with TickerProviderStateMixin {
  double fillLevel = 0.0;
  String selectedSection = "Main";
  String activeTemplate = "Thali"; 
  
  // Plate Memory System
  final Map<String, String> plateOccupancy = {}; // section -> foodName
  final Map<String, double> sectionFillLevels = {}; // section -> fill percentage

  final Color accentMint = const Color(0xFF7EE081);
  final Color bgDark = const Color(0xFF080C0B);
  final Color surface = const Color(0xFF121A16);
  final Color coral = const Color(0xFFFF6B6B);

  @override
  void initState() {
    super.initState();
    fillLevel = widget.initialFill;
    // Initialize with existing occupancy
    plateOccupancy.addAll(widget.existingOccupancy);
    sectionFillLevels.addAll(widget.existingFills);
  }
  // Handle section tap with selection/deselection logic
  Future<void> _handleSectionTap(String name, bool isOccupied) async {
    if (widget.foodName == null) {
      setState(() => selectedSection = name);
      return;
    }

    // Food is selected - handle selection/deselection
    if (selectedSection == name) {
      // Clicking the same section - deselect it
      setState(() => selectedSection = '');
      return;
    }

    // Check if section is occupied by different food
    if (isOccupied && plateOccupancy[name] != widget.foodName) {
      final action = await _showConflictDialog(name, plateOccupancy[name]!);
      if (action == 'cancel') return;

      if (action == 'replace') {
        _placeFoodInSection(name, fillLevel);
      } else if (action == 'keep_both') {
        final nextSlot = _findNextAvailableSlot();
        if (nextSlot != null) {
          _placeFoodInSection(nextSlot, fillLevel);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('No available slots!'), backgroundColor: coral),
            );
          }
        }
      }
    } else {
      // Section is empty or occupied by same food - select it
      setState(() => selectedSection = name);
    }
  }

  // Place food in a section
  void _placeFoodInSection(String sectionName, double fill) {
    setState(() {
      plateOccupancy[sectionName] = widget.foodName!;
      sectionFillLevels[sectionName] = fill;
      selectedSection = ''; // Clear selection after placing
    });
  }

  // Show conflict
  Future<String?> _showConflictDialog(String sectionName, String existingFood) async {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: surface,
          title: Text('Section Occupied', style: TextStyle(color: accentMint)),
          content: Text(
            'Section "$sectionName" already contains $existingFood.\n\nWhat would you like to do with ${widget.foodName}?',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, 'cancel'),
              child: Text('Cancel', style: TextStyle(color: coral)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'replace'),
              child: Text('Replace', style: TextStyle(color: accentMint)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'keep_both'),
              child: Text('Find New Spot', style: TextStyle(color: accentMint)),
            ),
          ],
        );
      },
    );
  }

  // Find next available empty slot
  String? _findNextAvailableSlot() {
    final allSections = _getAllSectionsForTemplate(activeTemplate);
    for (final section in allSections) {
      if (!plateOccupancy.containsKey(section) || plateOccupancy[section] == 'Empty') {
        return section;
      }
    }
    return null;
  }

  // Get all sections for current template
  List<String> _getAllSectionsForTemplate(String template) {
    switch (template) {
      case 'Thali':
        return ['Bowl 1', 'Bowl 2', 'Bowl 3', 'Rice/Roti'];
      case 'Balanced':
        return ['Veggies (50%)', 'Protein', 'Carbs'];
      case 'Bowl':
        return ['Main Bowl'];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("PLATE ARCHITECT", style: TextStyle(letterSpacing: 2, fontSize: 14, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              SizedBox(height: 60, child: _buildTemplateSelector()),
              if (widget.foodName != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text("MAPPING: ${widget.foodName!.toUpperCase()}", 
                    style: TextStyle(color: accentMint, fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 12)),
                ),
            
              Expanded(
                child: Center(
                  child: _buildVisualPlate(),
                ),
              ),
              
              _buildControlPanel(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTemplateSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: ["Thali", "Balanced", "Bowl"].map((t) {
        bool isSel = activeTemplate == t;
        return GestureDetector(
          onTap: () => setState(() => activeTemplate = t),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSel ? accentMint : surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(t, style: TextStyle(color: isSel ? Colors.black : Colors.white60, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildVisualPlate() {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: surface,
              boxShadow: [
                BoxShadow(color: accentMint.withOpacity(0.05), blurRadius: 40, spreadRadius: 10),
                BoxShadow(color: Colors.black, blurRadius: 20, offset: const Offset(0, 10)),
              ],
              border: Border.all(color: Colors.white10, width: 2),
            ),
          ),
          if (activeTemplate == "Thali") _buildThaliLayout(),
          if (activeTemplate == "Balanced") _buildBalancedLayout(),
          if (activeTemplate == "Bowl") _buildBowlLayout(),
        ],
      ),
    );
  }

  Widget _buildThaliLayout() {
    return SizedBox(
      width: 260,
      height: 260,
      child: Stack(
        children: [
          _circularBowl(top: 0, left: 70, name: "Bowl 1"),
          _circularBowl(top: 40, left: 0, name: "Bowl 2"),
          _circularBowl(top: 40, right: 0, name: "Bowl 3"),
          _mainArea(bottom: 10, left: 30, name: "Rice/Roti"),
        ],
      ),
    );
  }

  Widget _buildBalancedLayout() {
    return 
    ClipOval(
      child: SizedBox(
        width: 260,
        height: 260,
        child: Column(
          children: [
            Expanded(child: _wedgeArea("Veggies (50%)", Colors.green.withOpacity(0.2))),
            Expanded(
              child: Row(
                children: [
                  Expanded(child: _wedgeArea("Protein", Colors.red.withOpacity(0.2))),
                  Expanded(child: _wedgeArea("Carbs", Colors.orange.withOpacity(0.2))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBowlLayout() => _circularBowl(top: 30, left: 30, size: 200, name: "Main Bowl");

  Widget _circularBowl({double? top, double? left, double? right, double size = 80, required String name}) {
    bool isSel = selectedSection == name;
    bool isOccupied = plateOccupancy.containsKey(name) && plateOccupancy[name] != 'Empty';
    double currentFill = sectionFillLevels[name] ?? 0.0;

    return Positioned(
      top: top, left: left, right: right,
      child: GestureDetector(
        onTap: () => _handleSectionTap(name, isOccupied),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: size, height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSel ? accentMint.withOpacity(fillLevel * 0.8) : Colors.black26,
            border: Border.all(color: isSel ? accentMint : Colors.white12, width: isSel ? 3 : 1),
            boxShadow: isOccupied ? [
              BoxShadow(
                color: accentMint.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ] : null,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: isOccupied
                  ? Icon(
                      _getFoodIcon(plateOccupancy[name]!),
                      key: ValueKey(plateOccupancy[name]),
                      color: Colors.white70,
                      size: size * 0.4,
                    )
                  : Text(
                      name,
                      key: ValueKey('empty_$name'),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10, color: isSel ? Colors.black : Colors.white38),
                    ),
              ),
              if (isOccupied && currentFill > 0)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: bgDark.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${(currentFill * 100).toInt()}%',
                      style: TextStyle(color: accentMint, fontSize: 8, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mainArea({double? bottom, double? left, required String name}) {
    bool isSel = selectedSection == name;
    bool isOccupied = plateOccupancy.containsKey(name) && plateOccupancy[name] != 'Empty';
    double currentFill = sectionFillLevels[name] ?? 0.0;

    return Positioned(
      bottom: bottom, left: left,
      child: GestureDetector(
        onTap: () => _handleSectionTap(name, isOccupied),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 200, height: 120,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20), bottom: Radius.circular(100)),
            color: isSel ? accentMint.withOpacity(fillLevel * 0.8) : Colors.black26,
            border: Border.all(color: isSel ? accentMint : Colors.white12, width: isSel ? 3 : 1),
            boxShadow: isOccupied ? [
              BoxShadow(
                color: accentMint.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ] : null,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: isOccupied
                  ? Icon(
                      _getFoodIcon(plateOccupancy[name]!),
                      key: ValueKey(plateOccupancy[name]),
                      color: Colors.white70,
                      size: 40,
                    )
                  : Text(
                      name,
                      key: ValueKey('empty_$name'),
                      style: TextStyle(color: isSel ? Colors.black : Colors.white38),
                    ),
              ),
              if (isOccupied && currentFill > 0)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: bgDark.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${(currentFill * 100).toInt()}%',
                      style: TextStyle(color: accentMint, fontSize: 8, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _wedgeArea(String name, Color col) {
    bool isSel = selectedSection == name;
    bool isOccupied = plateOccupancy.containsKey(name) && plateOccupancy[name] != 'Empty';
    double currentFill = sectionFillLevels[name] ?? 0.0;

    return GestureDetector(
      onTap: () => _handleSectionTap(name, isOccupied),
      child: Container(
        decoration: BoxDecoration(
          color: isSel ? accentMint.withOpacity(fillLevel) : col,
          border: Border.all(color: isSel ? accentMint : Colors.transparent, width: 2),
          boxShadow: isOccupied ? [
            BoxShadow(
              color: accentMint.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ] : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: isOccupied
                ? Icon(
                    _getFoodIcon(plateOccupancy[name]!),
                    key: ValueKey(plateOccupancy[name]),
                    color: Colors.white70,
                    size: 24,
                  )
                : Text(
                    name,
                    key: ValueKey('empty_$name'),
                    style: const TextStyle(fontSize: 12),
                  ),
            ),
            if (isOccupied && currentFill > 0)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  padding: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: bgDark.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${(currentFill * 100).toInt()}%',
                    style: TextStyle(color: accentMint, fontSize: 6, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getFoodIcon(String foodName) {
    final foodIcons = {
      'Rice': Icons.rice_bowl_rounded,
      'Dal': Icons.soup_kitchen_rounded,
      'Paneer': Icons.restaurant_rounded,
      'Roti': Icons.flatware_rounded,
      'Curd': Icons.egg_alt_rounded,
      'Salad': Icons.eco_rounded,
      'Oats': Icons.breakfast_dining,
      'Eggs': Icons.egg,
      'Milk': Icons.coffee_rounded,
      'Tea': Icons.emoji_food_beverage,
      'Samosa': Icons.fastfood,
      'Soup': Icons.waves,
      'Sabzi': Icons.dinner_dining,
    };
    return foodIcons[foodName] ?? Icons.restaurant;
  }

  Widget _buildControlPanel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.foodName != null) ...[
            Text("Set portion for ${widget.foodName}", 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Portion Size", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              Text("${(fillLevel * 100).toInt()}%", style: TextStyle(color: accentMint, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          Slider(
            value: fillLevel,
            activeColor: accentMint,
            onChanged: (v) {
              HapticFeedback.selectionClick();
              setState(() => fillLevel = v);
            },
          ),
          const SizedBox(height: 8),
          if (selectedSection.isNotEmpty && widget.foodName != null)
            Text("Selected: $selectedSection", 
              style: TextStyle(color: accentMint, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),
          if (selectedSection.isNotEmpty && widget.foodName != null) ...[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: accentMint, 
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () {
                _placeFoodInSection(selectedSection, fillLevel);
              },
              child: Text("PLACE ${widget.foodName!.toUpperCase()}", 
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
            const SizedBox(height: 8),
          ],
          const Text("Tap sections to select, tap again to deselect", style: TextStyle(color: Colors.white60, fontSize: 10)),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: surface, 
              foregroundColor: accentMint,
              minimumSize: const Size(double.infinity, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: accentMint, width: 2),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: () {
              // Return list of all plate changes
              final changes = <Map<String, dynamic>>[];
              plateOccupancy.forEach((section, food) {
                if (food != 'Empty') {
                  changes.add({
                    'section': section,
                    'food': food,
                    'fill': sectionFillLevels[section] ?? 0.0,
                  });
                }
              });
              Navigator.pop(context, changes);
            },
            child: const Text("CONFIRM PLATE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
