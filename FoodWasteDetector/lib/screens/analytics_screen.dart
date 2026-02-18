import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../services/database_helper.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<Map<String, dynamic>> _load() async {
    final summary = await DatabaseHelper.instance.getSummaryStats();
    final weekly = await DatabaseHelper.instance.getWeeklyWasteData();
    return {'summary': summary, 'weekly': weekly};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics Dashboard')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final summary = snapshot.data!['summary'] as Map<String, int>;
          final weekly = snapshot.data!['weekly'] as List<Map<String, dynamic>>;

          final spots = <FlSpot>[];
          for (int i = 0; i < weekly.length; i++) {
            final rotten = (weekly[i]['rotten'] as num?)?.toDouble() ?? 0;
            spots.add(FlSpot(i.toDouble(), rotten));
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: ListTile(
                    title: const Text('Total scanned foods'),
                    trailing: Text('${summary['total'] ?? 0}'),
                  ),
                ),
                Card(
                  child: ListTile(
                    title: const Text('Total rotten foods'),
                    trailing: Text('${summary['rotten'] ?? 0}'),
                  ),
                ),
                const SizedBox(height: 8),
                const Text('Weekly waste chart (rotten scans)'),
                const SizedBox(height: 8),
                Expanded(
                  child: LineChart(
                    LineChartData(
                      minX: 0,
                      maxX: (spots.length - 1).toDouble().clamp(0, 6),
                      minY: 0,
                      lineBarsData: [
                        LineChartBarData(spots: spots, isCurved: true, barWidth: 3),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
