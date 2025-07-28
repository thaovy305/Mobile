import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../Helper/UriHelper.dart';

class TimeComparisonChart extends StatefulWidget {
  final String projectKey;

  const TimeComparisonChart({super.key, required this.projectKey});

  @override
  State<TimeComparisonChart> createState() => _TimeComparisonChartState();
}

class _TimeComparisonChartState extends State<TimeComparisonChart> {
  late Future<TimeDashboardData> _timeDataFuture;

  @override
  void initState() {
    super.initState();
    _timeDataFuture = fetchTimeDashboard(widget.projectKey);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TimeDashboardData>(
      future: _timeDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Loading...', style: TextStyle(color: Colors.grey)),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Error loading time dashboard'),
          );
        }

        final data = snapshot.data!;
        final delta = (data.actualCompletion - data.plannedCompletion).abs();
        final chartData = [
          _ChartItem("Planned Completion", data.plannedCompletion, data.status),
          _ChartItem("Actual Completion", data.actualCompletion, data.status),
          _ChartItem(data.status, delta, data.status),
        ];

        return Card(
          margin: const EdgeInsets.all(10),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 12,
                  children: [
                    _LegendDot(color: Colors.blue, label: 'Ahead'),
                    _LegendDot(color: Colors.orange, label: 'Behind'),
                    _LegendDot(color: Colors.green, label: 'On Time'),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 100,
                      // barTouchData: BarTouchData(enabled: false),
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          tooltipBgColor: Colors.black87,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final value = rod.toY.toStringAsFixed(1);
                            return BarTooltipItem(
                              '$value%',
                              const TextStyle(color: Colors.white),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(),
                        topTitles: const AxisTitles(),
                        rightTitles: const AxisTitles(),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 60,
                            getTitlesWidget: (value, _) {
                              final index = value.toInt();
                              if (index < 0 || index >= chartData.length) return const SizedBox();
                              return Transform.rotate(
                                angle: 0, //
                                child: Text(
                                  chartData[index].name,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      barGroups: chartData.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: item.value,
                              width: 20,
                              borderRadius: BorderRadius.circular(6),
                              color: item.color,
                              backDrawRodData: BackgroundBarChartRodData(
                                show: true,
                                toY: 100,
                                color: Colors.grey[200],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Status: ${_statusText(data.status)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: _statusColor(data.status),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _statusText(String status) {
    switch (status) {
      case 'Ahead':
        return '🚀 Ahead of schedule';
      case 'Behind':
        return '🔺 Behind schedule';
      default:
        return '✅ On time';
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Ahead':
        return Colors.blue;
      case 'Behind':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }
}

// ====================== MODEL =======================

class TimeDashboardData {
  final double plannedCompletion;
  final double actualCompletion;
  final String status;

  TimeDashboardData({
    required this.plannedCompletion,
    required this.actualCompletion,
    required this.status,
  });

  factory TimeDashboardData.fromJson(Map<String, dynamic> json) {
    return TimeDashboardData(
      plannedCompletion: (json['plannedCompletion'] ?? 0).toDouble(),
      actualCompletion: (json['actualCompletion'] ?? 0).toDouble(),
      status: json['status'] ?? 'Unknown',
    );
  }
}

Future<TimeDashboardData> fetchTimeDashboard(String projectKey) async {
  final url = UriHelper.build('/projectmetric/time-dashboard?projectKey=$projectKey');
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('accessToken') ?? '';

  final response = await http.get(url, headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  });

  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);
    return TimeDashboardData.fromJson(jsonData['data']);
  } else {
    throw Exception('Failed to load time dashboard');
  }
}

// ===================== CHART ITEM =====================

class _ChartItem {
  final String name;
  final double value;
  final Color color;

  _ChartItem(String name, double value, String status)
      : name = name,
        value = value,
        color = status == 'Ahead'
            ? Colors.blue
            : status == 'Behind'
            ? Colors.orange
            : Colors.green;
}

// ===================== LEGEND =====================

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
