import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final popular = await api.getRidePopularity();
    final visitors = await api.getVisitorStats();
    setState(() {
      popularity = popular;
      visitorStats = visitors;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: GradientBackground(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            GlassPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ride popularity', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 240,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        barGroups: [
                          for (var i = 0; i < popularity.length; i++)
                            BarChartGroupData(
                              x: i,
                              barRods: [
                                BarChartRodData(
                                  toY: (popularity[i]['bookings'] ?? 0).toDouble(),
                                  width: 22,
                                  borderRadius: BorderRadius.circular(12),
                                  color: const Color(0xFFFF6B57),
                                ),
                              ],
                            )
                        ],
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() < 0 || value.toInt() >= popularity.length) {
                                  return const SizedBox.shrink();
                                }
                                final item = popularity[value.toInt()];
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(item['ride_name'].toString(), style: const TextStyle(fontSize: 10)),
                                );
                              },
                            ),
                          ),
                        ),
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
                  const SizedBox(height: 12),
                  Text('Average age: ${((visitorStats?['averageAge'] ?? 0) as num).toStringAsFixed(1)}'),
                  Text('Visitor count: ${visitorStats?['visitorCount'] ?? 0}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
