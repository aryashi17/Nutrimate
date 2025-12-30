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
    padding: const EdgeInsets.fromLTRB(5, 15, 15, 5),
    decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(20)),
    child: BarChart(
      BarChartData(
        maxY: 150, // Set this to your proteinGoal + a buffer
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 30,
          getDrawingHorizontalLine: (value) => FlLine(color: Colors.white10, strokeWidth: 1)),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 35,
              interval: 30, // ONLY SHOWS LABELS EVERY 30g TO PREVENT OVERLAP
              getTitlesWidget: (value, meta) => Text("${value.toInt()}g", 
                style: const TextStyle(color: Colors.white38, fontSize: 10)),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                // Only show labels for first, middle, and last day to prevent overlap
                if (value == 0 || value == (logs.length / 2).floor() || value == logs.length - 1) {
                  return Text("Day ${value.toInt() + 1}", 
                    style: const TextStyle(color: Colors.white38, fontSize: 9));
                }
                return const Text("");
              },
            ),
          ),
        ),
        barGroups: List.generate(logs.length, (index) {
          final double proteinValue = (logs[index]['totalProtein'] as num?)?.toDouble() ?? 0.0;
          return BarChartGroupData(
            x: index,
            barRods: [BarChartRodData(toY: proteinValue, color: mint, width: logs.length > 7 ? 4 : 12)],
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
    padding: const EdgeInsets.fromLTRB(5, 15, 20, 5),
    decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(20)),
    child: LineChart(
      LineChartData(
        minY: 0,
        maxY: 4000, // Adjust based on max expected water intake
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 1000,
          getDrawingHorizontalLine: (value) => FlLine(color: Colors.white10, strokeWidth: 1)),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: 1000, // SHOW LABELS EVERY 1000ml (1L)
              getTitlesWidget: (value, meta) {
                // Convert 1000ml to 1L for cleaner UI
                return Text("${(value / 1000).toStringAsFixed(1)}L", 
                  style: const TextStyle(color: Colors.white38, fontSize: 10));
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value == 0 || value == (logs.length / 2).floor() || value == logs.length - 1) {
                  return Text("Day ${value.toInt() + 1}", 
                    style: const TextStyle(color: Colors.white38, fontSize: 9));
                }
                return const Text("");
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(logs.length, (index) {
              final double waterValue = (logs[index]['water'] as num?)?.toDouble() ?? 0.0;
              return FlSpot(index.toDouble(), waterValue);
            }),
            isCurved: true,
            color: waterBlue,
            barWidth: 3,
            dotData: const FlDotData(show: false), // Hide dots for cleaner look in monthly view
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
    height: 250, // Increased height for better axis visibility
    padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
    decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(20)),
    child: BarChart(
      BarChartData(
        maxY: engine.proteinGoal + 20, // Sets the top of the chart slightly above goal
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(color: Colors.white10, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          // --- Y-AXIS SCALE ---
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 35,
              getTitlesWidget: (value, meta) => Text("${value.toInt()}g", 
                style: const TextStyle(color: Colors.white38, fontSize: 10)),
            ),
          ),
          // --- X-AXIS LABELS ---
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const titles = ['BREAKFAST', 'LUNCH', 'SNACK', 'DINNER'];
                if (value.toInt() >= 0 && value.toInt() < titles.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(titles[value.toInt()], 
                      style: const TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold)),
                  );
                }
                return const Text('');
              },
            ),
          ),
        ),
        // --- ADDING A TARGET GOAL LINE ---
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: engine.proteinGoal,
              color: mint.withOpacity(0.5),
              strokeWidth: 2,
              dashArray: [5, 5],
              label: HorizontalLineLabel(
                show: true,
                alignment: Alignment.topRight,
                style: TextStyle(color: mint, fontSize: 10, fontWeight: FontWeight.bold),
                labelResolver: (line) => 'GOAL ${engine.proteinGoal}g',
              ),
            ),
          ],
        ),
        barGroups: [
          BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 35, color: mint, width: 18)]),
          BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 45, color: mint, width: 18)]),
          BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 15, color: mint, width: 18)]),
          BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 25, color: mint, width: 18)]),
        ],
      ),
    ),
  );
}

// --- IMPROVED HYDRATION LINE CHART ---
Widget _buildLineChart(CalculatorEngine engine) {
  return Container(
    height: 250,
    padding: const EdgeInsets.fromLTRB(10, 20, 20, 10),
    decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(20)),
    child: LineChart(
      LineChartData(
        minY: 0,
        maxY: engine.goal.toDouble() + 500, // Dynamic max height based on user profile
        gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => FlLine(color: Colors.white10)),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 45,
              getTitlesWidget: (value, meta) => Text("${value.toInt()}ml", 
                style: const TextStyle(color: Colors.white38, fontSize: 10)),
            ),
          ),
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
        // --- DYNAMIC WATER GOAL LINE ---
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: engine.goal.toDouble(),
              color: waterBlue.withOpacity(0.5),
              strokeWidth: 2,
              dashArray: [10, 5],
              label: HorizontalLineLabel(
                show: true,
                labelResolver: (line) => 'TARGET',
                style: TextStyle(color: waterBlue, fontWeight: FontWeight.bold, fontSize: 10),
              ),
            ),
          ],
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [
              FlSpot(0, 500), 
              FlSpot(1, 1200), 
              FlSpot(2, 1800), 
              FlSpot(3, engine.totalDrank.toDouble())
            ],
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