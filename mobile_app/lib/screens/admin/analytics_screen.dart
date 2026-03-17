import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../widgets/glass_panel.dart';
import '../../widgets/gradient_background.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final api = ApiService();
  List<dynamic> popularity = [];
  Map<String, dynamic>? visitorStats;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final results = await Future.wait([
      api.getRidePopularity(),
      api.getVisitorStats(),
    ]);
    final popular = results[0] as List<dynamic>;
    final visitors = results[1] as Map<String, dynamic>;
    if (!mounted) {
      return;
    }
    setState(() {
      popularity = popular;
      visitorStats = visitors;
      loading = false;
    });
  }

  double get _maxBookings {
    if (popularity.isEmpty) {
      return 5;
    }
    final maxValue = popularity
        .map((item) => (item['bookings'] as num? ?? 0).toDouble())
        .fold<double>(0, (prev, element) => element > prev ? element : prev);
    return maxValue < 5 ? 5 : maxValue + 1;
  }

  String _shortRideName(String fullName) {
    const overrides = {
      'Roller Coaster': 'Coaster',
      'Ferris Wheel': 'Wheel',
      'Bumper Cars': 'Bumpers',
      'Drop Tower': 'Tower',
      'Water Splash Ride': 'Splash',
      'Carousel (Merry-Go-Round)': 'Carousel',
    };
    return overrides[fullName] ?? fullName;
  }

  @override
  Widget build(BuildContext context) {
    final averageAge = ((visitorStats?['averageAge'] ?? 0) as num).toDouble();
    final visitorCount = visitorStats?['visitorCount'] ?? 0;
    final busiestRide = popularity.isEmpty ? 'No data' : popularity.first['ride_name'].toString();

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: GradientBackground(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: const LinearGradient(
                  colors: [Color(0xFF1F2A44), Color(0xFF2F7D8C), Color(0xFFFFA95C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.navy.withOpacity(0.18),
                    blurRadius: 26,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Analytics Hub',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'A cleaner view of ride demand, guest flow, and park performance.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _HeroChip(
                          title: 'Top ride',
                          value: _shortRideName(busiestRide),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _HeroChip(
                          title: 'Visitors',
                          value: '$visitorCount tracked',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.05),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: 'Average age',
                    value: averageAge.toStringAsFixed(1),
                    icon: Icons.groups_rounded,
                    color: const Color(0xFFFFF1E8),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    title: 'Ride demand',
                    value: '${popularity.length}',
                    icon: Icons.local_fire_department_rounded,
                    color: const Color(0xFFE9FBF6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            GlassPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Ride popularity', style: Theme.of(context).textTheme.titleLarge),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3EF),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text('${popularity.length} rides'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  if (loading)
                    const SizedBox(
                      height: 260,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else
                    SizedBox(
                      height: 280,
                      child: BarChart(
                        BarChartData(
                          maxY: _maxBookings,
                          alignment: BarChartAlignment.spaceAround,
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 1,
                            getDrawingHorizontalLine: (_) => FlLine(
                              color: Colors.black.withOpacity(0.08),
                              strokeWidth: 1,
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          barTouchData: BarTouchData(
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipColor: (_) => AppTheme.navy,
                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                final item = popularity[group.x.toInt()];
                                return BarTooltipItem(
                                  '${item['ride_name']}\n${item['bookings']} bookings',
                                  const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                                );
                              },
                            ),
                          ),
                          titlesData: FlTitlesData(
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 28,
                                interval: 1,
                                getTitlesWidget: (value, meta) => Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(fontSize: 10, color: Colors.black54),
                                ),
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 42,
                                getTitlesWidget: (value, meta) {
                                  if (value.toInt() < 0 || value.toInt() >= popularity.length) {
                                    return const SizedBox.shrink();
                                  }
                                  final item = popularity[value.toInt()];
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Text(
                                      _shortRideName(item['ride_name'].toString()),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          barGroups: [
                            for (var i = 0; i < popularity.length; i++)
                              BarChartGroupData(
                                x: i,
                                barRods: [
                                  BarChartRodData(
                                    toY: (popularity[i]['bookings'] ?? 0).toDouble(),
                                    width: 18,
                                    borderRadius: BorderRadius.circular(14),
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFFF6B57), Color(0xFFFFB55A)],
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                    ),
                                  ),
                                ],
                              )
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            GlassPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Visitor statistics', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 14),
                  _StatLine(label: 'Average age', value: averageAge.toStringAsFixed(1)),
                  _StatLine(label: 'Visitor count', value: '$visitorCount'),
                  _StatLine(label: 'Most watched ride', value: _shortRideName(busiestRide)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.navy),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _StatLine extends StatelessWidget {
  const _StatLine({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
