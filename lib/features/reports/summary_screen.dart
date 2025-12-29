import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/services/calculator_engine.dart';
import '../../core/services/history_service.dart'; // Ensure this exists

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Theme Colors
  final Color bgDark = const Color(0xFF080C0B);
  final Color surface = const Color(0xFF121A16);
  final Color mint = const Color(0xFF7EE081);
  final Color waterBlue = const Color(0xFF4FC3F7);

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final engine = Provider.of<CalculatorEngine>(context);

    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("HEALTH SUMMARY", 
          style: TextStyle(letterSpacing: 3, fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: mint,
          dividerColor: Colors.transparent,
          labelColor: mint,
          unselectedLabelColor: Colors.white38,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          tabs: const [
            Tab(text: "DAILY"),
            Tab(text: "WEEKLY"),
            Tab(text: "MONTHLY"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDailyView(engine),
          _buildHistoryView(7),  // Weekly (7 days)
          _buildHistoryView(30), // Monthly (30 days)
        ],
      ),
    );
  }

  // --- 1. DAILY VIEW ---
  Widget _buildDailyView(CalculatorEngine engine) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("TODAY'S DIET", Icons.restaurant_menu),
          const SizedBox(height: 15),
          _buildBarChart(engine),
          const SizedBox(height: 30),
          _buildSectionHeader("TODAY'S HYDRATION", Icons.water_drop),
          const SizedBox(height: 15),
          _buildLineChart(engine),
          const SizedBox(height: 30),
          _buildQuickStats(engine),
        ],
      ),
    );
  }

  // --- 2. WEEKLY/MONTHLY VIEW (Generic History) ---
  Widget _buildHistoryView(int days) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: HistoryService().getHistory(days),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text("No logs found for this period", 
              style: TextStyle(color: Colors.white24))
          );
        }

        var logs = snapshot.data!;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildSectionHeader("$days-DAY PROTEIN TREND", Icons.analytics),
              const SizedBox(height: 15),
              _buildHistoryBarChart(logs),
              const SizedBox(height: 30),
              _buildSectionHeader("$days-DAY HYDRATION TREND", Icons.opacity),
              const SizedBox(height: 15),
              _buildHistoryLineChart(logs),
            ],
          ),
        );
      },
    );
  }

  // --- CHART HELPERS ---

  // --- FIXED HISTORY BAR CHART ---
Widget _buildHistoryBarChart(List<Map<String, dynamic>> logs) {
  return Container(
    height: 220,
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(20)),
    child: BarChart(
      BarChartData(
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        barGroups: List.generate(logs.length, (index) {
          // SAFE DATA FETCHING: Check if key exists and is not null
          final rawProtein = logs[index]['totalProtein'];
          final double proteinValue = (rawProtein is num) ? rawProtein.toDouble() : 0.0;

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: proteinValue, 
                color: mint,
                width: 12,
                borderRadius: BorderRadius.circular(4),
              )
            ],
          );
        }),
      ),
    ),
  );
}

// --- FIXED HISTORY LINE CHART ---
Widget _buildHistoryLineChart(List<Map<String, dynamic>> logs) {
  return Container(
    height: 220,
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(20)),
    child: LineChart(
      LineChartData(
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(logs.length, (index) {
              // SAFE DATA FETCHING
              final rawWater = logs[index]['water'];
              final double waterValue = (rawWater is num) ? rawWater.toDouble() : 0.0;
              
              return FlSpot(index.toDouble(), waterValue);
            }),
            isCurved: true,
            color: waterBlue,
            barWidth: 3,
            belowBarData: BarAreaData(show: true, color: waterBlue.withOpacity(0.1)),
          ),
        ],
      ),
    ),
  );
}

  // --- REUSED UI COMPONENTS ---

  // --- IMPROVED DIET BAR CHART ---
Widget _buildBarChart(CalculatorEngine engine) {
  return Container(
    height: 220,
    padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
    decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(20)),
    child: BarChart(
      BarChartData(
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        // Adding labels to the X-axis
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const titles = ['BREAKFAST', 'LUNCH', 'SNACK', 'DINNER']; // Breakfast, Lunch, Snack, Dinner
                return Text(titles[value.toInt()], 
                  style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold));
              },
            ),
          ),
        ),
        barGroups: [
          BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 8, color: mint, width: 16)]),
          BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 12, color: mint, width: 16)]),
          BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 5, color: mint, width: 16)]),
          BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 10, color: mint, width: 16)]),
        ],
      ),
    ),
  );
}

// --- IMPROVED HYDRATION LINE CHART ---
Widget _buildLineChart(CalculatorEngine engine) {
  return Container(
    height: 220,
    padding: const EdgeInsets.fromLTRB(10, 20, 20, 10),
    decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(20)),
    child: LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const times = ['8AM', '12PM', '4PM', '8PM'];
                return Text(times[value.toInt()], 
                  style: const TextStyle(color: Colors.white38, fontSize: 10));
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: const [FlSpot(0, 1), FlSpot(1, 3), FlSpot(2, 2), FlSpot(3, 5)],
            isCurved: true,
            color: waterBlue,
            barWidth: 4,
            belowBarData: BarAreaData(show: true, color: waterBlue.withOpacity(0.1)),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: mint, size: 18),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildQuickStats(CalculatorEngine engine) {
    return Row(
      children: [
        _statTile("Avg Protein", "65g", Colors.orangeAccent),
        const SizedBox(width: 15),
        _statTile("Total Water", "2.4L", waterBlue),
      ],
    );
  }

  Widget _statTile(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
            const SizedBox(height: 5),
            Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}