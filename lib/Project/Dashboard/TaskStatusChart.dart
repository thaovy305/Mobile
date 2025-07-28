import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../Helper/UriHelper.dart';

class TaskStatusChart extends StatefulWidget {
  final String projectKey;

  const TaskStatusChart({super.key, required this.projectKey});

  @override
  State<TaskStatusChart> createState() => _TaskStatusChartState();
}

class _TaskStatusChartState extends State<TaskStatusChart> {
  List<_ChartData> chartData = [];
  bool isLoading = true;
  bool isError = false;

  final List<Color> defaultColors = const [
    Colors.grey,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.red,
  ];

  @override
  void initState() {
    super.initState();
    fetchChartData();
  }

  Future<void> fetchChartData() async {
    try {
      final uri = UriHelper.build('/projectmetric/tasks-dashboard?projectKey=${widget.projectKey}');
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';

      final response = await http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final List<dynamic> items = decoded['data']['statusCounts'];
        setState(() {
          chartData = items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final String name = item['name']
                .toString()
                .replaceAll('_', ' ')
                .toLowerCase()
                .replaceFirstMapped(RegExp(r'^\w'), (m) => m.group(0)!.toUpperCase());
            return _ChartData(
              name: name,
              count: item['count'],
              color: defaultColors[index % defaultColors.length],
            );
          }).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = chartData.fold<int>(0, (sum, item) => sum + item.count);

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (isError || chartData.isEmpty) {
      return const Center(child: Text("Error loading task status"));
    }

    return Card(
      margin: const EdgeInsets.only(top: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 180,
                  height: 180,
                  child: PieChart(
                    PieChartData(
                      sections: chartData.map((e) {
                        final percent = e.count / total * 100;
                        return PieChartSectionData(
                          value: e.count.toDouble(),
                          color: e.color,
                          title: "${percent.toStringAsFixed(0)}%",
                          radius: 60,
                          titleStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                      centerSpaceRadius: 40,
                    ),
                  ),
                ),
                Text(
                  '$total',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...chartData.map((e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: e.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        e.name,
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ],
                  ),
                  Text(
                    '${e.count}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  )
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _ChartData {
  final String name;
  final int count;
  final Color color;

  _ChartData({
    required this.name,
    required this.count,
    required this.color,
  });
}
