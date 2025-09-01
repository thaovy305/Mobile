// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../Helper/UriHelper.dart';
//
// class TimeComparisonChart extends StatefulWidget {
//   final String projectKey;
//
//   const TimeComparisonChart({super.key, required this.projectKey});
//
//   @override
//   State<TimeComparisonChart> createState() => _TimeComparisonChartState();
// }
//
// class _TimeComparisonChartState extends State<TimeComparisonChart> {
//   late Future<TimeDashboardData> _timeDataFuture;
//
//   @override
//   void initState() {
//     super.initState();
//     _timeDataFuture = fetchTimeDashboard(widget.projectKey);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<TimeDashboardData>(
//       future: _timeDataFuture,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Padding(
//             padding: EdgeInsets.all(8.0),
//             child: Text('Loading...', style: TextStyle(color: Colors.grey)),
//           );
//         }
//
//         if (snapshot.hasError || !snapshot.hasData) {
//           return const Padding(
//             padding: EdgeInsets.all(8.0),
//             child: Text('Error loading time dashboard'),
//           );
//         }
//
//         final data = snapshot.data!;
//         final delta = (data.actualCompletion - data.plannedCompletion).abs();
//         final chartData = [
//           _ChartItem("Planned Completion", data.plannedCompletion, data.status),
//           _ChartItem("Actual Completion", data.actualCompletion, data.status),
//           _ChartItem(data.status, delta, data.status),
//         ];
//
//         return Card(
//           margin: const EdgeInsets.all(10),
//           elevation: 2,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Wrap(
//                   spacing: 12,
//                   children: [
//                     _LegendDot(color: Colors.blue, label: 'Ahead'),
//                     _LegendDot(color: Colors.orange, label: 'Behind'),
//                     _LegendDot(color: Colors.green, label: 'On Time'),
//                   ],
//                 ),
//                 const SizedBox(height: 12),
//                 SizedBox(
//                   height: 200,
//                   child: BarChart(
//                     BarChartData(
//                       alignment: BarChartAlignment.spaceAround,
//                       maxY: 100,
//                       // barTouchData: BarTouchData(enabled: false),
//                       barTouchData: BarTouchData(
//                         enabled: true,
//                         touchTooltipData: BarTouchTooltipData(
//                           tooltipBgColor: Colors.black87,
//                           getTooltipItem: (group, groupIndex, rod, rodIndex) {
//                             final value = rod.toY.toStringAsFixed(1);
//                             return BarTooltipItem(
//                               '$value%',
//                               const TextStyle(color: Colors.white),
//                             );
//                           },
//                         ),
//                       ),
//                       titlesData: FlTitlesData(
//                         leftTitles: const AxisTitles(),
//                         topTitles: const AxisTitles(),
//                         rightTitles: const AxisTitles(),
//                         bottomTitles: AxisTitles(
//                           sideTitles: SideTitles(
//                             showTitles: true,
//                             reservedSize: 60,
//                             getTitlesWidget: (value, _) {
//                               final index = value.toInt();
//                               if (index < 0 || index >= chartData.length) return const SizedBox();
//                               return Transform.rotate(
//                                 angle: 0, //
//                                 child: Text(
//                                   chartData[index].name,
//                                   style: const TextStyle(fontSize: 14),
//                                 ),
//                               );
//                             },
//                           ),
//                         ),
//                       ),
//                       barGroups: chartData.asMap().entries.map((entry) {
//                         final index = entry.key;
//                         final item = entry.value;
//                         return BarChartGroupData(
//                           x: index,
//                           barRods: [
//                             BarChartRodData(
//                               toY: item.value,
//                               width: 20,
//                               borderRadius: BorderRadius.circular(6),
//                               color: item.color,
//                               backDrawRodData: BackgroundBarChartRodData(
//                                 show: true,
//                                 toY: 100,
//                                 color: Colors.grey[200],
//                               ),
//                             ),
//                           ],
//                         );
//                       }).toList(),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Status: ${_statusText(data.status)}',
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: _statusColor(data.status),
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   String _statusText(String status) {
//     switch (status) {
//       case 'Ahead':
//         return '🚀 Ahead of schedule';
//       case 'Behind':
//         return '🔺 Behind schedule';
//       default:
//         return '✅ On time';
//     }
//   }
//
//   Color _statusColor(String status) {
//     switch (status) {
//       case 'Ahead':
//         return Colors.blue;
//       case 'Behind':
//         return Colors.orange;
//       default:
//         return Colors.green;
//     }
//   }
// }
//
// // ====================== MODEL =======================
//
// class TimeDashboardData {
//   final double plannedCompletion;
//   final double actualCompletion;
//   final String status;
//
//   TimeDashboardData({
//     required this.plannedCompletion,
//     required this.actualCompletion,
//     required this.status,
//   });
//
//   factory TimeDashboardData.fromJson(Map<String, dynamic> json) {
//     return TimeDashboardData(
//       plannedCompletion: (json['plannedCompletion'] ?? 0).toDouble(),
//       actualCompletion: (json['actualCompletion'] ?? 0).toDouble(),
//       status: json['status'] ?? 'Unknown',
//     );
//   }
// }
//
// Future<TimeDashboardData> fetchTimeDashboard(String projectKey) async {
//   final url = UriHelper.build('/projectmetric/time-dashboard?projectKey=$projectKey');
//   final prefs = await SharedPreferences.getInstance();
//   final token = prefs.getString('accessToken') ?? '';
//
//   final response = await http.get(url, headers: {
//     'Content-Type': 'application/json',
//     'Accept': 'application/json',
//     'Authorization': 'Bearer $token',
//   });
//
//   if (response.statusCode == 200) {
//     final jsonData = json.decode(response.body);
//     return TimeDashboardData.fromJson(jsonData['data']);
//   } else {
//     throw Exception('Failed to load time dashboard');
//   }
// }
//
// // ===================== CHART ITEM =====================
//
// class _ChartItem {
//   final String name;
//   final double value;
//   final Color color;
//
//   _ChartItem(String name, double value, String status)
//       : name = name,
//         value = value,
//         color = status == 'Ahead'
//             ? Colors.blue
//             : status == 'Behind'
//             ? Colors.orange
//             : Colors.green;
// }
//
// // ===================== LEGEND =====================
//
// class _LegendDot extends StatelessWidget {
//   final Color color;
//   final String label;
//
//   const _LegendDot({required this.color, required this.label});
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
//         const SizedBox(width: 4),
//         Text(label, style: const TextStyle(fontSize: 12)),
//       ],
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'Dashboard.dart'; // Import TimeDashboardResponse and TimeData

class TimeComparisonChart extends StatelessWidget {
  final TimeDashboardResponse data;
  final bool isLoading;

  const TimeComparisonChart({super.key, required this.data, this.isLoading = false});

  // Fallback health status map (mirroring React's fallback)
  static const Map<String, Map<String, dynamic>> healthStatusMap = {
    'AHEAD': {'name': 'AHEAD', 'label': 'Ahead', 'color': Color(0xFF00BFFF)},
    'BEHIND': {'name': 'BEHIND', 'label': 'Behind', 'color': Color(0xFFFFA500)},
    'ON_TIME': {'name': 'ON_TIME', 'label': 'On Time', 'color': Color(0xFF00C49F)},
  };

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Text(
        'Loading...',
        style: TextStyle(fontSize: 14, color: Colors.grey),
      );
    }
    if (!data.isSuccess || data.data == null) {
      return const Text(
        'Error loading time dashboard',
        style: TextStyle(fontSize: 14, color: Colors.red),
      );
    }

    final timeData = data.data;
    final currentStatus = healthStatusMap[timeData.status] ??
        {'name': timeData.status, 'label': timeData.status, 'color': const Color(0xFFD3D3D3)};
    final deltaValue = (timeData.actualCompletion - timeData.plannedCompletion).abs();

    final chartData = [
      {'name': 'Planned Completion', 'value': timeData.plannedCompletion, 'color': currentStatus['color']},
      {'name': 'Actual Completion', 'value': timeData.actualCompletion, 'color': currentStatus['color']},
      {'name': currentStatus['label'], 'value': deltaValue, 'color': currentStatus['color']},
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0), // Matches p-4
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Legend
          Wrap(
            spacing: 16, // Matches gap-4
            children: healthStatusMap.values
                .where((status) => ['AHEAD', 'BEHIND', 'ON_TIME'].contains(status['name']))
                .map((status) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: status['color'] as Color,
                  ),
                ),
                const SizedBox(width: 4), // Matches gap-1
                Text(
                  status['label'] as String,
                  style: const TextStyle(fontSize: 14, color: Colors.grey), // Matches text-sm text-gray-600
                ),
              ],
            ))
                .toList(),
          ),
          const SizedBox(height: 16), // Matches mb-4
          // Bar Chart
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                maxY: 100,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${chartData[groupIndex]['value'].toStringAsFixed(0)}%',
                        const TextStyle(color: Colors.white),
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
                      reservedSize: 40, // Adjusted for percentage labels
                      getTitlesWidget: (value, meta) {
                        if (value % 25 == 0) { // Show labels at 0%, 25%, 50%, 75%, 100%
                          return Text(
                            '${value.toInt()}%',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.end,
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  // bottomTitles: AxisTitles(
                  //   sideTitles: SideTitles(
                  //     showTitles: true,
                  //     reservedSize: 60, // Increased to accommodate multi-word labels
                  //     getTitlesWidget: (value, meta) {
                  //       final index = value.toInt();
                  //       if (index >= 0 && index < chartData.length) {
                  //         return Padding(
                  //           padding: const EdgeInsets.only(top: 8),
                  //           child: Text(
                  //             chartData[index]['name'] as String,
                  //             style: const TextStyle(fontSize: 12, color: Colors.grey),
                  //             textAlign: TextAlign.center,
                  //             maxLines: 2,
                  //             overflow: TextOverflow.ellipsis,
                  //           ),
                  //         );
                  //       }
                  //       return const SizedBox.shrink();
                  //     },
                  //   ),
                  // ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 70, // Giữ không gian đủ lớn
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < chartData.length) {
                          return Transform.rotate(
                            angle: -10 * 3.14159 / 180, // Xoay 45 độ (radian)
                            child: Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Text(
                                chartData[index]['name'] as String,
                                style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: chartData.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: (item['value'] as double).clamp(0, 100),
                        color: item['color'] as Color,
                        width: 20, // Matches barCategoryGap=15 adjusted for Flutter
                        borderRadius: BorderRadius.zero,
                        rodStackItems: [
                          BarChartRodStackItem(
                            0,
                            (item['value'] as double).clamp(0, 100),
                            item['color'] as Color,
                          ),
                        ],
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          // Status Text
          Padding(
            padding: const EdgeInsets.only(top: 8), // Matches mt-2
            child: Row(
              children: [
                const Text(
                  'Status: ',
                  style: TextStyle(fontSize: 14, color: Colors.grey), // Matches text-sm text-gray-600
                ),
                Text(
                  timeData.status == 'AHEAD'
                      ? '🚀 ${currentStatus['label']}'
                      : timeData.status == 'BEHIND'
                      ? '🔺 ${currentStatus['label']}'
                      : '✅ ${currentStatus['label']}',
                  style: TextStyle(
                    fontSize: 14,
                    color: timeData.status == 'AHEAD'
                        ? const Color(0xFF3B82F6) // text-blue-500
                        : timeData.status == 'BEHIND'
                        ? const Color(0xFFF97316) // text-orange-500
                        : const Color(0xFF10B981), // text-green-500
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
