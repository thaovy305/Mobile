// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../Helper/UriHelper.dart';
// import 'RiskPage.dart';
//
// class RiskDetailPage extends StatefulWidget {
//   final RiskItem risk;
//
//   const RiskDetailPage({super.key, required this.risk});
//
//   @override
//   State<RiskDetailPage> createState() => _RiskDetailPageState();
// }
//
// class _RiskDetailPageState extends State<RiskDetailPage> {
//   late String selectedStatus;
//   late String selectedType;
//   late Future<List<DynamicCategory>> riskTypesFuture;
//   List<RiskSolutionItem> riskSolutions = [];
//   bool isRiskSolutionLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     selectedStatus = widget.risk.status;
//     selectedType = widget.risk.type;
//     riskTypesFuture = fetchRiskTypes();
//     fetchRiskSolution();
//   }
//
//   Future<void> updateStatus(String newStatus) async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('accessToken') ?? '';
//
//     final int riskId = widget.risk.id;
//     final url = UriHelper.build('/risk/$riskId/status');
//
//     try {
//       final response = await http.patch(
//         url,
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//         body: jsonEncode(newStatus),
//       );
//
//       if (response.statusCode == 200) {
//         setState(() {
//           selectedStatus = newStatus;
//         });
//
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Đã cập nhật trạng thái thành $newStatus')),
//         );
//       } else {
//         throw Exception('Failed to update status');
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Cập nhật thất bại')));
//       print('Error updating status: $e');
//     }
//   }
//
//   Future<List<DynamicCategory>> fetchRiskTypes() async {
//     String categoryGroup = 'risk_type';
//     final url = UriHelper.build(
//       '/dynamiccategory/by-category-group?categoryGroup=$categoryGroup',
//     );
//
//     final response = await http.get(url);
//
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       return (data['data'] as List)
//           .map((item) => DynamicCategory.fromJson(item))
//           .toList();
//     } else {
//       throw Exception('Failed to load risk types');
//     }
//   }
//
//   Future<void> updateRiskType(int riskId, String newType) async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('accessToken') ?? '';
//
//     final url = UriHelper.build('/risk/$riskId/type');
//     final response = await http.patch(
//       url,
//       headers: {
//         'Authorization': 'Bearer $token',
//         'Content-Type': 'application/json',
//       },
//       body: jsonEncode(newType),
//     );
//
//     if (response.statusCode != 200) {
//       throw Exception('Failed to update risk type');
//     }
//   }
//
//   String formatDate(String? dateStr) {
//     if (dateStr == null || dateStr.isEmpty) return "Không rõ";
//     try {
//       final date = DateTime.parse(dateStr);
//       return DateFormat('dd/MM/yyyy').format(date);
//     } catch (_) {
//       return "Không hợp lệ";
//     }
//   }
//
//   Widget buildInfoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
//           Expanded(child: Text(value)),
//         ],
//       ),
//     );
//   }
//
//   Widget buildStatusDropdown() {
//     return DropdownButton<String>(
//       value: selectedStatus,
//       onChanged: (value) {
//         if (value != null) updateStatus(value);
//       },
//       underline: Container(),
//       style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
//       dropdownColor: Colors.white,
//       borderRadius: BorderRadius.circular(8),
//       items:
//           ['OPEN', 'MITIGATED', 'CLOSED'].map((status) {
//             return DropdownMenuItem<String>(
//               value: status,
//               child: Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 8,
//                       vertical: 4,
//                     ),
//                     decoration: BoxDecoration(
//                       color: statusColors[status]?.withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(6),
//                     ),
//                     child: Text(
//                       status,
//                       style: TextStyle(
//                         color: statusColors[status],
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }).toList(),
//     );
//   }
//
//   Map<String, Color> statusColors = {
//     'OPEN': Colors.blue,
//     'MITIGATED': Colors.green,
//     'CLOSED': Colors.grey,
//   };
//
//   Widget buildInfoRowWithAvatar(
//     String label,
//     String? fullName,
//     String? username,
//     String? pictureUrl,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           SizedBox(
//             width: 150,
//             child: Text(
//               "$label:",
//               style: const TextStyle(fontWeight: FontWeight.bold),
//             ),
//           ),
//           CircleAvatar(
//             radius: 18,
//             backgroundImage:
//                 pictureUrl != null && pictureUrl.isNotEmpty
//                     ? NetworkImage(pictureUrl)
//                     : null,
//             child:
//                 (pictureUrl == null || pictureUrl.isEmpty)
//                     ? const Icon(Icons.person, size: 18)
//                     : null,
//           ),
//           const SizedBox(width: 8),
//           Expanded(child: Text(fullName ?? username ?? 'Not assigned')),
//         ],
//       ),
//     );
//   }
//
//   Color getLevelColor(String level) {
//     switch (level.toLowerCase()) {
//       case "low":
//         return Colors.green;
//       case "medium":
//         return Colors.orange;
//       case "high":
//         return Colors.red;
//       default:
//         return Colors.grey;
//     }
//   }
//
//   Widget buildLevelLabel(String title, String value) {
//     final displayValue = value.isNotEmpty ? value : "Unknown";
//     final color = getLevelColor(displayValue);
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//         ),
//         const SizedBox(height: 6),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.2),
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Text(
//             displayValue,
//             style: TextStyle(color: color, fontWeight: FontWeight.bold),
//           ),
//         ),
//         const SizedBox(height: 24),
//       ],
//     );
//   }
//
//   Future<void> fetchRiskSolution() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('accessToken') ?? '';
//
//     final uri = UriHelper.build('/risksolution/by-risk/${widget.risk.id}');
//     try {
//       final response = await http.get(
//         uri,
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//       );
//
//       if (response.statusCode == 200) {
//         final decoded = json.decode(response.body);
//         final data = decoded['data'];
//         if (data != null && data is List) {
//           setState(() {
//             riskSolutions =
//                 data.map((item) => RiskSolutionItem.fromJson(item)).toList();
//             isRiskSolutionLoading = false;
//           });
//         } else {
//           setState(() {
//             isRiskSolutionLoading = false;
//           });
//         }
//       } else {
//         setState(() {
//           isRiskSolutionLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         isRiskSolutionLoading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final String createdBy =
//         widget.risk.creatorFullName ?? widget.risk.creatorUserName ?? 'Unknown';
//     final String responsible =
//         widget.risk.responsibleFullName ??
//         widget.risk.responsibleUserName ??
//         'Not assigned';
//     final String dueDate = formatDate(widget.risk.dueDate);
//     final String createdAt = formatDate(widget.risk.createdAt);
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.risk.title),
//         backgroundColor: Colors.redAccent,
//       ),
//       body: Container(
//         padding: const EdgeInsets.all(16.0),
//         color: Colors.grey[50],
//         child: SingleChildScrollView(
//           child: Card(
//             elevation: 2,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             margin: const EdgeInsets.only(bottom: 24),
//             child: Padding(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Wrap(
//                     spacing: 8,
//                     runSpacing: 4,
//                     children: [Chip(label: Text(widget.risk.riskKey))],
//                   ),
//                   Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       const Text(
//                         "Status: ",
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                       buildStatusDropdown(),
//                     ],
//                   ),
//                   FutureBuilder<List<DynamicCategory>>(
//                     future: riskTypesFuture,
//                     builder: (context, snapshot) {
//                       if (snapshot.connectionState == ConnectionState.waiting) {
//                         return const CircularProgressIndicator();
//                       } else if (snapshot.hasError) {
//                         return const Text("Failed to load risk type");
//                       } else {
//                         final types = snapshot.data!;
//                         return DropdownButton<String>(
//                           value: selectedType,
//                           onChanged: (newType) async {
//                             if (newType != null && newType != selectedType) {
//                               try {
//                                 await updateRiskType(widget.risk.id, newType);
//                                 setState(() {
//                                   selectedType = newType;
//                                 });
//                               } catch (e) {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   const SnackBar(
//                                     content: Text('Failed to update type'),
//                                   ),
//                                 );
//                               }
//                             }
//                           },
//                           items:
//                               types
//                                   .map(
//                                     (type) => DropdownMenuItem(
//                                       value: type.name,
//                                       child: Text(type.label),
//                                     ),
//                                   )
//                                   .toList(),
//                         );
//                       }
//                     },
//                   ),
//
//                   const Divider(height: 32),
//                   buildInfoRowWithAvatar(
//                     "Created by",
//                     widget.risk.creatorFullName,
//                     widget.risk.creatorUserName,
//                     widget.risk.creatorPicture,
//                   ),
//                   buildInfoRowWithAvatar(
//                     "Responsible",
//                     widget.risk.responsibleFullName,
//                     widget.risk.responsibleUserName,
//                     widget.risk.responsiblePicture,
//                   ),
//                   buildInfoRow("Due date", dueDate),
//                   buildInfoRow("Created at", createdAt),
//
//                   const SizedBox(height: 24),
//                   const Text(
//                     "Description",
//                     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                   ),
//                   const SizedBox(height: 6),
//                   Text(
//                     widget.risk.description.isNotEmpty
//                         ? widget.risk.description
//                         : "No description provided.",
//                   ),
//
//                   const SizedBox(height: 24),
//                   const Text(
//                     "Scope",
//                     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                   ),
//                   const SizedBox(height: 6),
//                   Text(
//                     widget.risk.riskScope.isNotEmpty
//                         ? widget.risk.riskScope
//                         : "No information.",
//                   ),
//
//                   const SizedBox(height: 24),
//                   buildLevelLabel("Probability", widget.risk.probability),
//                   buildLevelLabel("Impact Level", widget.risk.impactLevel),
//                   buildLevelLabel("Severity Level", widget.risk.severityLevel),
//
//                   if (isRiskSolutionLoading)
//                     const CircularProgressIndicator()
//                   else if (riskSolutions.isNotEmpty)
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const SizedBox(height: 24),
//                         const Text(
//                           "Mitigation Plan",
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16,
//                           ),
//                         ),
//                         const SizedBox(height: 6),
//                         ...riskSolutions
//                             .map(
//                               (solution) => Padding(
//                                 padding: const EdgeInsets.only(bottom: 12),
//                                 child: Text(
//                                   solution.mitigationPlan?.isNotEmpty == true
//                                       ? solution.mitigationPlan!
//                                       : "Not provided",
//                                 ),
//                               ),
//                             )
//                             .toList(),
//
//                         const SizedBox(height: 24),
//                         const Text(
//                           "Contingency Plan",
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16,
//                           ),
//                         ),
//                         const SizedBox(height: 6),
//                         ...riskSolutions
//                             .map(
//                               (solution) => Padding(
//                                 padding: const EdgeInsets.only(bottom: 12),
//                                 child: Text(
//                                   solution.contingencyPlan?.isNotEmpty == true
//                                       ? solution.contingencyPlan!
//                                       : "Not provided",
//                                 ),
//                               ),
//                             )
//                             .toList(),
//                       ],
//                     )
//                   else
//                     const SizedBox.shrink(),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class DynamicCategory {
//   final int id;
//   final String name;
//   final String label;
//
//   DynamicCategory({required this.id, required this.name, required this.label});
//
//   factory DynamicCategory.fromJson(Map<String, dynamic> json) {
//     return DynamicCategory(
//       id: json['id'],
//       name: json['name'],
//       label: json['label'],
//     );
//   }
// }
//
// class RiskSolutionItem {
//   final int id;
//   final int riskId;
//   final String? mitigationPlan;
//   final String? contingencyPlan;
//   final String createdAt;
//   final String updatedAt;
//
//   RiskSolutionItem({
//     required this.id,
//     required this.riskId,
//     this.mitigationPlan,
//     this.contingencyPlan,
//     required this.createdAt,
//     required this.updatedAt,
//   });
//
//   factory RiskSolutionItem.fromJson(Map<String, dynamic> json) {
//     return RiskSolutionItem(
//       id: json['id'],
//       riskId: json['riskId'],
//       mitigationPlan: json['mitigationPlan'],
//       contingencyPlan: json['contingencyPlan'],
//       createdAt: json['createdAt'],
//       updatedAt: json['updatedAt'],
//     );
//   }
// }


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';

import '../../Helper/UriHelper.dart';
import 'RiskPage.dart';

class RiskSolutionItem {
  final int id;
  final int riskId;
  final String? mitigationPlan;
  final String? contingencyPlan;
  final String createdAt;
  final String updatedAt;

  RiskSolutionItem({
    required this.id,
    required this.riskId,
    this.mitigationPlan,
    this.contingencyPlan,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RiskSolutionItem.fromJson(Map<String, dynamic> json) {
    return RiskSolutionItem(
      id: json['id'] ?? 0,
      riskId: json['riskId'] ?? 0,
      mitigationPlan: json['mitigationPlan'],
      contingencyPlan: json['contingencyPlan'],
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}

class RiskFileItem {
  final int id;
  final int riskId;
  final String fileName;
  final String fileUrl;
  final String uploadedAt;

  RiskFileItem({
    required this.id,
    required this.riskId,
    required this.fileName,
    required this.fileUrl,
    required this.uploadedAt,
  });

  factory RiskFileItem.fromJson(Map<String, dynamic> json) {
    return RiskFileItem(
      id: json['id'] ?? 0,
      riskId: json['riskId'] ?? 0,
      fileName: json['fileName'] ?? '',
      fileUrl: json['fileUrl'] ?? '',
      uploadedAt: json['uploadedAt'] ?? '',
    );
  }
}

class RiskCommentItem {
  final int id;
  final int riskId;
  final int accountId;
  final String? accountFullName;
  final String? accountUserName;
  final String? accountPicture;
  final String comment;
  final String createdAt;

  RiskCommentItem({
    required this.id,
    required this.riskId,
    required this.accountId,
    this.accountFullName,
    this.accountUserName,
    this.accountPicture,
    required this.comment,
    required this.createdAt,
  });

  factory RiskCommentItem.fromJson(Map<String, dynamic> json) {
    return RiskCommentItem(
      id: json['id'] ?? 0,
      riskId: json['riskId'] ?? 0,
      accountId: json['accountId'] ?? 0,
      accountFullName: json['accountFullName'],
      accountUserName: json['accountUserName'],
      accountPicture: json['accountPicture'],
      comment: json['comment'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }
}

class ActivityLogItem {
  final int id;
  final int createdBy;
  final String? createdByName;
  final String message;
  final String createdAt;

  ActivityLogItem({
    required this.id,
    required this.createdBy,
    this.createdByName,
    required this.message,
    required this.createdAt,
  });

  factory ActivityLogItem.fromJson(Map<String, dynamic> json) {
    return ActivityLogItem(
      id: json['id'] ?? 0,
      createdBy: json['createdBy'] ?? 0,
      createdByName: json['createdByName'],
      message: json['message'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }
}

class RiskDetailPage extends StatefulWidget {
  final RiskItem risk;
  final String projectKey;

  const RiskDetailPage({super.key, required this.risk, required this.projectKey});

  @override
  State<RiskDetailPage> createState() => _RiskDetailPageState();
}

class _RiskDetailPageState extends State<RiskDetailPage> {
  late RiskItem editableRisk;
  late Future<List<DynamicCategory>> riskTypesFuture;
  late Future<List<DynamicCategory>> impactCategoriesFuture;
  late Future<List<DynamicCategory>> probabilityCategoriesFuture;
  late Future<List<Assignee>> assigneesFuture;
  List<RiskSolutionItem> riskSolutions = [];
  List<RiskFileItem> riskFiles = [];
  List<RiskCommentItem> riskComments = [];
  List<ActivityLogItem> activityLogs = [];
  bool isRiskSolutionLoading = true;
  bool isRiskFilesLoading = true;
  bool isRiskCommentsLoading = true;
  bool isActivityLogsLoading = true;
  String newMitigation = '';
  String newContingency = '';
  String newComment = '';
  int? editIndexMitigation;
  String editTextMitigation = '';
  int? editIndexContingency;
  String editTextContingency = '';
  int? editingCommentId;
  String editedCommentContent = '';
  int? currentAccountId;

  @override
  void initState() {
    super.initState();
    editableRisk = widget.risk;
    riskTypesFuture = fetchRiskTypes();
    impactCategoriesFuture = fetchCategories('risk_impact_level');
    probabilityCategoriesFuture = fetchCategories('risk_probability_level');
    assigneesFuture = fetchAssignees();
    fetchRiskSolution();
    fetchRiskFiles();
    fetchRiskComments();
    fetchActivityLogs();
    fetchCurrentAccountId();
  }

  Future<void> fetchCurrentAccountId() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      final user = json.decode(userJson);
      setState(() {
        currentAccountId = user['id'];
      });
    }
  }

  Future<List<DynamicCategory>> fetchRiskTypes() async {
    return fetchCategories('risk_type');
  }

  Future<List<DynamicCategory>> fetchCategories(String categoryGroup) async {
    final url = UriHelper.build('/dynamiccategory/by-category-group?categoryGroup=$categoryGroup');
    print('Fetching categories for $categoryGroup: $url');
    final response = await http.get(url);
    print('Categories response status: ${response.statusCode}');
    print('Categories response body: ${response.body}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> categories = data['data'];
      // Remove duplicates by name, keeping the first occurrence
      final seenNames = <String>{};
      final uniqueCategories = categories.where((item) {
        final name = item['name'] as String? ?? '';
        if (seenNames.contains(name)) return false;
        seenNames.add(name);
        return true;
      }).toList();
      return uniqueCategories.map((item) => DynamicCategory.fromJson(item)).toList();
    }
    throw Exception('Failed to load $categoryGroup');
  }

  Future<List<Assignee>> fetchAssignees() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';
    final projectResponse = await http.get(
      UriHelper.build('/project/by-key?projectKey=${widget.projectKey}'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (projectResponse.statusCode != 200) throw Exception('Failed to load project');
    final projectId = json.decode(projectResponse.body)['data']['id'];

    final response = await http.get(
      UriHelper.build('/project/$projectId/projectmember/with-positions'),
      headers: {'Authorization': 'Bearer $token'},
    );
    print('Assignees response status: ${response.statusCode}');
    print('Assignees response body: ${response.body}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['data'] as List).map((m) => Assignee(
        id: m['accountId'] ?? 0,
        fullName: m['fullName'],
        userName: m['username'] ?? '',
        picture: m['picture'],
      )).toList();
    }
    throw Exception('Failed to load assignees');
  }

  Future<void> fetchRiskSolution() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';
    final uri = UriHelper.build('/risksolution/by-risk/${widget.risk.id}');
    print('Fetching risk solutions: $uri');
    try {
      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      });
      print('Risk solutions response status: ${response.statusCode}');
      print('Risk solutions response body: ${response.body}');
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final data = decoded['data'];
        setState(() {
          riskSolutions = data != null
              ? (data as List).map((item) => RiskSolutionItem.fromJson(item)).toList()
              : [];
          isRiskSolutionLoading = false;
        });
      } else {
        setState(() {
          isRiskSolutionLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isRiskSolutionLoading = false;
      });
      print('Error fetching risk solutions: $e');
    }
  }

  Future<void> fetchRiskFiles() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';
    final uri = UriHelper.build('/riskfile/by-risk/${widget.risk.id}');
    print('Fetching risk files: $uri');
    try {
      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      });
      print('Risk files response status: ${response.statusCode}');
      print('Risk files response body: ${response.body}');
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final data = decoded['data'];
        setState(() {
          riskFiles = data != null
              ? (data as List).map((item) => RiskFileItem.fromJson(item)).toList()
              : [];
          isRiskFilesLoading = false;
        });
      } else {
        setState(() {
          isRiskFilesLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isRiskFilesLoading = false;
      });
      print('Error fetching risk files: $e');
    }
  }

  Future<void> fetchRiskComments() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';
    final uri = UriHelper.build('/riskcomment/by-risk/${widget.risk.id}');
    print('Fetching risk comments: $uri');
    try {
      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      });
      print('Risk comments response status: ${response.statusCode}');
      print('Risk comments response body: ${response.body}');
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final data = decoded['data'];
        setState(() {
          riskComments = data != null
              ? (data as List).map((item) => RiskCommentItem.fromJson(item)).toList()
              : [];
          isRiskCommentsLoading = false;
        });
      } else {
        setState(() {
          isRiskCommentsLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isRiskCommentsLoading = false;
      });
      print('Error fetching risk comments: $e');
    }
  }

  Future<void> fetchActivityLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';
    final uri = UriHelper.build('/activitylog/risk/${widget.risk.riskKey}');
    print('Fetching activity logs: $uri');
    try {
      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      });
      print('Activity logs response status: ${response.statusCode}');
      print('Activity logs response body: ${response.body}');
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final data = decoded['data'];
        setState(() {
          activityLogs = data != null
              ? (data as List).map((item) => ActivityLogItem.fromJson(item)).toList()
              : [];
          isActivityLogsLoading = false;
        });
      } else {
        setState(() {
          isActivityLogsLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isActivityLogsLoading = false;
      });
      print('Error fetching activity logs: $e');
    }
  }

  Future<void> updateRiskField(String endpoint, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';
    final url = UriHelper.build('/risk/${widget.risk.id}/$endpoint');
    print('Updating risk field: $url with value: $value');
    try {
      final response = await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(value),
      );
      print('Update response status: ${response.statusCode}');
      print('Update response body: ${response.body}');
      if (response.statusCode == 200) {
        final updatedData = json.decode(response.body)['data'];
        setState(() {
          if (endpoint == 'title') editableRisk.title = updatedData['title'] ?? editableRisk.title;
          if (endpoint == 'status') editableRisk.status = updatedData['status'] ?? editableRisk.status;
          if (endpoint == 'type') editableRisk.type = updatedData['type'] ?? editableRisk.type;
          if (endpoint == 'responsible') {
            editableRisk.responsibleId = updatedData['responsibleId'] ?? editableRisk.responsibleId;
            editableRisk.responsibleFullName = updatedData['responsibleFullName'];
            editableRisk.responsibleUserName = updatedData['responsibleUserName'];
            editableRisk.responsiblePicture = updatedData['responsiblePicture'];
          }
          if (endpoint == 'dueDate') editableRisk.dueDate = updatedData['dueDate'];
          if (endpoint == 'description') editableRisk.description = updatedData['description'] ?? editableRisk.description;
          if (endpoint == 'impactLevel') {
            editableRisk.impactLevel = updatedData['impactLevel'] ?? editableRisk.impactLevel;
            editableRisk.severityLevel = updatedData['severityLevel'] ?? editableRisk.severityLevel;
          }
          if (endpoint == 'probability') {
            editableRisk.probability = updatedData['probability'] ?? editableRisk.probability;
            editableRisk.severityLevel = updatedData['severityLevel'] ?? editableRisk.severityLevel;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cập nhật $endpoint thành công')),
        );
      } else {
        throw Exception('Failed to update $endpoint: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cập nhật $endpoint thất bại')),
      );
      print('Error updating $endpoint: $e');
    }
  }

  Future<void> createRiskSolution({String? mitigationPlan, String? contingencyPlan}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';
    final url = UriHelper.build('/risksolution');
    print('Creating risk solution: $url');
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'riskId': widget.risk.id,
          'mitigationPlan': mitigationPlan,
          'contingencyPlan': contingencyPlan,
          'createdBy': currentAccountId,
        }),
      );
      print('Create risk solution response status: ${response.statusCode}');
      print('Create risk solution response body: ${response.body}');
      if (response.statusCode == 200) {
        await fetchRiskSolution();
        await fetchActivityLogs();
      } else {
        throw Exception('Failed to create risk solution: ${response.statusCode}');
      }
    } catch (e) {
      print('Error creating risk solution: $e');
    }
  }

  Future<void> updateRiskSolution(int id, {String? mitigationPlan, String? contingencyPlan}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';
    final url = UriHelper.build('/risksolution/$id/${mitigationPlan != null ? 'mitigation' : 'contingency'}');
    print('Updating risk solution: $url');
    try {
      final response = await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(mitigationPlan ?? contingencyPlan),
      );
      print('Update risk solution response status: ${response.statusCode}');
      print('Update risk solution response body: ${response.body}');
      if (response.statusCode == 200) {
        await fetchRiskSolution();
        await fetchActivityLogs();
      } else {
        throw Exception('Failed to update risk solution: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating risk solution: $e');
    }
  }

  Future<void> deleteRiskSolution(int id, String type) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';
    final url = UriHelper.build('/risksolution/$id/$type');
    print('Deleting risk solution: $url');
    try {
      final response = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      print('Delete risk solution response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        await fetchRiskSolution();
        await fetchActivityLogs();
      } else {
        throw Exception('Failed to delete $type: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting $type: $e');
    }
  }

  Future<void> uploadRiskFile(PlatformFile file) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';
    final url = UriHelper.build('/riskfile');
    print('Uploading risk file: $url');
    try {
      final request = http.MultipartRequest('POST', url)
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['riskId'] = widget.risk.id.toString()
        ..fields['fileName'] = file.name
        ..fields['uploadedBy'] = currentAccountId.toString()
        ..files.add(http.MultipartFile.fromBytes('file', file.bytes!, filename: file.name));
      final response = await request.send();
      print('Upload risk file response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã tải lên file ${file.name}')),
        );
        await fetchRiskFiles();
        await fetchActivityLogs();
      } else {
        throw Exception('Failed to upload file: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tải file thất bại')),
      );
      print('Error uploading file: $e');
    }
  }

  Future<void> deleteRiskFile(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';
    final url = UriHelper.build('/riskfile/$id');
    print('Deleting risk file: $url');
    try {
      final response = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      print('Delete risk file response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa file')),
        );
        await fetchRiskFiles();
        await fetchActivityLogs();
      } else {
        throw Exception('Failed to delete file: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Xóa file thất bại')),
      );
      print('Error deleting file: $e');
    }
  }

  Future<void> createRiskComment(String comment) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';
    final url = UriHelper.build('/riskcomment');
    print('Creating risk comment: $url');
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'riskId': widget.risk.id,
          'accountId': currentAccountId,
          'comment': comment,
        }),
      );
      print('Create risk comment response status: ${response.statusCode}');
      print('Create risk comment response body: ${response.body}');
      if (response.statusCode == 200) {
        await fetchRiskComments();
        await fetchActivityLogs();
      } else {
        throw Exception('Failed to create comment: ${response.statusCode}');
      }
    } catch (e) {
      print('Error creating comment: $e');
    }
  }

  Future<void> updateRiskComment(int id, String comment) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';
    final url = UriHelper.build('/riskcomment/$id');
    print('Updating risk comment: $url');
    try {
      final response = await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'riskId': widget.risk.id,
          'accountId': currentAccountId,
          'comment': comment,
        }),
      );
      print('Update risk comment response status: ${response.statusCode}');
      print('Update risk comment response body: ${response.body}');
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã cập nhật bình luận')),
        );
        await fetchRiskComments();
        await fetchActivityLogs();
      } else {
        throw Exception('Failed to update comment: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật bình luận thất bại')),
      );
      print('Error updating comment: $e');
    }
  }

  Future<void> deleteRiskComment(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';
    final url = UriHelper.build('/riskcomment/$id');
    print('Deleting risk comment: $url');
    try {
      final response = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      print('Delete risk comment response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa bình luận')),
        );
        await fetchRiskComments();
        await fetchActivityLogs();
      } else {
        throw Exception('Failed to delete comment: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Xóa bình luận thất bại')),
      );
      print('Error deleting comment: $e');
    }
  }

  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "Không rõ";
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (_) {
      return "Không hợp lệ";
    }
  }

  Color getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case "low":
        return Colors.green;
      case "medium":
        return Colors.orange;
      case "high":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget buildInfoRowWithAvatar(String label, String? fullName, String? username, String? pictureUrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          CircleAvatar(
            radius: 18,
            backgroundImage: pictureUrl != null && pictureUrl.isNotEmpty ? NetworkImage(pictureUrl) : null,
            child: pictureUrl == null || pictureUrl.isEmpty ? const Icon(Icons.person, size: 18) : null,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(fullName ?? username ?? 'Không phân công')),
        ],
      ),
    );
  }

  Widget buildLevelLabel(String title, String value) {
    final displayValue = value.isNotEmpty ? value : "Không rõ";
    final color = getLevelColor(displayValue);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            displayValue,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final String createdBy = editableRisk.creatorFullName ?? editableRisk.creatorUserName ?? 'Không rõ';
    final String responsible = editableRisk.responsibleFullName ?? editableRisk.responsibleUserName ?? 'Không phân công';
    final String dueDate = formatDate(editableRisk.dueDate);
    final String createdAt = formatDate(editableRisk.createdAt);

    return Scaffold(
      appBar: AppBar(
        title: Text(editableRisk.title),
        backgroundColor: Colors.redAccent,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        color: Colors.grey[50],
        child: SingleChildScrollView(
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.only(bottom: 24),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [Chip(label: Text(editableRisk.riskKey))],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: TextEditingController(text: editableRisk.title),
                    decoration: const InputDecoration(
                      labelText: 'Tiêu đề',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => setState(() => editableRisk.title = value),
                    onSubmitted: (value) => updateRiskField('title', value),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text("Trạng thái: ", style: TextStyle(fontWeight: FontWeight.bold)),
                      Expanded(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: editableRisk.status,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => editableRisk.status = value);
                              updateRiskField('status', value);
                            }
                          },
                          items: ['OPEN', 'MITIGATED', 'CLOSED'].map((status) {
                            return DropdownMenuItem<String>(
                              value: status,
                              child: Text(status),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<List<DynamicCategory>>(
                    future: riskTypesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return const Text("Không tải được loại rủi ro");
                      }
                      final types = snapshot.data!;
                      return Row(
                        children: [
                          const Text("Loại: ", style: TextStyle(fontWeight: FontWeight.bold)),
                          Expanded(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: editableRisk.type,
                              onChanged: (value) {
                                if (value != null && value != editableRisk.type) {
                                  setState(() => editableRisk.type = value);
                                  updateRiskField('type', value);
                                }
                              },
                              items: types.map((type) => DropdownMenuItem(
                                value: type.name,
                                child: Text(type.label),
                              )).toList(),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<List<Assignee>>(
                    future: assigneesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return const Text("Không tải được danh sách người phụ trách");
                      }
                      final assignees = snapshot.data!;
                      return Row(
                        children: [
                          const Text("Người phụ trách: ", style: TextStyle(fontWeight: FontWeight.bold)),
                          Expanded(
                            child: DropdownButton<int>(
                              isExpanded: true,
                              value: editableRisk.responsibleId,
                              onChanged: (value) {
                                final selected = assignees.firstWhere((a) => a.id == value, orElse: () => Assignee(id: 0, fullName: null, userName: 'Không phân công', picture: null));
                                setState(() {
                                  editableRisk.responsibleId = value ?? 0;
                                  editableRisk.responsibleFullName = selected.fullName;
                                  editableRisk.responsibleUserName = selected.userName;
                                  editableRisk.responsiblePicture = selected.picture;
                                });
                                updateRiskField('responsible', value);
                              },
                              items: [
                                const DropdownMenuItem(value: 0, child: Text('Không phân công')),
                                ...assignees.map((user) => DropdownMenuItem(
                                  value: user.id,
                                  child: Text(user.fullName ?? user.userName),
                                )),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text("Ngày đáo hạn: ", style: TextStyle(fontWeight: FontWeight.bold)),
                      Expanded(
                        child: TextFormField(
                          initialValue: editableRisk.dueDate?.split('T')[0] ?? '',
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Chọn ngày',
                          ),
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (date != null) {
                              final newDate = DateFormat('yyyy-MM-dd').format(date) + 'T00:00:00Z';
                              setState(() => editableRisk.dueDate = newDate);
                              updateRiskField('dueDate', newDate);
                            }
                          },
                          readOnly: true,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  buildInfoRowWithAvatar(
                    "Người tạo",
                    editableRisk.creatorFullName,
                    editableRisk.creatorUserName,
                    editableRisk.creatorPicture,
                  ),
                  buildInfoRow("Ngày tạo", createdAt),
                  const SizedBox(height: 24),
                  const Text(
                    "Mô tả",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: TextEditingController(text: editableRisk.description),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Nhập mô tả',
                    ),
                    maxLines: 4,
                    onChanged: (value) => setState(() => editableRisk.description = value),
                    onSubmitted: (value) => updateRiskField('description', value),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Phạm vi",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Text(editableRisk.riskScope.isNotEmpty ? editableRisk.riskScope : "Không có thông tin"),
                  const SizedBox(height: 24),
                  FutureBuilder<List<DynamicCategory>>(
                    future: impactCategoriesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return const Text("Không tải được mức độ ảnh hưởng");
                      }
                      final categories = snapshot.data!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Mức độ ảnh hưởng",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 6),
                          ...categories.map((category) => RadioListTile<String>(
                            title: Text(category.label),
                            value: category.name,
                            groupValue: editableRisk.impactLevel,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => editableRisk.impactLevel = value);
                                updateRiskField('impactLevel', value);
                              }
                            },
                          )),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  FutureBuilder<List<DynamicCategory>>(
                    future: probabilityCategoriesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return const Text("Không tải được xác suất");
                      }
                      final categories = snapshot.data!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Xác suất",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 6),
                          ...categories.map((category) => RadioListTile<String>(
                            title: Text(category.label),
                            value: category.name,
                            groupValue: editableRisk.probability,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => editableRisk.probability = value);
                                updateRiskField('probability', value);
                              }
                            },
                          )),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  buildLevelLabel("Mức độ nghiêm trọng", editableRisk.severityLevel),
                  const SizedBox(height: 24),
                  if (isRiskSolutionLoading)
                    const CircularProgressIndicator()
                  else if (riskSolutions.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Kế hoạch giảm thiểu",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 6),
                        ...riskSolutions.asMap().entries.map((entry) {
                          final index = entry.key;
                          final solution = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: editIndexMitigation == index
                                      ? TextField(
                                    controller: TextEditingController(text: editTextMitigation),
                                    onChanged: (value) => editTextMitigation = value,
                                    onSubmitted: (value) {
                                      updateRiskSolution(solution.id, mitigationPlan: value);
                                      setState(() => editIndexMitigation = null);
                                    },
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText: 'Nhập kế hoạch giảm thiểu',
                                    ),
                                  )
                                      : Text(
                                    solution.mitigationPlan?.isNotEmpty == true
                                        ? solution.mitigationPlan!
                                        : "Không có",
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(editIndexMitigation == index ? Icons.check : Icons.edit),
                                  onPressed: () {
                                    if (editIndexMitigation == index) {
                                      updateRiskSolution(solution.id, mitigationPlan: editTextMitigation);
                                      setState(() => editIndexMitigation = null);
                                    } else {
                                      setState(() {
                                        editIndexMitigation = index;
                                        editTextMitigation = solution.mitigationPlan ?? '';
                                      });
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => deleteRiskSolution(solution.id, 'mitigation'),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        TextField(
                          decoration: const InputDecoration(
                            hintText: 'Thêm kế hoạch giảm thiểu',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) => newMitigation = value,
                          onSubmitted: (value) {
                            if (value.trim().isNotEmpty) {
                              createRiskSolution(mitigationPlan: value.trim());
                              setState(() => newMitigation = '');
                            }
                          },
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          "Kế hoạch dự phòng",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 6),
                        ...riskSolutions.asMap().entries.map((entry) {
                          final index = entry.key;
                          final solution = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: editIndexContingency == index
                                      ? TextField(
                                    controller: TextEditingController(text: editTextContingency),
                                    onChanged: (value) => editTextContingency = value,
                                    onSubmitted: (value) {
                                      updateRiskSolution(solution.id, contingencyPlan: value);
                                      setState(() => editIndexContingency = null);
                                    },
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText: 'Nhập kế hoạch dự phòng',
                                    ),
                                  )
                                      : Text(
                                    solution.contingencyPlan?.isNotEmpty == true
                                        ? solution.contingencyPlan!
                                        : "Không có",
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(editIndexContingency == index ? Icons.check : Icons.edit),
                                  onPressed: () {
                                    if (editIndexContingency == index) {
                                      updateRiskSolution(solution.id, contingencyPlan: editTextContingency);
                                      setState(() => editIndexContingency = null);
                                    } else {
                                      setState(() {
                                        editIndexContingency = index;
                                        editTextContingency = solution.contingencyPlan ?? '';
                                      });
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => deleteRiskSolution(solution.id, 'contingency'),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        TextField(
                          decoration: const InputDecoration(
                            hintText: 'Thêm kế hoạch dự phòng',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) => newContingency = value,
                          onSubmitted: (value) {
                            if (value.trim().isNotEmpty) {
                              createRiskSolution(contingencyPlan: value.trim());
                              setState(() => newContingency = '');
                            }
                          },
                        ),
                      ],
                    ),
                  const SizedBox(height: 24),
                  const Text(
                    "Tệp đính kèm",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  if (isRiskFilesLoading)
                    const CircularProgressIndicator()
                  else if (riskFiles.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: riskFiles.map((file) {
                        return Container(
                          width: 100,
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Mở file không được hỗ trợ trong ứng dụng')),
                                ),
                                child: file.fileUrl.contains(RegExp(r'\.(jpg|jpeg|png|gif)$', caseSensitive: false))
                                    ? Image.network(file.fileUrl, height: 80, fit: BoxFit.cover)
                                    : Container(
                                  height: 80,
                                  color: Colors.grey[200],
                                  child: Center(
                                    child: Text(
                                      file.fileName.length > 10 ? '${file.fileName.substring(0, 10)}...' : file.fileName,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                              Text(file.fileName, maxLines: 1, overflow: TextOverflow.ellipsis),
                              Text(formatDate(file.uploadedAt), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => deleteRiskFile(file.id),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    )
                  else
                    const Text("Không có tệp đính kèm"),
                  ElevatedButton(
                    onPressed: () async {
                      final result = await FilePicker.platform.pickFiles();
                      if (result != null && result.files.isNotEmpty) {
                        await uploadRiskFile(result.files.first);
                      }
                    },
                    child: const Text('Tải lên tệp'),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Bình luận",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  if (isRiskCommentsLoading)
                    const CircularProgressIndicator()
                  else if (riskComments.isNotEmpty)
                    Column(
                      children: riskComments.reversed.map((comment) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundImage: comment.accountPicture != null && comment.accountPicture!.isNotEmpty
                                    ? NetworkImage(comment.accountPicture!)
                                    : null,
                                child: comment.accountPicture == null || comment.accountPicture!.isEmpty
                                    ? const Icon(Icons.person, size: 18)
                                    : null,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          comment.accountFullName ?? comment.accountUserName ?? 'User #${comment.accountId}',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          formatDate(comment.createdAt),
                                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    editingCommentId == comment.id
                                        ? Column(
                                      children: [
                                        TextField(
                                          controller: TextEditingController(text: editedCommentContent),
                                          onChanged: (value) => editedCommentContent = value,
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            hintText: 'Chỉnh sửa bình luận',
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            TextButton(
                                              onPressed: () {
                                                updateRiskComment(comment.id, editedCommentContent);
                                                setState(() => editingCommentId = null);
                                              },
                                              child: const Text('Lưu', style: TextStyle(color: Colors.green)),
                                            ),
                                            TextButton(
                                              onPressed: () => setState(() => editingCommentId = null),
                                              child: const Text('Hủy', style: TextStyle(color: Colors.red)),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                        : Text(comment.comment),
                                    if (comment.accountId == currentAccountId && editingCommentId != comment.id)
                                      Row(
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              setState(() {
                                                editingCommentId = comment.id;
                                                editedCommentContent = comment.comment;
                                              });
                                            },
                                            child: const Text('Chỉnh sửa', style: TextStyle(color: Colors.blue)),
                                          ),
                                          TextButton(
                                            onPressed: () => deleteRiskComment(comment.id),
                                            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    )
                  else
                    const Text("Không có bình luận"),
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Thêm bình luận',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => newComment = value,
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        createRiskComment(value.trim());
                        setState(() => newComment = '');
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Nhật ký hoạt động",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  if (isActivityLogsLoading)
                    const CircularProgressIndicator()
                  else if (activityLogs.isNotEmpty)
                    Column(
                      children: activityLogs.map((log) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    log.createdByName ?? 'User #${log.createdBy}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    formatDate(log.createdAt),
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(log.message),
                            ],
                          ),
                        );
                      }).toList(),
                    )
                  else
                    const Text("Không có nhật ký hoạt động"),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Assignee {
  final int id;
  final String? fullName;
  final String userName;
  final String? picture;

  Assignee({
    required this.id,
    this.fullName,
    required this.userName,
    this.picture,
  });
}
