import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../Helper/UriHelper.dart';

// Model response
class CostDashboardData {
  final double actualCost;
  final double plannedCost;
  final double budget;

  CostDashboardData({
    required this.actualCost,
    required this.plannedCost,
    required this.budget,
  });

  factory CostDashboardData.fromJson(Map<String, dynamic> json) {
    return CostDashboardData(
      actualCost: (json['actualCost'] ?? 0).toDouble(),
      plannedCost: (json['plannedCost'] ?? 0).toDouble(),
      budget: (json['budget'] ?? 0).toDouble(),
    );
  }
}

// Widget
class CostBarChart extends StatefulWidget {
  final String projectKey;

  const CostBarChart({super.key, required this.projectKey});

  @override
  State<CostBarChart> createState() => _CostBarChartState();
}

class _CostBarChartState extends State<CostBarChart> {
  CostDashboardData? costData;
  bool isLoading = true;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    fetchCostData();
  }

  Future<void> fetchCostData() async {
    try {
      final url = UriHelper.build('/projectmetric/cost-dashboard?projectKey=${widget.projectKey}');
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['isSuccess'] == true && body['data'] != null) {
          setState(() {
            costData = CostDashboardData.fromJson(body['data']);
            isLoading = false;
          });
        } else {
          setState(() => isError = true);
        }
      } else {
        setState(() => isError = true);
      }
    } catch (e) {
      setState(() => isError = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (isError || costData == null) {
      return const Center(child: Text('Failed to load cost data'));
    }

    // return Card(
    //   margin: const EdgeInsets.all(16),
    //   elevation: 4,
    //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    //   child: Padding(
    //     padding: const EdgeInsets.all(16),
    //     child: AspectRatio(
    //       aspectRatio: 1.5,
    //       child: BarChart(
    //         BarChartData(
    //           titlesData: FlTitlesData(
    //             leftTitles: AxisTitles(
    //               sideTitles: SideTitles(
    //                 showTitles: true,
    //                 getTitlesWidget: (value, meta) {
    //                   return Text("\$${(value / 1000).round()}K", style: const TextStyle(fontSize: 10));
    //                 },
    //                 reservedSize: 40,
    //               ),
    //             ),
    //             bottomTitles: AxisTitles(
    //               sideTitles: SideTitles(
    //                 showTitles: true,
    //                 getTitlesWidget: (_, __) => const Text("Cost"),
    //               ),
    //             ),
    //             topTitles: AxisTitles(),
    //             rightTitles: AxisTitles(),
    //           ),
    //           barGroups: [
    //             BarChartGroupData(
    //               x: 0,
    //               barRods: [
    //                 BarChartRodData(toY: costData!.actualCost, color: Colors.teal, width: 16),
    //                 BarChartRodData(toY: costData!.plannedCost, color: Colors.cyan, width: 16),
    //                 BarChartRodData(toY: costData!.budget, color: Colors.blue, width: 16),
    //               ],
    //             ),
    //           ],
    //           gridData: FlGridData(show: true),
    //           borderData: FlBorderData(show: false),
    //           barTouchData: BarTouchData(enabled: true),
    //         ),
    //       ),
    //     ),
    //   ),
    // );

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 1.5,
              child: BarChart(
                BarChartData(
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text("\$${(value / 1000).round()}K",
                              style: const TextStyle(fontSize: 10));
                        },
                        reservedSize: 40,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (_, __) => const Text("Cost"),
                      ),
                    ),
                    topTitles: AxisTitles(),
                    rightTitles: AxisTitles(),
                  ),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                            toY: costData!.actualCost,
                            color: Colors.teal,
                            width: 16),
                        BarChartRodData(
                            toY: costData!.plannedCost,
                            color: Colors.cyan,
                            width: 16),
                        BarChartRodData(
                            toY: costData!.budget,
                            color: Colors.blue,
                            width: 16),
                      ],
                    ),
                  ],
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(show: false),
                  barTouchData: BarTouchData(enabled: true),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegendItem(Colors.teal, 'Actual'),
                _buildLegendItem(Colors.cyan, 'Planned'),
                _buildLegendItem(Colors.blue, 'Budget'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

}
