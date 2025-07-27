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
//           members = data
//               .map((item) => WorkloadMember.fromJson(item))
//               .toList();
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
//     return SizedBox(
//       height: 300,
//       child: BarChart(
//         BarChartData(
//           alignment: BarChartAlignment.spaceAround,
//           barGroups: members
//               .asMap()
//               .entries
//               .map((entry) {
//             final index = entry.key;
//             final member = entry.value;
//             return BarChartGroupData(
//               x: index,
//               barRods: [
//                 BarChartRodData(
//                   toY: member.completed.toDouble(),
//                   color: Colors.teal,
//                   width: 6,
//                 ),
//                 BarChartRodData(
//                   toY: member.remaining.toDouble(),
//                   color: Colors.blueAccent,
//                   width: 6,
//                 ),
//                 BarChartRodData(
//                   toY: member.overdue.toDouble(),
//                   color: Colors.redAccent,
//                   width: 6,
//                 ),
//               ],
//               showingTooltipIndicators: [0, 1, 2],
//             );
//           })
//               .toList(),
//           titlesData: FlTitlesData(
//             leftTitles: const AxisTitles(
//               sideTitles: SideTitles(showTitles: true),
//             ),
//             bottomTitles: AxisTitles(
//               sideTitles: SideTitles(
//                 showTitles: true,
//                 getTitlesWidget: (index, _) {
//                   return Padding(
//                     padding: const EdgeInsets.only(top: 8),
//                     child: Text(
//                       members[index.toInt()].memberName,
//                       style: const TextStyle(fontSize: 10),
//                     ),
//                   );
//                 },
//               ),
//             ),
//             topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//             rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//           ),
//           barTouchData: BarTouchData(
//             enabled: true,
//             touchTooltipData: BarTouchTooltipData(
//               tooltipBgColor: Colors.grey.shade200,
//               getTooltipItem: (group, groupIndex, rod, rodIndex) {
//                 final member = members[group.x.toInt()];
//                 final label = ['Completed', 'Remaining', 'Overdue'][rodIndex];
//                 final value = [member.completed, member.remaining, member.overdue][rodIndex];
//                 return BarTooltipItem('$label: $value\n', const TextStyle(color: Colors.black));
//               },
//             ),
//           ),
//         ),
//       ),
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

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../Helper/UriHelper.dart';

class WorkloadChart extends StatefulWidget {
  final String projectKey;
  const WorkloadChart({super.key, required this.projectKey});

  @override
  State<WorkloadChart> createState() => _WorkloadChartState();
}

class _WorkloadChartState extends State<WorkloadChart> {
  bool isLoading = true;
  bool isError = false;
  List<WorkloadMember> members = [];

  @override
  void initState() {
    super.initState();
    fetchWorkloadData();
  }

  Future<void> fetchWorkloadData() async {
    final url = UriHelper.build('/projectmetric/workload-dashboard?projectKey=${widget.projectKey}');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';

    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });
      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        final List<dynamic> data = jsonBody['data'];
        setState(() {
          members = data.map((item) => WorkloadMember.fromJson(item)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isError = true;
          isLoading = false;
        });
      }
    } catch (_) {
      setState(() {
        isError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (isError || members.isEmpty) {
      return const Center(child: Text('Failed to load workload chart'));
    }

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Team Workload',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  groupsSpace: 30,
                  barGroups: members.asMap().entries.map((entry) {
                    final index = entry.key;
                    final member = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barsSpace: 4,
                      barRods: [
                        BarChartRodData(
                          toY: member.completed.toDouble(),
                          color: Colors.teal,
                          width: 8,
                          borderRadius: BorderRadius.circular(0),
                        ),
                        BarChartRodData(
                          toY: member.remaining.toDouble(),
                          color: Colors.blueAccent,
                          width: 8,
                          borderRadius: BorderRadius.circular(0),
                        ),
                        BarChartRodData(
                          toY: member.overdue.toDouble(),
                          color: Colors.redAccent,
                          width: 8,
                          borderRadius: BorderRadius.circular(0),
                        ),
                      ],
                      showingTooltipIndicators: [],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    // leftTitles: const AxisTitles(
                    //   sideTitles: SideTitles(
                    //     showTitles: true,
                    //     reservedSize: 28,
                    //   ),
                    // ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (value, _) {
                          if (value % 1 == 0) {
                            return Text('${value.toInt()}', style: const TextStyle(fontSize: 10));
                          }
                          return const SizedBox(); // Ẩn số lẻ
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (index, _) {
                          return SideTitleWidget(
                            axisSide: AxisSide.bottom,
                            child: Text(
                              members[index.toInt()].memberName,
                              style: const TextStyle(fontSize: 10),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.white,
                      tooltipBorder: BorderSide(color: Colors.grey.shade400),
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final member = members[group.x.toInt()];
                        final labels = ['Completed', 'Remaining', 'Overdue'];
                        final values = [
                          member.completed,
                          member.remaining,
                          member.overdue
                        ];
                        final color = [Colors.teal, Colors.blueAccent, Colors.redAccent][rodIndex];
                        return BarTooltipItem(
                          '${labels[rodIndex]}: ${values[rodIndex]}',
                          TextStyle(color: color, fontWeight: FontWeight.w500),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                LegendItem(label: 'Completed', color: Colors.teal),
                SizedBox(width: 12),
                LegendItem(label: 'Remaining', color: Colors.blueAccent),
                SizedBox(width: 12),
                LegendItem(label: 'Overdue', color: Colors.redAccent),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class LegendItem extends StatelessWidget {
  final String label;
  final Color color;
  const LegendItem({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class WorkloadMember {
  final String memberName;
  final int completed;
  final int remaining;
  final int overdue;

  WorkloadMember({
    required this.memberName,
    required this.completed,
    required this.remaining,
    required this.overdue,
  });

  factory WorkloadMember.fromJson(Map<String, dynamic> json) {
    return WorkloadMember(
      memberName: json['memberName'],
      completed: json['completed'],
      remaining: json['remaining'],
      overdue: json['overdue'],
    );
  }
}
