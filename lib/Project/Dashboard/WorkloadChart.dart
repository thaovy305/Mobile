// // import 'package:flutter/material.dart';
// // import 'package:fl_chart/fl_chart.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:shared_preferences/shared_preferences.dart';
// // import 'dart:convert';
// //
// // import '../../Helper/UriHelper.dart';
// //
// // class WorkloadChart extends StatefulWidget {
// //   final String projectKey;
// //   const WorkloadChart({super.key, required this.projectKey});
// //
// //   @override
// //   State<WorkloadChart> createState() => _WorkloadChartState();
// // }
// //
// // class _WorkloadChartState extends State<WorkloadChart> {
// //   bool isLoading = true;
// //   bool isError = false;
// //   List<WorkloadMember> members = [];
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     fetchWorkloadData();
// //   }
// //
// //   Future<void> fetchWorkloadData() async {
// //     final url = UriHelper.build('/projectmetric/workload-dashboard?projectKey=${widget.projectKey}');
// //     final prefs = await SharedPreferences.getInstance();
// //     final token = prefs.getString('accessToken') ?? '';
// //
// //     try {
// //       final response = await http.get(url, headers: {
// //         'Content-Type': 'application/json',
// //         'Accept': 'application/json',
// //         'Authorization': 'Bearer $token',
// //       });
// //       if (response.statusCode == 200) {
// //         final jsonBody = json.decode(response.body);
// //         final List<dynamic> data = jsonBody['data'];
// //         setState(() {
// //           members = data
// //               .map((item) => WorkloadMember.fromJson(item))
// //               .toList();
// //           isLoading = false;
// //         });
// //       } else {
// //         setState(() {
// //           isError = true;
// //           isLoading = false;
// //         });
// //       }
// //     } catch (_) {
// //       setState(() {
// //         isError = true;
// //         isLoading = false;
// //       });
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     if (isLoading) {
// //       return const Center(child: CircularProgressIndicator());
// //     }
// //
// //     if (isError || members.isEmpty) {
// //       return const Center(child: Text('Failed to load workload chart'));
// //     }
// //
// //     return SizedBox(
// //       height: 300,
// //       child: BarChart(
// //         BarChartData(
// //           alignment: BarChartAlignment.spaceAround,
// //           barGroups: members
// //               .asMap()
// //               .entries
// //               .map((entry) {
// //             final index = entry.key;
// //             final member = entry.value;
// //             return BarChartGroupData(
// //               x: index,
// //               barRods: [
// //                 BarChartRodData(
// //                   toY: member.completed.toDouble(),
// //                   color: Colors.teal,
// //                   width: 6,
// //                 ),
// //                 BarChartRodData(
// //                   toY: member.remaining.toDouble(),
// //                   color: Colors.blueAccent,
// //                   width: 6,
// //                 ),
// //                 BarChartRodData(
// //                   toY: member.overdue.toDouble(),
// //                   color: Colors.redAccent,
// //                   width: 6,
// //                 ),
// //               ],
// //               showingTooltipIndicators: [0, 1, 2],
// //             );
// //           })
// //               .toList(),
// //           titlesData: FlTitlesData(
// //             leftTitles: const AxisTitles(
// //               sideTitles: SideTitles(showTitles: true),
// //             ),
// //             bottomTitles: AxisTitles(
// //               sideTitles: SideTitles(
// //                 showTitles: true,
// //                 getTitlesWidget: (index, _) {
// //                   return Padding(
// //                     padding: const EdgeInsets.only(top: 8),
// //                     child: Text(
// //                       members[index.toInt()].memberName,
// //                       style: const TextStyle(fontSize: 10),
// //                     ),
// //                   );
// //                 },
// //               ),
// //             ),
// //             topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
// //             rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
// //           ),
// //           barTouchData: BarTouchData(
// //             enabled: true,
// //             touchTooltipData: BarTouchTooltipData(
// //               tooltipBgColor: Colors.grey.shade200,
// //               getTooltipItem: (group, groupIndex, rod, rodIndex) {
// //                 final member = members[group.x.toInt()];
// //                 final label = ['Completed', 'Remaining', 'Overdue'][rodIndex];
// //                 final value = [member.completed, member.remaining, member.overdue][rodIndex];
// //                 return BarTooltipItem('$label: $value\n', const TextStyle(color: Colors.black));
// //               },
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // class WorkloadMember {
// //   final String memberName;
// //   final int completed;
// //   final int remaining;
// //   final int overdue;
// //
// //   WorkloadMember({
// //     required this.memberName,
// //     required this.completed,
// //     required this.remaining,
// //     required this.overdue,
// //   });
// //
// //   factory WorkloadMember.fromJson(Map<String, dynamic> json) {
// //     return WorkloadMember(
// //       memberName: json['memberName'],
// //       completed: json['completed'],
// //       remaining: json['remaining'],
// //       overdue: json['overdue'],
// //     );
// //   }
// // }
//
// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
//
// import '../../Helper/UriHelper.dart';
//
// class WorkloadChart extends StatefulWidget {
//   final String projectKey;
//   const WorkloadChart({super.key, required this.projectKey});
//
//   @override
//   State<WorkloadChart> createState() => _WorkloadChartState();
// }
//
// class _WorkloadChartState extends State<WorkloadChart> {
//   bool isLoading = true;
//   bool isError = false;
//   List<WorkloadMember> members = [];
//
//   @override
//   void initState() {
//     super.initState();
//     fetchWorkloadData();
//   }
//
//   Future<void> fetchWorkloadData() async {
//     final url = UriHelper.build('/projectmetric/workload-dashboard?projectKey=${widget.projectKey}');
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('accessToken') ?? '';
//
//     try {
//       final response = await http.get(url, headers: {
//         'Content-Type': 'application/json',
//         'Accept': 'application/json',
//         'Authorization': 'Bearer $token',
//       });
//       if (response.statusCode == 200) {
//         final jsonBody = json.decode(response.body);
//         final List<dynamic> data = jsonBody['data'];
//         setState(() {
//           members = data.map((item) => WorkloadMember.fromJson(item)).toList();
//           isLoading = false;
//         });
//       } else {
//         setState(() {
//           isError = true;
//           isLoading = false;
//         });
//       }
//     } catch (_) {
//       setState(() {
//         isError = true;
//         isLoading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }
//
//     if (isError || members.isEmpty) {
//       return const Center(child: Text('Failed to load workload chart'));
//     }
//
//     return Card(
//       margin: const EdgeInsets.all(16),
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             const Text(
//               'Team Workload',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 16),
//             SizedBox(
//               height: 300,
//               child: BarChart(
//                 BarChartData(
//                   alignment: BarChartAlignment.spaceAround,
//                   groupsSpace: 30,
//                   barGroups: members.asMap().entries.map((entry) {
//                     final index = entry.key;
//                     final member = entry.value;
//                     return BarChartGroupData(
//                       x: index,
//                       barsSpace: 4,
//                       barRods: [
//                         BarChartRodData(
//                           toY: member.completed.toDouble(),
//                           color: Colors.teal,
//                           width: 8,
//                           borderRadius: BorderRadius.circular(0),
//                         ),
//                         BarChartRodData(
//                           toY: member.remaining.toDouble(),
//                           color: Colors.blueAccent,
//                           width: 8,
//                           borderRadius: BorderRadius.circular(0),
//                         ),
//                         BarChartRodData(
//                           toY: member.overdue.toDouble(),
//                           color: Colors.redAccent,
//                           width: 8,
//                           borderRadius: BorderRadius.circular(0),
//                         ),
//                       ],
//                       showingTooltipIndicators: [],
//                     );
//                   }).toList(),
//                   titlesData: FlTitlesData(
//                     // leftTitles: const AxisTitles(
//                     //   sideTitles: SideTitles(
//                     //     showTitles: true,
//                     //     reservedSize: 28,
//                     //   ),
//                     // ),
//                     leftTitles: AxisTitles(
//                       sideTitles: SideTitles(
//                         showTitles: true,
//                         reservedSize: 28,
//                         getTitlesWidget: (value, _) {
//                           if (value % 1 == 0) {
//                             return Text('${value.toInt()}', style: const TextStyle(fontSize: 10));
//                           }
//                           return const SizedBox(); // Ẩn số lẻ
//                         },
//                       ),
//                     ),
//                     bottomTitles: AxisTitles(
//                       sideTitles: SideTitles(
//                         showTitles: true,
//                         getTitlesWidget: (index, _) {
//                           return SideTitleWidget(
//                             axisSide: AxisSide.bottom,
//                             child: Text(
//                               members[index.toInt()].memberName,
//                               style: const TextStyle(fontSize: 10),
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                     topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                     rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                   ),
//                   barTouchData: BarTouchData(
//                     enabled: true,
//                     touchTooltipData: BarTouchTooltipData(
//                       tooltipBgColor: Colors.white,
//                       tooltipBorder: BorderSide(color: Colors.grey.shade400),
//                       getTooltipItem: (group, groupIndex, rod, rodIndex) {
//                         final member = members[group.x.toInt()];
//                         final labels = ['Completed', 'Remaining', 'Overdue'];
//                         final values = [
//                           member.completed,
//                           member.remaining,
//                           member.overdue
//                         ];
//                         final color = [Colors.teal, Colors.blueAccent, Colors.redAccent][rodIndex];
//                         return BarTooltipItem(
//                           '${labels[rodIndex]}: ${values[rodIndex]}',
//                           TextStyle(color: color, fontWeight: FontWeight.w500),
//                         );
//                       },
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             // Legend
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: const [
//                 LegendItem(label: 'Completed', color: Colors.teal),
//                 SizedBox(width: 12),
//                 LegendItem(label: 'Remaining', color: Colors.blueAccent),
//                 SizedBox(width: 12),
//                 LegendItem(label: 'Overdue', color: Colors.redAccent),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class LegendItem extends StatelessWidget {
//   final String label;
//   final Color color;
//   const LegendItem({super.key, required this.label, required this.color});
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Container(width: 12, height: 12, color: color),
//         const SizedBox(width: 4),
//         Text(label, style: const TextStyle(fontSize: 12)),
//       ],
//     );
//   }
// }
//
// class WorkloadMember {
//   final String memberName;
//   final int completed;
//   final int remaining;
//   final int overdue;
//
//   WorkloadMember({
//     required this.memberName,
//     required this.completed,
//     required this.remaining,
//     required this.overdue,
//   });
//
//   factory WorkloadMember.fromJson(Map<String, dynamic> json) {
//     return WorkloadMember(
//       memberName: json['memberName'],
//       completed: json['completed'],
//       remaining: json['remaining'],
//       overdue: json['overdue'],
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'Dashboard.dart';
//
// class WorkloadChart extends StatelessWidget {
//   final WorkloadDashboardResponse data;
//   final bool isLoading;
//
//   const WorkloadChart({super.key, required this.data, this.isLoading = false});
//
//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) {
//       return const Text(
//         'Loading...',
//         style: TextStyle(fontSize: 14, color: Colors.grey),
//       );
//     }
//     if (!data.isSuccess || data.data.isEmpty) {
//       return Text(
//         'Failed to load workload chart: ${data.message.isNotEmpty ? data.message : "No data available"}',
//         style: const TextStyle(fontSize: 14, color: Colors.red),
//       );
//     }
//
//     final chartData = data.data.map((member) {
//       print('Processing member: ${member.memberName}, completed: ${member.completed.runtimeType}, remaining: ${member.remaining.runtimeType}, overdue: ${member.overdue.runtimeType}');
//       return {
//         'name': member.memberName,
//         'Completed': _toDouble(member.completed),
//         'Remaining': _toDouble(member.remaining),
//         'Overdue': _toDouble(member.overdue),
//       };
//     }).toList();
//
//     // Calculate maxY based on the sum of tasks for each member
//     final maxTasks = chartData
//         .map((member) =>
//     (member['Completed'] as double) +
//         (member['Remaining'] as double) +
//         (member['Overdue'] as double))
//         .reduce((a, b) => a > b ? a : b)
//         .ceil()
//         .toDouble();
//     final maxY = maxTasks > 0 ? maxTasks * 1.2 : 10.0;
//
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Wrap(
//             spacing: 16,
//             children: [
//               _buildLegendItem('Completed', const Color(0xFF00C49F)),
//               _buildLegendItem('Remaining', const Color(0xFF00E0FF)),
//               _buildLegendItem('Overdue', const Color(0xFFFF4D4F)),
//             ],
//           ),
//           const SizedBox(height: 16),
//           SizedBox(
//             height: 300,
//             child: BarChart(
//               BarChartData(
//                 maxY: maxY,
//                 barTouchData: BarTouchData(
//                   enabled: true,
//                   touchTooltipData: BarTouchTooltipData(
//                     getTooltipItem: (group, groupIndex, rod, rodIndex) {
//                       final keys = ['Completed', 'Remaining', 'Overdue'];
//                       return BarTooltipItem(
//                         '${keys[rodIndex]}: ${rod.toY.toInt()}',
//                         const TextStyle(color: Colors.white, fontSize: 12),
//                       );
//                     },
//                   ),
//                 ),
//                 titlesData: FlTitlesData(
//                   topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                   rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                   leftTitles: AxisTitles(
//                     sideTitles: SideTitles(
//                       showTitles: true,
//                       reservedSize: 100,
//                       getTitlesWidget: (value, meta) {
//                         final index = value.toInt();
//                         if (index >= 0 && index < chartData.length) {
//                           return Padding(
//                             padding: const EdgeInsets.only(right: 8),
//                             child: Text(
//                               chartData[index]['name'] as String,
//                               style: const TextStyle(fontSize: 12, color: Colors.grey),
//                               textAlign: TextAlign.right,
//                               maxLines: 2,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           );
//                         }
//                         return const SizedBox.shrink();
//                       },
//                     ),
//                   ),
//                   bottomTitles: AxisTitles(
//                     sideTitles: SideTitles(
//                       showTitles: true,
//                       reservedSize: 40,
//                       getTitlesWidget: (value, meta) {
//                         if (value % (maxY / 5).ceil() == 0) {
//                           return Text(
//                             value.toInt().toString(),
//                             style: const TextStyle(fontSize: 12, color: Colors.grey),
//                           );
//                         }
//                         return const SizedBox.shrink();
//                       },
//                     ),
//                   ),
//                 ),
//                 gridData: FlGridData(
//                   show: true,
//                   drawVerticalLine: true,
//                   getDrawingHorizontalLine: (value) => const FlLine(
//                     color: Colors.grey,
//                     strokeWidth: 1,
//                     dashArray: [3, 3],
//                   ),
//                 ),
//                 borderData: FlBorderData(show: false),
//                 barGroups: chartData.asMap().entries.map((entry) {
//                   final index = entry.key;
//                   final member = entry.value;
//                   double stackStart = 0;
//                   return BarChartGroupData(
//                     x: index,
//                     barRods: [
//                       BarChartRodData(
//                         toY: (member['Completed'] as double),
//                         color: const Color(0xFF00C49F),
//                         width: 20,
//                         borderRadius: BorderRadius.zero,
//                         rodStackItems: [
//                           BarChartRodStackItem(
//                             stackStart,
//                             stackStart + (member['Completed'] as double),
//                             const Color(0xFF00C49F),
//                           ),
//                         ],
//                       ),
//                       BarChartRodData(
//                         toY: (member['Remaining'] as double),
//                         color: const Color(0xFF00E0FF),
//                         width: 20,
//                         borderRadius: BorderRadius.zero,
//                         rodStackItems: [
//                           BarChartRodStackItem(
//                             stackStart,
//                             stackStart + (member['Remaining'] as double),
//                             const Color(0xFF00E0FF),
//                           ),
//                         ],
//                       ),
//                       BarChartRodData(
//                         toY: (member['Overdue'] as double),
//                         color: const Color(0xFFFF4D4F),
//                         width: 20,
//                         borderRadius: BorderRadius.zero,
//                         rodStackItems: [
//                           BarChartRodStackItem(
//                             stackStart,
//                             stackStart + (member['Overdue'] as double),
//                             const Color(0xFFFF4D4F),
//                           ),
//                         ],
//                       ),
//                     ],
//                     showingTooltipIndicators: [0, 1, 2],
//                     barsSpace: 0,
//                   );
//                 }).toList(),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildLegendItem(String label, Color color) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Container(
//           width: 12,
//           height: 12,
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             color: color,
//           ),
//         ),
//         const SizedBox(width: 4),
//         Text(
//           label,
//           style: const TextStyle(fontSize: 14, color: Colors.grey),
//         ),
//       ],
//     );
//   }
//
//   double _toDouble(dynamic value) {
//     if (value == null) return 0.0;
//     if (value is num) return value.toDouble();
//     if (value is String) {
//       try {
//         return double.parse(value);
//       } catch (e) {
//         print('Error parsing double from string: $value');
//         return 0.0;
//       }
//     }
//     print('Unexpected type for double field: ${value.runtimeType}');
//     return 0.0;
//   }
// }


import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'Dashboard.dart';

class WorkloadChart extends StatelessWidget {
  final WorkloadDashboardResponse data;
  final bool isLoading;

  const WorkloadChart({super.key, required this.data, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Text(
        'Loading...',
        style: TextStyle(fontSize: 14, color: Colors.grey),
      );
    }
    if (!data.isSuccess || data.data.isEmpty) {
      return Text(
        'Failed to load workload chart: ${data.message.isNotEmpty ? data.message : "No data available"}',
        style: const TextStyle(fontSize: 14, color: Colors.red),
      );
    }

    final chartData = data.data.asMap().entries.map((entry) {
      final member = entry.value;
      print('Processing member: ${member.memberName}, '
          'completed: ${member.completed} (${member.completed.runtimeType}), '
          'remaining: ${member.remaining} (${member.remaining.runtimeType}), '
          'overdue: ${member.overdue} (${member.overdue.runtimeType})');
      return {
        'index': entry.key,
        'name': member.memberName,
        'Completed': _toDouble(member.completed),
        'Remaining': _toDouble(member.remaining),
        'Overdue': _toDouble(member.overdue),
      };
    }).toList();

    // Calculate maxX (total tasks) for the horizontal axis
    final maxTasks = chartData
        .map((member) =>
    (member['Completed'] as double) +
        (member['Remaining'] as double) +
        (member['Overdue'] as double))
        .reduce((a, b) => a > b ? a : b)
        .ceil()
        .toDouble();
    final maxX = maxTasks > 0 ? maxTasks * 1.2 : 10.0;

    return Padding(
      padding: const EdgeInsets.only(
        top: 20.0, // Matches web margin top: 20px
        right: 30.0, // Matches web margin right: 30px
        left: 10.0, // Matches web margin left: 10px
        bottom: 5.0, // Matches web margin bottom: 5px
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Legends (always visible, matching web Legend)
          Wrap(
            spacing: 16,
            children: [
              _buildLegendItem('Completed', const Color(0xFF00C49F)),
              _buildLegendItem('Remaining', const Color(0xFF00E0FF)),
              _buildLegendItem('Overdue', const Color(0xFFFF4D4F)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300, // Matches web height: 300px
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: chartData.length - 0.5, // Prevent duplicate labels
                minY: -0.5,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.black.withOpacity(0.8),
                    tooltipRoundedRadius: 8,
                    tooltipPadding: const EdgeInsets.all(8),
                    tooltipMargin: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final keys = ['Completed', 'Remaining', 'Overdue'];
                      final member = chartData[groupIndex];
                      return BarTooltipItem(
                        '${keys[rodIndex]}: ${(member[keys[rodIndex]] as double).toInt()}',
                        const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
                  handleBuiltInTouches: true,
                ),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        if (value % (maxX / 5).ceil() == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              value.toInt().toString(),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 100,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < chartData.length && value == index.toDouble()) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              chartData[index]['name'] as String,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.right,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  drawHorizontalLine: false,
                  getDrawingVerticalLine: (value) => FlLine(
                    color: Colors.grey.withOpacity(0.3),
                    strokeWidth: 1,
                    dashArray: [3, 3],
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: chartData.asMap().entries.map((entry) {
                  final index = entry.value['index'] as int;
                  final member = entry.value;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: index.toDouble(), // Position bar at index
                        fromY: index.toDouble() - 0.4, // Fixed height for bar
                        width: 25,
                        color: Colors.transparent,
                        rodStackItems: [
                          BarChartRodStackItem(
                            0,
                            member['Completed'] as double,
                            const Color(0xFF00C49F),
                          ),
                          BarChartRodStackItem(
                            member['Completed'] as double,
                            (member['Completed'] as double) + (member['Remaining'] as double),
                            const Color(0xFF00E0FF),
                          ),
                          BarChartRodStackItem(
                            (member['Completed'] as double) + (member['Remaining'] as double),
                            (member['Completed'] as double) +
                                (member['Remaining'] as double) +
                                (member['Overdue'] as double),
                            const Color(0xFFFF4D4F),
                          ),
                        ],
                        borderRadius: BorderRadius.zero,
                      ),
                    ],
                    showingTooltipIndicators: [],
                  );
                }).toList(),
              ),
              swapAnimationDuration: const Duration(milliseconds: 300),
              swapAnimationCurve: Curves.easeInOut,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        print('Error parsing double from string: $value');
        return 0.0;
      }
    }
    print('Unexpected type for double field: ${value.runtimeType}');
    return 0.0;
  }
}

