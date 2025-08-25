// import 'dart:convert';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../Helper/UriHelper.dart';
//
// class TaskStatusChart extends StatefulWidget {
//   final String projectKey;
//
//   const TaskStatusChart({super.key, required this.projectKey});
//
//   @override
//   State<TaskStatusChart> createState() => _TaskStatusChartState();
// }
//
// class _TaskStatusChartState extends State<TaskStatusChart> {
//   List<_ChartData> chartData = [];
//   bool isLoading = true;
//   bool isError = false;
//
//   final List<Color> defaultColors = const [
//     Colors.grey,
//     Colors.blue,
//     Colors.green,
//     Colors.orange,
//     Colors.red,
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     fetchChartData();
//   }
//
//   Future<void> fetchChartData() async {
//     try {
//       final uri = UriHelper.build('/projectmetric/tasks-dashboard?projectKey=${widget.projectKey}');
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('accessToken') ?? '';
//
//       final response = await http.get(
//         uri,
//         headers: {
//           "Content-Type": "application/json",
//           'Authorization': 'Bearer $token',
//         },
//       );
//
//       if (response.statusCode == 200) {
//         final decoded = json.decode(response.body);
//         final List<dynamic> items = decoded['data']['statusCounts'];
//         setState(() {
//           chartData = items.asMap().entries.map((entry) {
//             final index = entry.key;
//             final item = entry.value;
//             final String name = item['name']
//                 .toString()
//                 .replaceAll('_', ' ')
//                 .toLowerCase()
//                 .replaceFirstMapped(RegExp(r'^\w'), (m) => m.group(0)!.toUpperCase());
//             return _ChartData(
//               name: name,
//               count: item['count'],
//               color: defaultColors[index % defaultColors.length],
//             );
//           }).toList();
//           isLoading = false;
//         });
//       } else {
//         setState(() {
//           isError = true;
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         isError = true;
//         isLoading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final total = chartData.fold<int>(0, (sum, item) => sum + item.count);
//
//     if (isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }
//
//     if (isError || chartData.isEmpty) {
//       return const Center(child: Text("Error loading task status"));
//     }
//
//     return Card(
//       margin: const EdgeInsets.only(top: 16.0),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Stack(
//               alignment: Alignment.center,
//               children: [
//                 SizedBox(
//                   width: 180,
//                   height: 180,
//                   child: PieChart(
//                     PieChartData(
//                       sections: chartData.map((e) {
//                         final percent = e.count / total * 100;
//                         return PieChartSectionData(
//                           value: e.count.toDouble(),
//                           color: e.color,
//                           title: "${percent.toStringAsFixed(0)}%",
//                           radius: 60,
//                           titleStyle: const TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         );
//                       }).toList(),
//                       centerSpaceRadius: 40,
//                     ),
//                   ),
//                 ),
//                 Text(
//                   '$total',
//                   style: const TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.black87,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             ...chartData.map((e) => Padding(
//               padding: const EdgeInsets.symmetric(vertical: 2),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Row(
//                     children: [
//                       Container(
//                         width: 10,
//                         height: 10,
//                         decoration: BoxDecoration(
//                           color: e.color,
//                           shape: BoxShape.circle,
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       Text(
//                         e.name,
//                         style: const TextStyle(color: Colors.black87),
//                       ),
//                     ],
//                   ),
//                   Text(
//                     '${e.count}',
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black87,
//                     ),
//                   )
//                 ],
//               ),
//             )),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _ChartData {
//   final String name;
//   final int count;
//   final Color color;
//
//   _ChartData({
//     required this.name,
//     required this.count,
//     required this.color,
//   });
// }


import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'Dashboard.dart'; // Import TaskStatusDashboardResponse and TaskStatusItem

class TaskStatusChart extends StatelessWidget {
  final TaskStatusDashboardResponse data;
  final bool isLoading;

  const TaskStatusChart({super.key, required this.data, this.isLoading = false});

  // Define colors matching the React component
  static const List<Color> defaultColors = [
    Color(0xFFD3D3D3), // Light gray
    Color(0xFF00BFFF), // Deep sky blue
    Color(0xFF00C49F), // Teal
    Color(0xFFFFA500), // Orange
    Color(0xFFFF6384), // Red
  ];

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Text(
        'Loading...',
        style: TextStyle(fontSize: 14, color: Colors.grey),
      );
    }
    if (!data.isSuccess || data.statusCounts.isEmpty) {
      return const Text(
        'Error loading task status',
        style: TextStyle(fontSize: 14, color: Colors.red),
      );
    }

    // Process chart data
    final chartData = data.statusCounts.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      // Format name: replace underscores and capitalize words
      final formattedName = item.name
          .replaceAll('_', ' ')
          .toLowerCase()
          .split(' ')
          .map((word) => word.isNotEmpty
          ? '${word[0].toUpperCase()}${word.substring(1)}'
          : '')
          .join(' ');
      return {
        'name': formattedName,
        'value': item.count.toDouble(),
        'color': defaultColors[index % defaultColors.length],
      };
    }).toList();

    // Calculate total
    final total = chartData.fold<double>(
        0, (sum, item) => sum + (item['value'] as double));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Pie Chart
        SizedBox(
          width: 180,
          height: 180,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sections: chartData.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return PieChartSectionData(
                      value: item['value'] as double,
                      color: item['color'] as Color,
                      radius: 20, // (70 - 50) to match innerRadius=50, outerRadius=70
                      showTitle: false,
                    );
                  }).toList(),
                  sectionsSpace: 3, // Matches paddingAngle=3
                  centerSpaceRadius: 50, // Matches innerRadius=50
                ),
              ),
              Text(
                total.toInt().toString(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        // Legend
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            children: chartData.asMap().entries.map((entry) {
              final item = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: item['color'] as Color,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item['name'] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      (item['value'] as double).toInt().toString(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
