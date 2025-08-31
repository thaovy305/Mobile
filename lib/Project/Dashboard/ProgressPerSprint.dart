// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../Helper/UriHelper.dart';
//
// // =================== MAIN WIDGET ===================
//
// class ProgressPerSprint extends StatefulWidget {
//   final String projectKey;
//
//   const ProgressPerSprint({super.key, required this.projectKey});
//
//   @override
//   State<ProgressPerSprint> createState() => _ProgressPerSprintState();
// }
//
// class _ProgressPerSprintState extends State<ProgressPerSprint> {
//   late Future<ProgressPerSprintResponse> _future;
//
//   @override
//   void initState() {
//     super.initState();
//     _future = getProgressDashboard(widget.projectKey);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<ProgressPerSprintResponse>(
//       future: _future,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Padding(
//             padding: EdgeInsets.all(8.0),
//             child: Text('Loading...', style: TextStyle(color: Colors.grey)),
//           );
//         }
//
//         if (snapshot.hasError || snapshot.data == null || snapshot.data!.data == null) {
//           return const Padding(
//             padding: EdgeInsets.all(8.0),
//             child: Text('Error loading progress data'),
//           );
//         }
//
//         final progressList = snapshot.data!.data!;
//
//         return Padding(
//           // padding: const EdgeInsets.all(16.0),
//           padding: const EdgeInsets.only(top: 16.0),
//           child: Card(
//             elevation: 2,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Progress per Sprint',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   ...progressList.asMap().entries.map((entry) {
//                     final index = entry.key;
//                     final item = entry.value;
//
//                     return Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 6.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Expanded(
//                                 child: Text(
//                                   '${index + 1}. ${item.sprintName}',
//                                   overflow: TextOverflow.ellipsis,
//                                   style: const TextStyle(fontSize: 14),
//                                 ),
//                               ),
//                               Text(
//                                 '${item.percentComplete.toStringAsFixed(0)}%',
//                                 style: const TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w500,
//                                   color: Colors.teal,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 4),
//                           ClipRRect(
//                             borderRadius: BorderRadius.circular(4),
//                             child: LinearProgressIndicator(
//                               value: (item.percentComplete.clamp(0, 100)) / 100,
//                               backgroundColor: Colors.grey[300],
//                               color: Colors.teal[400],
//                               minHeight: 8,
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   }).toList(),
//                 ],
//               ),
//             ),
//           ),
//         );
//
//
//         // return Padding(
//         //   padding: const EdgeInsets.all(12.0),
//         //   child: Column(
//         //     children: progressList.asMap().entries.map((entry) {
//         //       final index = entry.key;
//         //       final item = entry.value;
//         //
//         //       return Padding(
//         //         padding: const EdgeInsets.symmetric(vertical: 6.0),
//         //         child: Column(
//         //           crossAxisAlignment: CrossAxisAlignment.start,
//         //           children: [
//         //             Row(
//         //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         //               children: [
//         //                 Expanded(
//         //                   child: Text(
//         //                     '${index + 1}. ${item.sprintName}',
//         //                     overflow: TextOverflow.ellipsis,
//         //                     style: const TextStyle(fontSize: 14),
//         //                   ),
//         //                 ),
//         //                 Text(
//         //                   '${item.percentComplete.toStringAsFixed(0)}%',
//         //                   style: const TextStyle(
//         //                     fontSize: 14,
//         //                     fontWeight: FontWeight.w500,
//         //                     color: Colors.teal,
//         //                   ),
//         //                 ),
//         //               ],
//         //             ),
//         //             const SizedBox(height: 4),
//         //             ClipRRect(
//         //               borderRadius: BorderRadius.circular(4),
//         //               child: LinearProgressIndicator(
//         //                 value: (item.percentComplete.clamp(0, 100)) / 100,
//         //                 backgroundColor: Colors.grey[300],
//         //                 color: Colors.teal[400],
//         //                 minHeight: 8,
//         //               ),
//         //             ),
//         //           ],
//         //         ),
//         //       );
//         //     }).toList(),
//         //   ),
//         // );
//       },
//     );
//   }
// }
//
// class ProgressPerSprintItem {
//   final String sprintName;
//   final double percentComplete;
//
//   ProgressPerSprintItem({
//     required this.sprintName,
//     required this.percentComplete,
//   });
//
//   factory ProgressPerSprintItem.fromJson(Map<String, dynamic> json) {
//     return ProgressPerSprintItem(
//       sprintName: json['sprintName'] ?? '',
//       percentComplete: (json['percentComplete'] ?? 0).toDouble(),
//     );
//   }
// }
//
// class ProgressPerSprintResponse {
//   final List<ProgressPerSprintItem>? data;
//
//   ProgressPerSprintResponse({required this.data});
//
//   factory ProgressPerSprintResponse.fromJson(List<dynamic> jsonList) {
//     return ProgressPerSprintResponse(
//       data: jsonList.map((e) => ProgressPerSprintItem.fromJson(e)).toList(),
//     );
//   }
// }
//
// Future<ProgressPerSprintResponse> getProgressDashboard(String projectKey) async {
//   final url = UriHelper.build('/projectmetric/progress-dashboard?projectKey=$projectKey');
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
//     final List<dynamic> jsonData = json.decode(response.body)['data'];
//     return ProgressPerSprintResponse.fromJson(jsonData);
//   } else {
//     throw Exception('Failed to load progress dashboard');
//   }
// }

import 'package:flutter/material.dart';
import 'Dashboard.dart'; // Import ProgressDashboardResponse and ProgressItem

class ProgressPerSprint extends StatelessWidget {
  final ProgressDashboardResponse data;
  final bool isLoading;

  const ProgressPerSprint({super.key, required this.data, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Text(
        'Loading...',
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey,
        ),
      );
    }
    if (!data.isSuccess || data.data.isEmpty) {
      return const Text(
        'There are currently no sprints with progress.',
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0), // Matches p-4
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: data.data.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0), // Matches space-y-2
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 2, // Matches w-2/3
                      child: Text(
                        '${index + 1}. ${item.sprintName}',
                        style: const TextStyle(
                          fontSize: 14, // Matches text-sm
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis, // Matches truncate
                      ),
                    ),
                    Text(
                      '${item.percentComplete.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 14, // Matches text-sm
                        fontWeight: FontWeight.w500, // Matches font-medium
                        color: Color(0xFF14B8A6), // Matches text-teal-500
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4), // Matches mb-1
                Container(
                  height: 8, // Matches h-2 (2 * 4 for pixel density)
                  decoration: BoxDecoration(
                    color: Colors.grey[200], // Matches bg-gray-200
                    borderRadius: BorderRadius.circular(4), // Matches rounded
                  ),
                  child: LinearProgressIndicator(
                    value: item.percentComplete / 100.0, // Matches width: min(percentComplete, 100)
                    backgroundColor: Colors.transparent,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF2DD4BF), // Matches bg-teal-400
                    ),
                    borderRadius: BorderRadius.circular(4), // Matches rounded
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
