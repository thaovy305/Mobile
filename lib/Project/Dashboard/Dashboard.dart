// import 'package:flutter/material.dart';
// import 'package:intelli_pm/Project/Dashboard/CostBarChart.dart';
// import 'package:intelli_pm/Project/Dashboard/ProgressPerSprint.dart';
// import 'package:intelli_pm/Project/Dashboard/TaskStatusChart.dart';
// import 'package:intelli_pm/Project/Dashboard/TimeComparisonChart.dart';
// import 'package:intelli_pm/Project/Dashboard/WorkloadChart.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../Helper/UriHelper.dart';
// import 'ForecastCard.dart';
// import 'AlertCard.dart';
// import 'HealthOverview.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
//
// class ProjectMetricResponse {
//   final bool isSuccess;
//   final int code;
//   final String message;
//   final ProjectMetricData data;
//
//   ProjectMetricResponse({
//     required this.isSuccess,
//     required this.code,
//     required this.message,
//     required this.data,
//   });
//
//   factory ProjectMetricResponse.fromJson(Map<String, dynamic> json) {
//     return ProjectMetricResponse(
//       isSuccess: json['isSuccess'],
//       code: json['code'],
//       message: json['message'],
//       data: ProjectMetricData.fromJson(json['data']),
//     );
//   }
// }
//
// class ProjectMetricData {
//   final int projectId;
//   final double plannedValue;
//   final double earnedValue;
//   final double actualCost;
//   final double budgetAtCompletion;
//   final double durationAtCompletion;
//   final double costVariance;
//   final double scheduleVariance;
//   final double costPerformanceIndex;
//   final double schedulePerformanceIndex;
//   final double estimateAtCompletion;
//   final double estimateToComplete;
//   final double varianceAtCompletion;
//   final double estimateDurationAtCompletion;
//   final String calculatedBy;
//   final String createdAt;
//   final String updatedAt;
//
//   ProjectMetricData({
//     required this.projectId,
//     required this.plannedValue,
//     required this.earnedValue,
//     required this.actualCost,
//     required this.budgetAtCompletion,
//     required this.durationAtCompletion,
//     required this.costVariance,
//     required this.scheduleVariance,
//     required this.costPerformanceIndex,
//     required this.schedulePerformanceIndex,
//     required this.estimateAtCompletion,
//     required this.estimateToComplete,
//     required this.varianceAtCompletion,
//     required this.estimateDurationAtCompletion,
//     required this.calculatedBy,
//     required this.createdAt,
//     required this.updatedAt,
//   });
//
//   factory ProjectMetricData.fromJson(Map<String, dynamic> json) {
//     return ProjectMetricData(
//       projectId: json['projectId'],
//       plannedValue: (json['plannedValue'] ?? 0).toDouble(),
//       earnedValue: (json['earnedValue'] ?? 0).toDouble(),
//       actualCost: (json['actualCost'] ?? 0).toDouble(),
//       budgetAtCompletion: (json['budgetAtCompletion'] ?? 0).toDouble(),
//       durationAtCompletion: (json['durationAtCompletion'] ?? 0).toDouble(),
//       costVariance: (json['costVariance'] ?? 0).toDouble(),
//       scheduleVariance: (json['scheduleVariance'] ?? 0).toDouble(),
//       costPerformanceIndex: (json['costPerformanceIndex'] ?? 0).toDouble(),
//       schedulePerformanceIndex:
//           (json['schedulePerformanceIndex'] ?? 0).toDouble(),
//       estimateAtCompletion: (json['estimateAtCompletion'] ?? 0).toDouble(),
//       estimateToComplete: (json['estimateToComplete'] ?? 0).toDouble(),
//       varianceAtCompletion: (json['varianceAtCompletion'] ?? 0).toDouble(),
//       estimateDurationAtCompletion:
//           (json['estimateDurationAtCompletion'] ?? 0).toDouble(),
//       calculatedBy: json['calculatedBy'] ?? '',
//       createdAt: json['createdAt'] ?? '',
//       updatedAt: json['updatedAt'] ?? '',
//     );
//   }
// }
//
// class AIRecommendationDTO {
//   final String recommendation;
//   final String details;
//   final String type;
//   final List<String> affectedTasks;
//   final String? suggestedTask;
//   final String expectedImpact;
//   final Map<String, dynamic> suggestedChanges;
//
//   AIRecommendationDTO({
//     required this.recommendation,
//     required this.details,
//     required this.type,
//     required this.affectedTasks,
//     required this.suggestedTask,
//     required this.expectedImpact,
//     required this.suggestedChanges,
//   });
//
//   factory AIRecommendationDTO.fromJson(Map<String, dynamic> json) {
//     return AIRecommendationDTO(
//       recommendation: json['recommendation'],
//       details: json['details'],
//       type: json['type'],
//       affectedTasks: List<String>.from(json['affectedTasks']),
//       suggestedTask: json['suggestedTask'],
//       expectedImpact: json['expectedImpact'],
//       suggestedChanges: Map<String, dynamic>.from(json['suggestedChanges']),
//     );
//   }
// }
//
// class DashboardPage extends StatefulWidget {
//   final String projectKey;
//
//   const DashboardPage({Key? key, required this.projectKey}) : super(key: key);
//
//   @override
//   State<DashboardPage> createState() => _DashboardPageState();
// }
//
// class _DashboardPageState extends State<DashboardPage> {
//   late Future<ProjectMetricResponse> metricFuture;
//   bool showRecommendations = false;
//   bool isRecLoading = false;
//   List<AIRecommendationDTO> aiRecommendations = [];
//
//   @override
//   void initState() {
//     super.initState();
//     metricFuture = fetchProjectMetric(widget.projectKey);
//   }
//
//   Future<ProjectMetricResponse> fetchProjectMetric(String projectKey) async {
//     final uri = UriHelper.build(
//       '/projectmetric/by-project-key?projectKey=$projectKey',
//     );
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('accessToken') ?? '';
//
//     final response = await http.get(
//       uri,
//       headers: {
//         "Content-Type": "application/json",
//         'Authorization': 'Bearer $token',
//       },
//     );
//
//     if (response.statusCode == 200) {
//       return ProjectMetricResponse.fromJson(json.decode(response.body));
//     } else {
//       throw Exception('Failed to load metric');
//     }
//   }
//
//   Future<List<AIRecommendationDTO>> fetchRecommendations(
//     String projectKey,
//   ) async {
//     final url = UriHelper.build(
//       '/projectrecommendation/ai-recommendations?projectKey=$projectKey',
//     );
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('accessToken') ?? '';
//
//     final response = await http.get(
//       url,
//       headers: {
//         "Content-Type": "application/json",
//         "Authorization": 'Bearer $token',
//       },
//     );
//
//     if (response.statusCode == 200) {
//       final json = jsonDecode(response.body);
//       final List data = json['data'];
//       return data.map((e) => AIRecommendationDTO.fromJson(e)).toList();
//     } else {
//       throw Exception('Failed to load AI Recommendations');
//     }
//   }
//
//   Future<void> fetchRecommendationsFromAPI(String projectKey) async {
//     setState(() {
//       isRecLoading = true;
//       showRecommendations = true;
//     });
//
//     try {
//       final recs = await fetchRecommendations(projectKey);
//       setState(() {
//         aiRecommendations = recs;
//       });
//     } catch (e) {
//       print("Failed to fetch recommendations: $e");
//     } finally {
//       setState(() {
//         isRecLoading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F6F8),
//       // appBar: AppBar(
//       //   title: Text('Dashboard - ${widget.projectKey}'),
//       //   backgroundColor: Colors.blue,
//       // ),
//       body: FutureBuilder<ProjectMetricResponse>(
//         future: metricFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text("Error: ${snapshot.error}"));
//           } else {
//             final metric = snapshot.data!.data;
//             return ListView(
//               padding: const EdgeInsets.all(16),
//               children: [
//                 ForecastCard(metric: metric), // ForecastCard
//                 const SizedBox(height: 16),
//                 AlertCard(
//                   spi: metric.schedulePerformanceIndex,
//                   cpi: metric.costPerformanceIndex,
//                   showRecommendations: showRecommendations,
//                   onShowAIRecommendations: () => fetchRecommendationsFromAPI(widget.projectKey),
//                   isRecLoading: isRecLoading,
//                   aiRecommendations: aiRecommendations,
//                 ),
//                 HealthOverview(projectKey: widget.projectKey), // HealthOverview
//                 TaskStatusChart(projectKey: widget.projectKey), // TaskStatusChart
//                 ProgressPerSprint(projectKey: widget.projectKey), // ProgressPerSprint
//                 TimeComparisonChart(projectKey: widget.projectKey), // TimeComparisonChart
//                 CostBarChart(projectKey: widget.projectKey), // CostBarChart
//                 WorkloadChart(projectKey: widget.projectKey), // WorkloadChart
//               ],
//             );
//           }
//         },
//       ),
//     );
//   }
// }

//-----------------------
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
// import '../../Helper/UriHelper.dart'; // Assuming UriHelper is defined similarly
// import './HealthOverview.dart';
// import './ProgressPerSprint.dart';
// import './TimeComparisonChart.dart';
// import './CostBarChart.dart';
// import './WorkloadChart.dart';
// import './TaskStatusChart.dart';
//
// // Data models
// class ProjectMetricResponse {
//   final bool isSuccess;
//   final int code;
//   final String message;
//   final ProjectMetricData data;
//
//   ProjectMetricResponse({
//     required this.isSuccess,
//     required this.code,
//     required this.message,
//     required this.data,
//   });
//
//   factory ProjectMetricResponse.fromJson(Map<String, dynamic> json) {
//     return ProjectMetricResponse(
//       isSuccess: json['isSuccess'],
//       code: json['code'],
//       message: json['message'],
//       data: ProjectMetricData.fromJson(json['data']),
//     );
//   }
// }
//
// class ProjectMetricData {
//   final int projectId;
//   final double plannedValue;
//   final double earnedValue;
//   final double actualCost;
//   final double budgetAtCompletion;
//   final double durationAtCompletion;
//   final double costVariance;
//   final double scheduleVariance;
//   final double costPerformanceIndex;
//   final double schedulePerformanceIndex;
//   final double estimateAtCompletion;
//   final double estimateToComplete;
//   final double varianceAtCompletion;
//   final double estimateDurationAtCompletion;
//   final String calculatedBy;
//   final String createdAt;
//   final String updatedAt;
//   final bool isImproved;
//   final String improvementSummary;
//   final double confidenceScore;
//
//   ProjectMetricData({
//     required this.projectId,
//     required this.plannedValue,
//     required this.earnedValue,
//     required this.actualCost,
//     required this.budgetAtCompletion,
//     required this.durationAtCompletion,
//     required this.costVariance,
//     required this.scheduleVariance,
//     required this.costPerformanceIndex,
//     required this.schedulePerformanceIndex,
//     required this.estimateAtCompletion,
//     required this.estimateToComplete,
//     required this.varianceAtCompletion,
//     required this.estimateDurationAtCompletion,
//     required this.calculatedBy,
//     required this.createdAt,
//     required this.updatedAt,
//     this.isImproved = false,
//     this.improvementSummary = '',
//     this.confidenceScore = 0.0,
//   });
//
//   factory ProjectMetricData.fromJson(Map<String, dynamic> json) {
//     return ProjectMetricData(
//       projectId: json['projectId'],
//       plannedValue: (json['plannedValue'] ?? 0).toDouble(),
//       earnedValue: (json['earnedValue'] ?? 0).toDouble(),
//       actualCost: (json['actualCost'] ?? 0).toDouble(),
//       budgetAtCompletion: (json['budgetAtCompletion'] ?? 0).toDouble(),
//       durationAtCompletion: (json['durationAtCompletion'] ?? 0).toDouble(),
//       costVariance: (json['costVariance'] ?? 0).toDouble(),
//       scheduleVariance: (json['scheduleVariance'] ?? 0).toDouble(),
//       costPerformanceIndex: (json['costPerformanceIndex'] ?? 0).toDouble(),
//       schedulePerformanceIndex: (json['schedulePerformanceIndex'] ?? 0).toDouble(),
//       estimateAtCompletion: (json['estimateAtCompletion'] ?? 0).toDouble(),
//       estimateToComplete: (json['estimateToComplete'] ?? 0).toDouble(),
//       varianceAtCompletion: (json['varianceAtCompletion'] ?? 0).toDouble(),
//       estimateDurationAtCompletion: (json['estimateDurationAtCompletion'] ?? 0).toDouble(),
//       calculatedBy: json['calculatedBy'] ?? '',
//       createdAt: json['createdAt'] ?? '',
//       updatedAt: json['updatedAt'] ?? '',
//       isImproved: json['isImproved'] ?? false,
//       improvementSummary: json['improvementSummary'] ?? '',
//       confidenceScore: (json['confidenceScore'] ?? 0).toDouble(),
//     );
//   }
// }
//
// class AIRecommendationDTO {
//   final int? id;
//   final String recommendation;
//   final String details;
//   final String type;
//   final List<String> affectedTasks;
//   final String? suggestedTask;
//   final String expectedImpact;
//   final Map<String, dynamic> suggestedChanges;
//   final int priority;
//
//   AIRecommendationDTO({
//     this.id,
//     required this.recommendation,
//     required this.details,
//     required this.type,
//     required this.affectedTasks,
//     this.suggestedTask,
//     required this.expectedImpact,
//     required this.suggestedChanges,
//     required this.priority,
//   });
//
//   factory AIRecommendationDTO.fromJson(Map<String, dynamic> json) {
//     return AIRecommendationDTO(
//       id: json['id'],
//       recommendation: json['recommendation'],
//       details: json['details'],
//       type: json['type'],
//       affectedTasks: List<String>.from(json['affectedTasks']),
//       suggestedTask: json['suggestedTask'],
//       expectedImpact: json['expectedImpact'],
//       suggestedChanges: Map<String, dynamic>.from(json['suggestedChanges']),
//       priority: json['priority'] ?? 0,
//     );
//   }
// }
//
// class MetricHistoryItem {
//   final int id;
//   final int projectId;
//   final String metricKey;
//   final Map<String, dynamic> value;
//   final String recordedAt;
//
//   MetricHistoryItem({
//     required this.id,
//     required this.projectId,
//     required this.metricKey,
//     required this.value,
//     required this.recordedAt,
//   });
//
//   // factory MetricHistoryItem.fromJson(Map<String, dynamic> json) {
//   //   dynamic parsedValue;
//   //   try {
//   //     if (json['value'] is String) {
//   //       parsedValue = jsonDecode(json['value']);
//   //       if (parsedValue is! Map<String, dynamic>) {
//   //         print('Error: Parsed value is not a Map<String, dynamic>, got: $parsedValue');
//   //         parsedValue = {}; // Fallback to empty map
//   //       }
//   //     } else {
//   //       parsedValue = json['value'] is Map<String, dynamic> ? json['value'] : {};
//   //     }
//   //   } catch (e) {
//   //     print('Error parsing value field in MetricHistoryItem: $e, JSON: $json');
//   //     parsedValue = {}; // Fallback to empty map on error
//   //   }
//   //
//   //   return MetricHistoryItem(
//   //     id: (json['id'] is num) ? json['id'].toInt() : json['id'],
//   //     projectId: (json['projectId'] is num) ? json['projectId'].toInt() : json['projectId'],
//   //     metricKey: json['metricKey'] ?? '',
//   //     value: parsedValue,
//   //     recordedAt: json['recordedAt'] ?? '',
//   //   );
//   // }
// }
//
// class HealthDashboardResponse {
//   final bool isSuccess;
//   final int code;
//   final String message;
//   final HealthData data;
//
//   HealthDashboardResponse({
//     required this.isSuccess,
//     required this.code,
//     required this.message,
//     required this.data,
//   });
//
//   factory HealthDashboardResponse.fromJson(Map<String, dynamic> json) {
//     return HealthDashboardResponse(
//       isSuccess: json['isSuccess'],
//       code: json['code'],
//       message: json['message'],
//       data: HealthData.fromJson(json['data']),
//     );
//   }
// }
//
// class HealthData {
//   final String projectStatus;
//   final String timeStatus;
//   final int tasksToBeCompleted;
//   final int overdueTasks;
//   final double progressPercent;
//   final double costStatus;
//   final ProjectMetricData cost;
//   final bool showAlert;
//
//   HealthData({
//     required this.projectStatus,
//     required this.timeStatus,
//     required this.tasksToBeCompleted,
//     required this.overdueTasks,
//     required this.progressPercent,
//     required this.costStatus,
//     required this.cost,
//     required this.showAlert,
//   });
//
//   factory HealthData.fromJson(Map<String, dynamic> json) {
//     return HealthData(
//       projectStatus: json['projectStatus'],
//       timeStatus: json['timeStatus'],
//       tasksToBeCompleted: json['tasksToBeCompleted'],
//       overdueTasks: json['overdueTasks'],
//       progressPercent: (json['progressPercent'] ?? 0).toDouble(),
//       costStatus: json['costStatus'],
//       cost: ProjectMetricData.fromJson(json['cost']),
//       showAlert: json['showAlert'],
//     );
//   }
// }
//
// class TaskStatusItem {
//   final int key;
//   final String name;
//   final int count;
//
//   TaskStatusItem({
//     required this.key,
//     required this.name,
//     required this.count,
//   });
//
//   factory TaskStatusItem.fromJson(Map<String, dynamic> json) {
//     return TaskStatusItem(
//       key: json['key'],
//       name: json['name'],
//       count: json['count'],
//     );
//   }
// }
//
// class TaskStatusDashboardResponse {
//   final bool isSuccess;
//   final int code;
//   final String message;
//   final List<TaskStatusItem> statusCounts;
//
//   TaskStatusDashboardResponse({
//     required this.isSuccess,
//     required this.code,
//     required this.message,
//     required this.statusCounts,
//   });
//
//   factory TaskStatusDashboardResponse.fromJson(Map<String, dynamic> json) {
//     return TaskStatusDashboardResponse(
//       isSuccess: json['isSuccess'],
//       code: json['code'],
//       message: json['message'],
//       statusCounts: (json['data']['statusCounts'] as List)
//           .map((e) => TaskStatusItem.fromJson(e))
//           .toList(),
//     );
//   }
// }
//
// class ProgressItem {
//   final int sprintId;
//   final String sprintName;
//   final double percentComplete;
//
//   ProgressItem({
//     required this.sprintId,
//     required this.sprintName,
//     required this.percentComplete,
//   });
//
//   factory ProgressItem.fromJson(Map<String, dynamic> json) {
//     return ProgressItem(
//       sprintId: json['sprintId'],
//       sprintName: json['sprintName'],
//       percentComplete: (json['percentComplete'] ?? 0).toDouble(),
//     );
//   }
// }
//
// class ProgressDashboardResponse {
//   final bool isSuccess;
//   final int code;
//   final String message;
//   final List<ProgressItem> data;
//
//   ProgressDashboardResponse({
//     required this.isSuccess,
//     required this.code,
//     required this.message,
//     required this.data,
//   });
//
//   factory ProgressDashboardResponse.fromJson(Map<String, dynamic> json) {
//     return ProgressDashboardResponse(
//       isSuccess: json['isSuccess'],
//       code: json['code'],
//       message: json['message'],
//       data: (json['data'] as List).map((e) => ProgressItem.fromJson(e)).toList(),
//     );
//   }
// }
//
// class TimeDashboardResponse {
//   final bool isSuccess;
//   final int code;
//   final String message;
//   final TimeData data;
//
//   TimeDashboardResponse({
//     required this.isSuccess,
//     required this.code,
//     required this.message,
//     required this.data,
//   });
//
//   factory TimeDashboardResponse.fromJson(Map<String, dynamic> json) {
//     return TimeDashboardResponse(
//       isSuccess: json['isSuccess'],
//       code: json['code'],
//       message: json['message'],
//       data: TimeData.fromJson(json['data']),
//     );
//   }
// }
//
// class TimeData {
//   final double plannedCompletion;
//   final double actualCompletion;
//   final String status;
//
//   TimeData({
//     required this.plannedCompletion,
//     required this.actualCompletion,
//     required this.status,
//   });
//
//   factory TimeData.fromJson(Map<String, dynamic> json) {
//     return TimeData(
//       plannedCompletion: (json['plannedCompletion'] ?? 0).toDouble(),
//       actualCompletion: (json['actualCompletion'] ?? 0).toDouble(),
//       status: json['status'],
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
//
// class WorkloadDashboardResponse {
//   final bool isSuccess;
//   final int code;
//   final String message;
//   final List<WorkloadMember> data;
//
//   WorkloadDashboardResponse({
//     required this.isSuccess,
//     required this.code,
//     required this.message,
//     required this.data,
//   });
//
//   factory WorkloadDashboardResponse.fromJson(Map<String, dynamic> json) {
//     return WorkloadDashboardResponse(
//       isSuccess: json['isSuccess'],
//       code: json['code'],
//       message: json['message'],
//       data: (json['data'] as List).map((e) => WorkloadMember.fromJson(e)).toList(),
//     );
//   }
// }
//
// class CostDashboardResponse {
//   final bool isSuccess;
//   final int code;
//   final String message;
//   final CostData data;
//
//   CostDashboardResponse({
//     required this.isSuccess,
//     required this.code,
//     required this.message,
//     required this.data,
//   });
//
//   factory CostDashboardResponse.fromJson(Map<String, dynamic> json) {
//     return CostDashboardResponse(
//       isSuccess: json['isSuccess'],
//       code: json['code'],
//       message: json['message'],
//       data: CostData.fromJson(json['data']),
//     );
//   }
// }
//
// class CostData {
//   final double actualCost;
//   final double actualTaskCost;
//   final double actualResourceCost;
//   final double plannedCost;
//   final double plannedTaskCost;
//   final double plannedResourceCost;
//   final double budget;
//
//   CostData({
//     required this.actualCost,
//     required this.actualTaskCost,
//     required this.actualResourceCost,
//     required this.plannedCost,
//     required this.plannedTaskCost,
//     required this.plannedResourceCost,
//     required this.budget,
//   });
//
//   factory CostData.fromJson(Map<String, dynamic> json) {
//     return CostData(
//       actualCost: (json['actualCost'] ?? 0).toDouble(),
//       actualTaskCost: (json['actualTaskCost'] ?? 0).toDouble(),
//       actualResourceCost: (json['actualResourceCost'] ?? 0).toDouble(),
//       plannedCost: (json['plannedCost'] ?? 0).toDouble(),
//       plannedTaskCost: (json['plannedTaskCost'] ?? 0).toDouble(),
//       plannedResourceCost: (json['plannedResourceCost'] ?? 0).toDouble(),
//       budget: (json['budget'] ?? 0).toDouble(),
//     );
//   }
// }
//
// // Extension for AIRecommendationDTO to support copyWith
// extension AIRecommendationDTOExtension on AIRecommendationDTO {
//   AIRecommendationDTO copyWith({
//     int? id,
//     String? recommendation,
//     String? details,
//     String? type,
//     List<String>? affectedTasks,
//     String? suggestedTask,
//     String? expectedImpact,
//     Map<String, dynamic>? suggestedChanges,
//     int? priority,
//   }) {
//     return AIRecommendationDTO(
//       id: id ?? this.id,
//       recommendation: recommendation ?? this.recommendation,
//       details: details ?? this.details,
//       type: type ?? this.type,
//       affectedTasks: affectedTasks ?? this.affectedTasks,
//       suggestedTask: suggestedTask ?? this.suggestedTask,
//       expectedImpact: expectedImpact ?? this.expectedImpact,
//       suggestedChanges: suggestedChanges ?? this.suggestedChanges,
//       priority: priority ?? this.priority,
//     );
//   }
// }
//
// class DashboardPage extends StatefulWidget {
//   final String projectKey;
//
//   const DashboardPage({Key? key, required this.projectKey}) : super(key: key);
//
//   @override
//   _DashboardPageState createState() => _DashboardPageState();
// }
//
// class _DashboardPageState extends State<DashboardPage> {
//   late Future<ProjectMetricResponse> metricFuture;
//   late Future<HealthDashboardResponse> healthFuture;
//   late Future<TaskStatusDashboardResponse> taskStatusFuture;
//   late Future<ProgressDashboardResponse> progressFuture;
//   late Future<TimeDashboardResponse> timeFuture;
//   late Future<CostDashboardResponse> costFuture;
//   late Future<WorkloadDashboardResponse> workloadFuture;
//   late Future<ProjectMetricResponse> aiMetricFuture;
//   late Future<List<MetricHistoryItem>> historyFuture;
//   late Future<List<AIRecommendationDTO>> recommendationsFuture;
//   bool showRecommendations = false;
//   bool isRecLoading = false;
//   bool isCalculateDone = false;
//   List<AIRecommendationDTO> aiRecommendations = [];
//   List<int> approvedIds = [];
//   String aiResponseJson = '';
//   bool isEvaluationPopupOpen = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeFutures();
//     _calculateAndRefetch();
//   }
//
//   void _initializeFutures() {
//     metricFuture = fetchProjectMetric(widget.projectKey);
//     healthFuture = fetchHealthDashboard(widget.projectKey);
//     taskStatusFuture = fetchTaskStatusDashboard(widget.projectKey);
//     progressFuture = fetchProgressDashboard(widget.projectKey);
//     timeFuture = fetchTimeDashboard(widget.projectKey);
//     costFuture = fetchCostDashboard(widget.projectKey);
//     workloadFuture = fetchWorkloadDashboard(widget.projectKey);
//     aiMetricFuture = fetchProjectMetricAI(widget.projectKey);
//     // historyFuture = fetchMetricHistory(widget.projectKey);
//     recommendationsFuture = fetchRecommendations(widget.projectKey);
//   }
//
//   Future<void> _calculateAndRefetch() async {
//     setState(() {
//       isCalculateDone = false;
//     });
//     try {
//       await calculateMetricsBySystem(widget.projectKey);
//       _initializeFutures();
//       setState(() {
//         isCalculateDone = true;
//       });
//     } catch (e) {
//       print('Error calculating metrics: $e');
//       setState(() {
//         isCalculateDone = true;
//       });
//     }
//   }
//
//   Future<void> calculateMetricsBySystem(String projectKey) async {
//     final uri = UriHelper.build('/projectmetric/calculate-by-system?projectKey=$projectKey');
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('accessToken') ?? '';
//
//     final response = await http.post(
//       uri,
//       headers: {
//         "Content-Type": "application/json",
//         'Authorization': 'Bearer $token',
//       },
//     );
//
//     if (response.statusCode != 200) {
//       throw Exception('Failed to calculate metrics');
//     }
//   }
//
//   Future<ProjectMetricResponse> fetchProjectMetric(String projectKey) async {
//     final uri = UriHelper.build('/projectmetric/by-project-key?projectKey=$projectKey');
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('accessToken') ?? '';
//
//     final response = await http.get(
//       uri,
//       headers: {
//         "Content-Type": "application/json",
//         'Authorization': 'Bearer $token',
//       },
//     );
//
//     if (response.statusCode == 200) {
//       return ProjectMetricResponse.fromJson(json.decode(response.body));
//     } else {
//       throw Exception('Failed to load metric');
//     }
//   }
//
//   Future<HealthDashboardResponse> fetchHealthDashboard(String projectKey) async {
//     final uri = UriHelper.build('/projectmetric/health-dashboard?projectKey=$projectKey');
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('accessToken') ?? '';
//
//     final response = await http.get(
//       uri,
//       headers: {
//         "Content-Type": "application/json",
//         'Authorization': 'Bearer $token',
//       },
//     );
//
//     if (response.statusCode == 200) {
//       return HealthDashboardResponse.fromJson(json.decode(response.body));
//     } else {
//       throw Exception('Failed to load health dashboard');
//     }
//   }
//
//   Future<TaskStatusDashboardResponse> fetchTaskStatusDashboard(String projectKey) async {
//     final uri = UriHelper.build('/projectmetric/tasks-dashboard?projectKey=$projectKey');
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('accessToken') ?? '';
//
//     final response = await http.get(
//       uri,
//       headers: {
//         "Content-Type": "application/json",
//         'Authorization': 'Bearer $token',
//       },
//     );
//
//     if (response.statusCode == 200) {
//       return TaskStatusDashboardResponse.fromJson(json.decode(response.body));
//     } else {
//       throw Exception('Failed to load task status dashboard');
//     }
//   }
//
//   Future<ProgressDashboardResponse> fetchProgressDashboard(String projectKey) async {
//     final uri = UriHelper.build('/projectmetric/progress-dashboard?projectKey=$projectKey');
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('accessToken') ?? '';
//
//     final response = await http.get(
//       uri,
//       headers: {
//         "Content-Type": "application/json",
//         'Authorization': 'Bearer $token',
//       },
//     );
//
//     if (response.statusCode == 200) {
//       return ProgressDashboardResponse.fromJson(json.decode(response.body));
//     } else {
//       throw Exception('Failed to load progress dashboard');
//     }
//   }
//
//   Future<TimeDashboardResponse> fetchTimeDashboard(String projectKey) async {
//     final uri = UriHelper.build('/projectmetric/time-dashboard?projectKey=$projectKey');
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('accessToken') ?? '';
//
//     final response = await http.get(
//       uri,
//       headers: {
//         "Content-Type": "application/json",
//         'Authorization': 'Bearer $token',
//       },
//     );
//
//     if (response.statusCode == 200) {
//       return TimeDashboardResponse.fromJson(json.decode(response.body));
//     } else {
//       throw Exception('Failed to load time dashboard');
//     }
//   }
//
//   Future<CostDashboardResponse> fetchCostDashboard(String projectKey) async {
//     final uri = UriHelper.build('/projectmetric/cost-dashboard?projectKey=$projectKey');
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('accessToken') ?? '';
//
//     final response = await http.get(
//       uri,
//       headers: {
//         "Content-Type": "application/json",
//         'Authorization': 'Bearer $token',
//       },
//     );
//
//     if (response.statusCode == 200) {
//       return CostDashboardResponse.fromJson(json.decode(response.body));
//     } else {
//       throw Exception('Failed to load cost dashboard');
//     }
//   }
//
//   Future<WorkloadDashboardResponse> fetchWorkloadDashboard(String projectKey) async {
//     final uri = UriHelper.build('/projectmetric/workload-dashboard?projectKey=$projectKey');
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('accessToken') ?? '';
//
//     final response = await http.get(
//       uri,
//       headers: {
//         "Content-Type": "application/json",
//         'Authorization': 'Bearer $token',
//       },
//     );
//
//     if (response.statusCode == 200) {
//       return WorkloadDashboardResponse.fromJson(json.decode(response.body));
//     } else {
//       throw Exception('Failed to load workload dashboard');
//     }
//   }
//
//   Future<ProjectMetricResponse> fetchProjectMetricAI(String projectKey) async {
//     final uri = UriHelper.build('/projectmetric/ai-forecast?projectKey=$projectKey');
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('accessToken') ?? '';
//
//     final response = await http.get(
//       uri,
//       headers: {
//         "Content-Type": "application/json",
//         'Authorization': 'Bearer $token',
//       },
//     );
//
//     if (response.statusCode == 200) {
//       return ProjectMetricResponse.fromJson(json.decode(response.body));
//     } else {
//       throw Exception('Failed to load AI metric forecast');
//     }
//   }
//
//   // Future<List<MetricHistoryItem>> fetchMetricHistory(String projectKey) async {
//   //   final uri = UriHelper.build('/projectmetrichistory/history/$projectKey');
//   //   final prefs = await SharedPreferences.getInstance();
//   //   final token = prefs.getString('accessToken') ?? '';
//   //
//   //   final response = await http.get(
//   //     uri,
//   //     headers: {
//   //       "Content-Type": "application/json",
//   //       'Authorization': 'Bearer $token',
//   //     },
//   //   );
//   //
//   //   if (response.statusCode == 200) {
//   //     final List data = jsonDecode(response.body)['data'];
//   //     return data.map((e) => MetricHistoryItem.fromJson(e)).toList();
//   //   } else {
//   //     throw Exception('Failed to load metric history');
//   //   }
//   // }
//
//   Future<List<AIRecommendationDTO>> fetchRecommendations(String projectKey) async {
//     final uri = UriHelper.build('/projectrecommendation/ai-recommendations?projectKey=$projectKey');
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('accessToken') ?? '';
//
//     final response = await http.get(
//       uri,
//       headers: {
//         "Content-Type": "application/json",
//         'Authorization': 'Bearer $token',
//       },
//     );
//
//     if (response.statusCode == 200) {
//       final json = jsonDecode(response.body);
//       final List data = json['data'];
//       return data.map((e) => AIRecommendationDTO.fromJson(e)).toList();
//     } else {
//       throw Exception('Failed to load AI Recommendations');
//     }
//   }
//
//   Future<void> createRecommendation(AIRecommendationDTO rec, int projectId) async {
//     final uri = UriHelper.build('/projectrecommendation');
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('accessToken') ?? '';
//
//     final response = await http.post(
//       uri,
//       headers: {
//         "Content-Type": "application/json",
//         'Authorization': 'Bearer $token',
//       },
//       body: jsonEncode({
//         'projectId': projectId,
//         'type': rec.type,
//         'recommendation': rec.recommendation,
//         'details': rec.details,
//         'suggestedChanges': rec.suggestedChanges,
//       }),
//     );
//
//     if (response.statusCode != 200) {
//       throw Exception('Failed to save recommendation');
//     }
//   }
//
//   Future<void> fetchRecommendationsFromAPI(String projectKey) async {
//     setState(() {
//       isRecLoading = true;
//       showRecommendations = true;
//     });
//
//     try {
//       final recs = await fetchRecommendations(projectKey);
//       setState(() {
//         aiRecommendations = recs;
//       });
//     } catch (e) {
//       print("Failed to fetch recommendations: $e");
//     } finally {
//       setState(() {
//         isRecLoading = false;
//       });
//     }
//   }
//
//   Future<void> handleAfterDeleteRecommendation() async {
//     try {
//       recommendationsFuture = fetchRecommendations(widget.projectKey);
//       aiMetricFuture = fetchProjectMetricAI(widget.projectKey);
//       // historyFuture = fetchMetricHistory(widget.projectKey);
//       setState(() {});
//     } catch (e) {
//       print('Error after deleting recommendation: $e');
//     }
//   }
//
//   Future<void> handleEvaluationSubmitSuccess() async {
//     try {
//       recommendationsFuture = fetchRecommendations(widget.projectKey);
//       aiMetricFuture = fetchProjectMetricAI(widget.projectKey);
//       // historyFuture = fetchMetricHistory(widget.projectKey);
//       setState(() {
//         isEvaluationPopupOpen = false;
//         aiResponseJson = '';
//       });
//     } catch (e) {
//       print('Error handling evaluation submit: $e');
//     }
//   }
//
//   Future<bool> confirm(BuildContext context, String message) async {
//     bool confirmed = false;
//     await showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Confirm'),
//         content: Text(message),
//         actions: [
//           TextButton(
//             onPressed: () {
//               confirmed = false;
//               Navigator.of(context).pop();
//             },
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               confirmed = true;
//               Navigator.of(context).pop();
//             },
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//     return confirmed;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F6F8),
//       appBar: AppBar(
//         title: Text('Dashboard - ${widget.projectKey}'),
//         backgroundColor: Colors.blue,
//       ),
//       body: FutureBuilder<List<dynamic>>(
//         future: Future.wait([
//           metricFuture,
//           healthFuture,
//           taskStatusFuture,
//           progressFuture,
//           timeFuture,
//           costFuture,
//           workloadFuture,
//           aiMetricFuture,
//           // historyFuture,
//           recommendationsFuture,
//         ]),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting || !isCalculateDone) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text("Error: ${snapshot.error}"));
//           } else {
//             final metric = snapshot.data![0] as ProjectMetricResponse;
//             final health = snapshot.data![1] as HealthDashboardResponse;
//             final taskStatus = snapshot.data![2] as TaskStatusDashboardResponse;
//             final progress = snapshot.data![3] as ProgressDashboardResponse;
//             final time = snapshot.data![4] as TimeDashboardResponse;
//             final cost = snapshot.data![5] as CostDashboardResponse;
//             final workload = snapshot.data![6] as WorkloadDashboardResponse;
//             final aiMetric = snapshot.data![7] as ProjectMetricResponse;
//             final history = snapshot.data![8] as List<MetricHistoryItem>;
//             final recommendations = snapshot.data![9] as List<AIRecommendationDTO>;
//
//             return ListView(
//               padding: const EdgeInsets.all(16),
//               children: [
//                 // Impact of AI Recommendations
//                 _buildImpactCard(metric.data, aiMetric.data),
//                 // Approved AI Impact Panel
//                 _buildApprovedAIImpactPanel(recommendations),
//                 // Forecast Card
//                 _buildForecastCard(metric.data),
//                 // Alert Card
//                 if (health.data.showAlert)
//                   _buildAlertCard(
//                     metric.data.schedulePerformanceIndex,
//                     metric.data.costPerformanceIndex,
//                         () => fetchRecommendationsFromAPI(widget.projectKey),
//                     showRecommendations,
//                   ),
//                 // Health Overview
//                 Card(
//                   elevation: 2,
//                   child: Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'Health Overview',
//                           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                         ),
//                         const SizedBox(height: 8),
//                         HealthOverview(data: health),
//                       ],
//                     ),
//                   ),
//                 ),
//                 // Task Status
//                 Card(
//                   elevation: 2,
//                   child: Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'Task Status',
//                           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                         ),
//                         const SizedBox(height: 8),
//                         TaskStatusChart(data: taskStatus),
//                       ],
//                     ),
//                   ),
//                 ),
//                 // Progress Per Sprint
//                 Card(
//                   elevation: 2,
//                   child: Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'Progress Per Sprint',
//                           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                         ),
//                         const SizedBox(height: 8),
//                         ProgressPerSprint(data: progress),
//                       ],
//                     ),
//                   ),
//                 ),
//                 // Time Tracking
//                 Card(
//                   elevation: 2,
//                   child: Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'Time Tracking',
//                           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                         ),
//                         const SizedBox(height: 8),
//                         TimeComparisonChart(data: time),
//                       ],
//                     ),
//                   ),
//                 ),
//                 // Cost
//                 Card(
//                   elevation: 2,
//                   child: Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'Cost',
//                           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                         ),
//                         const SizedBox(height: 8),
//                         CostBarChart(data: cost),
//                       ],
//                     ),
//                   ),
//                 ),
//                 // Workload
//                 Card(
//                   elevation: 2,
//                   child: Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'Workload',
//                           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                         ),
//                         const SizedBox(height: 8),
//                         WorkloadChart(data: workload),
//                       ],
//                     ),
//                   ),
//                 ),
//                 // Metric Trends
//                 _buildMetricTrendsCard(history),
//                 // AI Recommendations Dialog
//                 if (showRecommendations)
//                   _buildRecommendationsDialog(),
//               ],
//             );
//           }
//         },
//       ),
//     );
//   }
//
//   Widget _buildImpactCard(ProjectMetricData metric, ProjectMetricData aiMetric) {
//     return Card(
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Impact of AI Recommendations',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             if (aiRecommendations.isNotEmpty)
//               Text(
//                 'SPI Before: ${metric.schedulePerformanceIndex.toStringAsFixed(2)}\n'
//                     'SPI After: ${aiMetric.schedulePerformanceIndex.toStringAsFixed(2)}\n'
//                     'CPI Before: ${metric.costPerformanceIndex.toStringAsFixed(2)}\n'
//                     'CPI After: ${aiMetric.costPerformanceIndex.toStringAsFixed(2)}',
//                 style: const TextStyle(fontSize: 14),
//               )
//             else
//               const Text(
//                 'No AI recommendations applied yet.',
//                 style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.grey),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildApprovedAIImpactPanel(List<AIRecommendationDTO> approvedRecs) {
//     return Card(
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Approved AI Impact',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             if (approvedRecs.isNotEmpty)
//               Column(
//                 children: approvedRecs
//                     .map((rec) => ListTile(
//                   title: Text(rec.recommendation),
//                   subtitle: Text('Type: ${rec.type}'),
//                 ))
//                     .toList(),
//               )
//             else
//               const Text(
//                 'No approved recommendations.',
//                 style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.grey),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildForecastCard(ProjectMetricData metric) {
//     return Card(
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Project Forecast',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Estimate at Completion (EAC): ${metric.estimateAtCompletion.toStringAsFixed(2)}',
//               style: const TextStyle(fontSize: 14),
//             ),
//             const Text(
//               'Expected total cost of the project based on current data.',
//               style: TextStyle(fontSize: 12, color: Colors.grey),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Estimate to Complete (ETC): ${metric.estimateToComplete.toStringAsFixed(2)}',
//               style: const TextStyle(fontSize: 14),
//             ),
//             const Text(
//               'Projected cost to finish remaining work.',
//               style: TextStyle(fontSize: 12, color: Colors.grey),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Variance at Completion (VAC): ${metric.varianceAtCompletion.toStringAsFixed(2)}',
//               style: const TextStyle(fontSize: 14),
//             ),
//             const Text(
//               'Difference between budget and estimated cost. Negative means over budget.',
//               style: TextStyle(fontSize: 12, color: Colors.grey),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Estimated Duration (EDAC): ${metric.estimateDurationAtCompletion.toStringAsFixed(2)} months',
//               style: const TextStyle(fontSize: 14),
//             ),
//             const Text(
//               'Estimated total time to complete based on progress.',
//               style: TextStyle(fontSize: 12, color: Colors.grey),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildAlertCard(
//       double spi,
//       double cpi,
//       VoidCallback onShowAIRecommendations,
//       bool showRecommendations,
//       ) {
//     return Card(
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Project Alerts',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
//             ),
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 const Icon(Icons.warning, color: Colors.red, size: 20),
//                 const SizedBox(width: 8),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text('Warning:', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
//                     if (spi < 0.9) const Text('• Schedule Performance Index (SPI) is below threshold.'),
//                     if (cpi < 0.9) const Text('• Cost Performance Index (CPI) is below threshold.'),
//                     const Text('• Review AI-suggested actions below.'),
//                   ],
//                 ),
//               ],
//             ),
//             if (!showRecommendations)
//               Padding(
//                 padding: const EdgeInsets.only(top: 8),
//                 child: ElevatedButton.icon(
//                   onPressed: isRecLoading ? null : onShowAIRecommendations,
//                   icon: const Icon(Icons.lightbulb_outline),
//                   label: Text(isRecLoading ? 'Loading...' : 'View AI Suggestions'),
//                   style: ElevatedButton.styleFrom(
//                     foregroundColor: Colors.white,
//                     backgroundColor: Colors.blue,
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildMetricTrendsCard(List<MetricHistoryItem> history) {
//     final processedHistory = history.map((item) {
//       return {
//         'date': DateTime.parse(item.recordedAt).toString().substring(0, 10),
//         'SPI': item.value['SPI']?.toDouble()?.toStringAsFixed(2) ?? '0.00',
//         'CPI': item.value['CPI']?.toDouble()?.toStringAsFixed(2) ?? '0.00',
//         'EV': item.value['EV']?.toDouble() ?? 0.0,
//         'AC': item.value['AC']?.toDouble() ?? 0.0,
//       };
//     }).toList();
//
//     return Card(
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Metric Trends',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             if (processedHistory.isNotEmpty)
//               SizedBox(
//                 height: 300,
//                 child: Text(
//                   'Line Chart Placeholder for SPI, CPI, EV, AC\nData: ${processedHistory.toString()}',
//                   style: const TextStyle(fontSize: 14),
//                 ),
//               )
//             else
//               const Text(
//                 'No historical metric data available yet.',
//                 style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.grey),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildRecommendationsDialog() {
//     return Dialog(
//       backgroundColor: Colors.white,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'AI Suggestions',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.close),
//                   onPressed: () => setState(() {
//                     showRecommendations = false;
//                     aiResponseJson = jsonEncode(aiRecommendations);
//                     isEvaluationPopupOpen = true;
//                   }),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             if (isRecLoading)
//               const Center(child: CircularProgressIndicator())
//             else if (aiRecommendations.isNotEmpty)
//               Flexible(
//                 child: ListView.builder(
//                   shrinkWrap: true,
//                   itemCount: aiRecommendations.length,
//                   itemBuilder: (context, index) {
//                     return _buildRecommendationCard(
//                         aiRecommendations[index], index, metricFuture.then((m) => m.data.projectId));
//                   },
//                 ),
//               )
//             else
//               const Text(
//                 'No AI suggestions available.',
//                 style: TextStyle(fontSize: 14, color: Colors.grey),
//               ),
//             if (aiRecommendations.isNotEmpty)
//               Padding(
//                 padding: const EdgeInsets.only(top: 8),
//                 child: ElevatedButton.icon(
//                   onPressed: () async {
//                     setState(() {
//                       aiResponseJson = jsonEncode(aiRecommendations);
//                       isEvaluationPopupOpen = true;
//                       showRecommendations = false;
//                     });
//                     await handleEvaluationSubmitSuccess();
//                   },
//                   icon: const Icon(Icons.save),
//                   label: const Text('Done'),
//                   style: ElevatedButton.styleFrom(
//                     foregroundColor: Colors.white,
//                     backgroundColor: Colors.blue,
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildRecommendationCard(AIRecommendationDTO rec, int index, Future<int> projectIdFuture) {
//     bool isApproved = approvedIds.contains(index);
//     bool isEditing = false;
//     AIRecommendationDTO editedRec = rec;
//     Map<String, String> errors = {};
//
//     return StatefulBuilder(
//       builder: (context, setState) {
//         void validateFields() {
//           final newErrors = <String, String>{};
//           if (editedRec.recommendation.trim().isEmpty) {
//             newErrors['recommendation'] = 'Recommendation is required';
//           }
//           if (!['SCHEDULE', 'COST'].contains(editedRec.type.toUpperCase())) {
//             newErrors['type'] = 'Valid type is required';
//           }
//           errors = newErrors;
//         }
//
//         return Card(
//           elevation: 2,
//           margin: const EdgeInsets.symmetric(vertical: 8),
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: isEditing
//                 ? Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 TextField(
//                   decoration: InputDecoration(
//                     labelText: 'Recommendation',
//                     errorText: errors['recommendation'],
//                   ),
//                   onChanged: (value) => editedRec = editedRec.copyWith(recommendation: value),
//                 ),
//                 DropdownButton<String>(
//                   value: editedRec.type,
//                   items: ['SCHEDULE', 'COST']
//                       .map((type) => DropdownMenuItem(
//                     value: type,
//                     child: Text(type),
//                   ))
//                       .toList(),
//                   onChanged: (value) => setState(() {
//                     editedRec = editedRec.copyWith(type: value!);
//                   }),
//                   hint: const Text('Select type'),
//                 ),
//                 if (errors['type'] != null)
//                   Text(
//                     errors['type']!,
//                     style: const TextStyle(color: Colors.red, fontSize: 12),
//                   ),
//                 TextField(
//                   decoration: const InputDecoration(labelText: 'Details'),
//                   maxLines: 4,
//                   onChanged: (value) => editedRec = editedRec.copyWith(details: value),
//                 ),
//                 TextField(
//                   decoration: const InputDecoration(labelText: 'Suggested Changes'),
//                   onChanged: (value) =>
//                   editedRec = editedRec.copyWith(suggestedChanges: {'changes': value}),
//                 ),
//                 if (errors['api'] != null)
//                   Text(
//                     errors['api']!,
//                     style: const TextStyle(color: Colors.red, fontSize: 12),
//                   ),
//                 Row(
//                   children: [
//                     ElevatedButton.icon(
//                       onPressed: () async {
//                         validateFields();
//                         if (errors.isEmpty) {
//                           setState(() {
//                             aiRecommendations[index] = editedRec;
//                             isEditing = false;
//                             errors = {};
//                           });
//                         }
//                       },
//                       icon: const Icon(Icons.save),
//                       label: const Text('Save'),
//                     ),
//                     const SizedBox(width: 8),
//                     TextButton(
//                       onPressed: () => setState(() {
//                         isEditing = false;
//                         errors = {};
//                       }),
//                       child: const Text('Cancel'),
//                     ),
//                   ],
//                 ),
//               ],
//             )
//                 : Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Recommendation #${index + 1} - ${rec.type} (Priority: ${rec.priority})',
//                   style:
//                   const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
//                 ),
//                 Text(
//                   rec.recommendation,
//                   style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                 ),
//                 Text(
//                   rec.details,
//                   style: const TextStyle(fontSize: 14, color: Colors.grey),
//                 ),
//                 Text(
//                   'Expected Impact: ${rec.expectedImpact}',
//                   style: const TextStyle(fontSize: 12, color: Colors.grey),
//                 ),
//                 if (rec.suggestedChanges.isNotEmpty)
//                   Container(
//                     margin: const EdgeInsets.only(top: 8),
//                     padding: const EdgeInsets.all(8),
//                     color: Colors.grey[100],
//                     child: Text(
//                       'Suggested Changes: ${rec.suggestedChanges.toString()}',
//                       style: const TextStyle(fontSize: 14),
//                     ),
//                   ),
//                 if (errors['api'] != null)
//                   Text(
//                     errors['api']!,
//                     style: const TextStyle(color: Colors.red, fontSize: 12),
//                   ),
//                 Row(
//                   children: [
//                     ElevatedButton.icon(
//                       onPressed: isApproved
//                           ? null
//                           : () async {
//                         validateFields();
//                         if (errors.isEmpty) {
//                           final projectId = await projectIdFuture;
//                           try {
//                             await createRecommendation(editedRec, projectId);
//                             setState(() {
//                               approvedIds.add(index);
//                               aiRecommendations[index] = editedRec;
//                             });
//                             await handleAfterDeleteRecommendation();
//                           } catch (e) {
//                             setState(() {
//                               errors['api'] = 'Failed to save recommendation. Please try again.';
//                             });
//                           }
//                         }
//                       },
//                       icon: const Icon(Icons.check_circle),
//                       label: const Text('Approve'),
//                       style: ElevatedButton.styleFrom(
//                         foregroundColor: Colors.white,
//                         backgroundColor: Colors.green,
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     ElevatedButton.icon(
//                       onPressed: isApproved
//                           ? null
//                           : () => setState(() {
//                         isEditing = true;
//                         editedRec = rec;
//                         errors = {};
//                       }),
//                       icon: const Icon(Icons.edit),
//                       label: const Text('Edit'),
//                       style: ElevatedButton.styleFrom(
//                         foregroundColor: Colors.white,
//                         backgroundColor: Colors.blue,
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     ElevatedButton.icon(
//                       onPressed: isApproved
//                           ? null
//                           : () async {
//                         final confirmed = await confirm(
//                             context, 'Are you sure you want to delete this recommendation?');
//                         if (confirmed) {
//                           setState(() {
//                             aiRecommendations.removeAt(index);
//                             approvedIds.remove(index);
//                           });
//                           await handleAfterDeleteRecommendation();
//                         }
//                       },
//                       icon: const Icon(Icons.delete),
//                       label: const Text('Delete'),
//                       style: ElevatedButton.styleFrom(
//                         foregroundColor: Colors.white,
//                         backgroundColor: Colors.red,
//                       ),
//                     ),
//                     if (isApproved)
//                       const Padding(
//                         padding: EdgeInsets.only(left: 8),
//                         child: Text(
//                           'Approved',
//                           style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
//                         ),
//                       ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// ----
// import 'dart:async';
// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
// import '../../Helper/UriHelper.dart';
// import './HealthOverview.dart';
// import './ProgressPerSprint.dart';
// import './TimeComparisonChart.dart';
// import './CostBarChart.dart';
// import './WorkloadChart.dart';
// import './TaskStatusChart.dart';
//
// double _toDouble(dynamic value) {
//   if (value == null) return 0.0;
//   if (value is num) return value.toDouble();
//   if (value is String) {
//     try {
//       return double.parse(value);
//     } catch (e) {
//       print('Error parsing double from string: $value');
//       return 0.0;
//     }
//   }
//   print('Unexpected type for double field: ${value.runtimeType}');
//   return 0.0;
// }
//
// // Data models
// class AIRecommendationDTO {
//   final int? id;
//   final String recommendation;
//   final String details;
//   final String type;
//   final List<String> affectedTasks;
//   final String? suggestedTask;
//   final String expectedImpact;
//   final String suggestedChanges;
//   final int priority;
//
//   AIRecommendationDTO({
//     this.id,
//     required this.recommendation,
//     required this.details,
//     required this.type,
//     required this.affectedTasks,
//     this.suggestedTask,
//     required this.expectedImpact,
//     required this.suggestedChanges,
//     required this.priority,
//   });
//
//   factory AIRecommendationDTO.fromJson(Map<String, dynamic> json) {
//     return AIRecommendationDTO(
//       id: (json['id'] is num) ? json['id']?.toInt() : json['id'],
//       recommendation: json['recommendation'] ?? '',
//       details: json['details'] ?? '',
//       type: json['type'] ?? '',
//       affectedTasks: List<String>.from(json['affectedTasks'] ?? []),
//       suggestedTask: json['suggestedTask'],
//       expectedImpact: json['expectedImpact'] ?? '',
//       suggestedChanges: json['suggestedChanges'] ?? '',
//       priority: (json['priority'] is num) ? json['priority'].toInt() : (json['priority'] ?? 0),
//     );
//   }
// }
//
// class HealthDashboardResponse {
//   final bool isSuccess;
//   final int code;
//   final String message;
//   final HealthData data;
//
//   HealthDashboardResponse({
//     required this.isSuccess,
//     required this.code,
//     required this.message,
//     required this.data,
//   });
//
//   factory HealthDashboardResponse.fromJson(Map<String, dynamic> json) {
//     return HealthDashboardResponse(
//       isSuccess: json['isSuccess'] ?? false,
//       code: (json['code'] is num) ? json['code'].toInt() : json['code'],
//       message: json['message'] ?? '',
//       data: HealthData.fromJson(json['data']),
//     );
//   }
// }
//
// class ProjectMetricData {
//   final int projectId;
//   final double plannedValue;
//   final double earnedValue;
//   final double actualCost;
//   final double budgetAtCompletion;
//   final double durationAtCompletion;
//   final double costVariance;
//   final double scheduleVariance;
//   final double costPerformanceIndex;
//   final double schedulePerformanceIndex;
//   final double estimateAtCompletion;
//   final double estimateToComplete;
//   final double varianceAtCompletion;
//   final double estimateDurationAtCompletion;
//   final String calculatedBy;
//   final String createdAt;
//   final String updatedAt;
//   final bool isImproved;
//   final String improvementSummary;
//   final double confidenceScore;
//
//   ProjectMetricData({
//     required this.projectId,
//     required this.plannedValue,
//     required this.earnedValue,
//     required this.actualCost,
//     required this.budgetAtCompletion,
//     required this.durationAtCompletion,
//     required this.costVariance,
//     required this.scheduleVariance,
//     required this.costPerformanceIndex,
//     required this.schedulePerformanceIndex,
//     required this.estimateAtCompletion,
//     required this.estimateToComplete,
//     required this.varianceAtCompletion,
//     required this.estimateDurationAtCompletion,
//     required this.calculatedBy,
//     required this.createdAt,
//     required this.updatedAt,
//     this.isImproved = false,
//     this.improvementSummary = '',
//     this.confidenceScore = 0.0,
//   });
//
//   factory ProjectMetricData.fromJson(Map<String, dynamic> json) {
//     return ProjectMetricData(
//       projectId: json['projectId'],
//       plannedValue: (json['plannedValue'] ?? 0).toDouble(),
//       earnedValue: (json['earnedValue'] ?? 0).toDouble(),
//       actualCost: (json['actualCost'] ?? 0).toDouble(),
//       budgetAtCompletion: (json['budgetAtCompletion'] ?? 0).toDouble(),
//       durationAtCompletion: (json['durationAtCompletion'] ?? 0).toDouble(),
//       costVariance: (json['costVariance'] ?? 0).toDouble(),
//       scheduleVariance: (json['scheduleVariance'] ?? 0).toDouble(),
//       costPerformanceIndex: (json['costPerformanceIndex'] ?? 0).toDouble(),
//       schedulePerformanceIndex: (json['schedulePerformanceIndex'] ?? 0)
//           .toDouble(),
//       estimateAtCompletion: (json['estimateAtCompletion'] ?? 0).toDouble(),
//       estimateToComplete: (json['estimateToComplete'] ?? 0).toDouble(),
//       varianceAtCompletion: (json['varianceAtCompletion'] ?? 0).toDouble(),
//       estimateDurationAtCompletion: (json['estimateDurationAtCompletion'] ?? 0)
//           .toDouble(),
//       calculatedBy: json['calculatedBy'] ?? '',
//       createdAt: json['createdAt'] ?? '',
//       updatedAt: json['updatedAt'] ?? '',
//       isImproved: json['isImproved'] ?? false,
//       improvementSummary: json['improvementSummary'] ?? '',
//       confidenceScore: (json['confidenceScore'] ?? 0).toDouble(),
//     );
//   }
// }
//
// class HealthData {
//   final String projectStatus;
//   final String timeStatus;
//   final int tasksToBeCompleted;
//   final int overdueTasks;
//   final double progressPercent;
//   final double costStatus;
//   final ProjectMetricData cost;
//   final bool showAlert;
//
//   HealthData({
//     required this.projectStatus,
//     required this.timeStatus,
//     required this.tasksToBeCompleted,
//     required this.overdueTasks,
//     required this.progressPercent,
//     required this.costStatus,
//     required this.cost,
//     required this.showAlert,
//   });
//
//   factory HealthData.fromJson(Map<String, dynamic> json) {
//     return HealthData(
//       projectStatus: json['projectStatus'],
//       timeStatus: json['timeStatus'],
//       tasksToBeCompleted: json['tasksToBeCompleted'],
//       overdueTasks: json['overdueTasks'],
//       progressPercent: (json['progressPercent'] ?? 0).toDouble(),
//       costStatus: json['costStatus'],
//       cost: ProjectMetricData.fromJson(json['cost']),
//       showAlert: json['showAlert'],
//     );
//   }
//
//
// }
//
// class TaskStatusItem {
//   final int key;
//   final String name;
//   final int count;
//
//   TaskStatusItem({
//     required this.key,
//     required this.name,
//     required this.count,
//   });
//
//   factory TaskStatusItem.fromJson(Map<String, dynamic> json) {
//     return TaskStatusItem(
//       key: (json['key'] is num) ? json['key'].toInt() : json['key'],
//       name: json['name'] ?? '',
//       count: (json['count'] is num) ? json['count'].toInt() : json['count'],
//     );
//   }
// }
//
// class TaskStatusDashboardResponse {
//   final bool isSuccess;
//   final int code;
//   final String message;
//   final List<TaskStatusItem> statusCounts;
//
//   TaskStatusDashboardResponse({
//     required this.isSuccess,
//     required this.code,
//     required this.message,
//     required this.statusCounts,
//   });
//
//   factory TaskStatusDashboardResponse.fromJson(Map<String, dynamic> json) {
//     return TaskStatusDashboardResponse(
//       isSuccess: json['isSuccess'] ?? false,
//       code: (json['code'] is num) ? json['code'].toInt() : json['code'],
//       message: json['message'] ?? '',
//       statusCounts: (json['data']['statusCounts'] as List? ?? []).map((e) => TaskStatusItem.fromJson(e)).toList(),
//     );
//   }
// }
//
// class ProgressItem {
//   final int sprintId;
//   final String sprintName;
//   final double percentComplete;
//
//   ProgressItem({
//     required this.sprintId,
//     required this.sprintName,
//     required this.percentComplete,
//   });
//
//   factory ProgressItem.fromJson(Map<String, dynamic> json) {
//     return ProgressItem(
//       sprintId: (json['sprintId'] is num) ? json['sprintId'].toInt() : json['sprintId'],
//       sprintName: json['sprintName'] ?? '',
//       percentComplete: (json['percentComplete'] ?? 0).toDouble(),
//     );
//   }
// }
//
// class ProgressDashboardResponse {
//   final bool isSuccess;
//   final int code;
//   final String message;
//   final List<ProgressItem> data;
//
//   ProgressDashboardResponse({
//     required this.isSuccess,
//     required this.code,
//     required this.message,
//     required this.data,
//   });
//
//   factory ProgressDashboardResponse.fromJson(Map<String, dynamic> json) {
//     return ProgressDashboardResponse(
//       isSuccess: json['isSuccess'] ?? false,
//       code: (json['code'] is num) ? json['code'].toInt() : json['code'],
//       message: json['message'] ?? '',
//       data: (json['data'] as List? ?? []).map((e) => ProgressItem.fromJson(e)).toList(),
//     );
//   }
// }
//
// class TimeDashboardResponse {
//   final bool isSuccess;
//   final int code;
//   final String message;
//   final TimeData data;
//
//   TimeDashboardResponse({
//     required this.isSuccess,
//     required this.code,
//     required this.message,
//     required this.data,
//   });
//
//   factory TimeDashboardResponse.fromJson(Map<String, dynamic> json) {
//     return TimeDashboardResponse(
//       isSuccess: json['isSuccess'] ?? false,
//       code: (json['code'] is num) ? json['code'].toInt() : json['code'],
//       message: json['message'] ?? '',
//       data: TimeData.fromJson(json['data']),
//     );
//   }
// }
//
// class TimeData {
//   final double plannedCompletion;
//   final double actualCompletion;
//   final String status;
//
//   TimeData({
//     required this.plannedCompletion,
//     required this.actualCompletion,
//     required this.status,
//   });
//
//   factory TimeData.fromJson(Map<String, dynamic> json) {
//     return TimeData(
//       plannedCompletion: (json['plannedCompletion'] ?? 0).toDouble(),
//       actualCompletion: (json['actualCompletion'] ?? 0).toDouble(),
//       status: json['status'] ?? '',
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
//       memberName: json['memberName'] ?? '',
//       completed: (json['completed'] is num) ? json['completed'].toInt() : json['completed'],
//       remaining: (json['remaining'] is num) ? json['remaining'].toInt() : json['remaining'],
//       overdue: (json['overdue'] is num) ? json['overdue'].toInt() : json['overdue'],
//     );
//   }
// }
//
// class WorkloadDashboardResponse {
//   final bool isSuccess;
//   final int code;
//   final String message;
//   final List<WorkloadMember> data;
//
//   WorkloadDashboardResponse({
//     required this.isSuccess,
//     required this.code,
//     required this.message,
//     required this.data,
//   });
//
//   factory WorkloadDashboardResponse.fromJson(Map<String, dynamic> json) {
//     return WorkloadDashboardResponse(
//       isSuccess: json['isSuccess'] ?? false,
//       code: (json['code'] is num) ? json['code'].toInt() : json['code'],
//       message: json['message'] ?? '',
//       data: (json['data'] as List? ?? []).map((e) => WorkloadMember.fromJson(e)).toList(),
//     );
//   }
// }
//
// class CostDashboardResponse {
//   final bool isSuccess;
//   final int code;
//   final String message;
//   final CostData data;
//
//   CostDashboardResponse({
//     required this.isSuccess,
//     required this.code,
//     required this.message,
//     required this.data,
//   });
//
//   factory CostDashboardResponse.fromJson(Map<String, dynamic> json) {
//     return CostDashboardResponse(
//       isSuccess: json['isSuccess'] ?? false,
//       code: (json['code'] is num) ? json['code'].toInt() : json['code'],
//       message: json['message'] ?? '',
//       data: CostData.fromJson(json['data']),
//     );
//   }
// }
//
// class CostData {
//   final double actualCost;
//   final double actualTaskCost;
//   final double actualResourceCost;
//   final double plannedCost;
//   final double plannedTaskCost;
//   final double plannedResourceCost;
//   final double budget;
//
//   CostData({
//     required this.actualCost,
//     required this.actualTaskCost,
//     required this.actualResourceCost,
//     required this.plannedCost,
//     required this.plannedTaskCost,
//     required this.plannedResourceCost,
//     required this.budget,
//   });
//
//   factory CostData.fromJson(Map<String, dynamic> json) {
//     return CostData(
//       actualCost: (json['actualCost'] ?? 0).toDouble(),
//       actualTaskCost: (json['actualTaskCost'] ?? 0).toDouble(),
//       actualResourceCost: (json['actualResourceCost'] ?? 0).toDouble(),
//       plannedCost: (json['plannedCost'] ?? 0).toDouble(),
//       plannedTaskCost: (json['plannedTaskCost'] ?? 0).toDouble(),
//       plannedResourceCost: (json['plannedResourceCost'] ?? 0).toDouble(),
//       budget: (json['budget'] ?? 0).toDouble(),
//     );
//   }
// }
//
// // Extension for AIRecommendationDTO to support copyWith
// extension AIRecommendationDTOExtension on AIRecommendationDTO {
//   AIRecommendationDTO copyWith({
//     int? id,
//     String? recommendation,
//     String? details,
//     String? type,
//     List<String>? affectedTasks,
//     String? suggestedTask,
//     String? expectedImpact,
//     String? suggestedChanges,
//     int? priority,
//   }) {
//     return AIRecommendationDTO(
//       id: id ?? this.id,
//       recommendation: recommendation ?? this.recommendation,
//       details: details ?? this.details,
//       type: type ?? this.type,
//       affectedTasks: affectedTasks ?? this.affectedTasks,
//       suggestedTask: suggestedTask ?? this.suggestedTask,
//       expectedImpact: expectedImpact ?? this.expectedImpact,
//       suggestedChanges: suggestedChanges ?? this.suggestedChanges,
//       priority: priority ?? this.priority,
//     );
//   }
// }
//
// class DashboardPage extends StatefulWidget {
//   final String projectKey;
//
//   const DashboardPage({Key? key, required this.projectKey}) : super(key: key);
//
//   @override
//   _DashboardPageState createState() => _DashboardPageState();
// }
//
// class _DashboardPageState extends State<DashboardPage> {
//   late Future<HealthDashboardResponse> healthFuture;
//   late Future<TaskStatusDashboardResponse> taskStatusFuture;
//   late Future<ProgressDashboardResponse> progressFuture;
//   late Future<TimeDashboardResponse> timeFuture;
//   late Future<CostDashboardResponse> costFuture;
//   late Future<WorkloadDashboardResponse> workloadFuture;
//   late Future<List<AIRecommendationDTO>> recommendationsFuture;
//   bool showRecommendations = false;
//   bool isRecLoading = false;
//   bool isCalculateDone = false;
//   List<AIRecommendationDTO> aiRecommendations = [];
//   List<int> approvedIds = [];
//   String aiResponseJson = '';
//   bool isEvaluationPopupOpen = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeFutures();
//     _calculateAndRefetch();
//   }
//
//   void _initializeFutures() {
//     healthFuture = fetchHealthDashboard(widget.projectKey);
//     taskStatusFuture = fetchTaskStatusDashboard(widget.projectKey);
//     progressFuture = fetchProgressDashboard(widget.projectKey);
//     timeFuture = fetchTimeDashboard(widget.projectKey);
//     costFuture = fetchCostDashboard(widget.projectKey);
//     workloadFuture = fetchWorkloadDashboard(widget.projectKey);
//     recommendationsFuture = fetchRecommendations(widget.projectKey);
//   }
//
//   Future<void> _calculateAndRefetch() async {
//     setState(() {
//       isCalculateDone = false;
//     });
//     try {
//       await calculateMetricsBySystem(widget.projectKey);
//       _initializeFutures();
//       setState(() {
//         isCalculateDone = true;
//       });
//     } catch (e) {
//       print('Error calculating metrics: $e');
//       _initializeFutures(); // Load existing data even if calculation fails
//       setState(() {
//         isCalculateDone = true;
//       });
//     }
//   }
//
//   Future<void> calculateMetricsBySystem(String projectKey) async {
//     final uri = UriHelper.build('/projectmetric/calculate-by-system?projectKey=$projectKey');
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('accessToken') ?? '';
//
//     print('Calling calculateMetricsBySystem with URI: $uri');
//     print('Access Token: $token');
//
//     if (token.isEmpty) {
//       throw Exception('No access token found. Please log in again.');
//     }
//
//     try {
//       final response = await http.post(
//         uri,
//         headers: {
//           "Content-Type": "application/json",
//           'Authorization': 'Bearer $token',
//         },
//         body: jsonEncode({}), // Empty body, adjust if API requires specific fields
//       ).timeout(Duration(seconds: 10));
//
//       print('Response Status Code: ${response.statusCode}');
//       print('Response Body: ${response.body}');
//
//       if (response.statusCode != 200) {
//         String errorMessage = response.body;
//         try {
//           final json = jsonDecode(response.body);
//           errorMessage = json['message'] ?? response.body;
//         } catch (_) {}
//         throw Exception('Failed to calculate metrics: ${response.statusCode} - $errorMessage');
//       }
//     } on SocketException catch (e) {
//       throw Exception('Network error: Unable to reach server. Please check your connection.');
//     } on TimeoutException catch (e) {
//       throw Exception('Request timed out. Please try again later.');
//     } catch (e) {
//       print('Error in calculateMetricsBySystem: $e');
//       rethrow;
//     }
//   }
//
//   Future<HealthDashboardResponse> fetchHealthDashboard(String projectKey) async {
//     final uri = UriHelper.build('/projectmetric/health-dashboard?projectKey=$projectKey');
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('accessToken') ?? '';
//
//     final response = await http.get(
//       uri,
//       headers: {
//         "Content-Type": "application/json",
//         'Authorization': 'Bearer $token',
//       },
//     );
//
//     if (response.statusCode == 200) {
//       return HealthDashboardResponse.fromJson(json.decode(response.body));
//     } else {
//       throw Exception('Failed to load health dashboard');
//     }
//   }
//
//   Future<TaskStatusDashboardResponse> fetchTaskStatusDashboard(String projectKey) async {
//     final uri = UriHelper.build('/projectmetric/tasks-dashboard?projectKey=$projectKey');
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('accessToken') ?? '';
//
//     final response = await http.get(
//       uri,
//       headers: {
//         "Content-Type": "application/json",
//         'Authorization': 'Bearer $token',
//       },
//     );
//
//     if (response.statusCode == 200) {
//       return TaskStatusDashboardResponse.fromJson(json.decode(response.body));
//     } else {
//       throw Exception('Failed to load task status dashboard');
//     }
//   }
//
//   Future<ProgressDashboardResponse> fetchProgressDashboard(String projectKey) async {
//     final uri = UriHelper.build('/projectmetric/progress-dashboard?projectKey=$projectKey');
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('accessToken') ?? '';
//
//     final response = await http.get(
//       uri,
//       headers: {
//         "Content-Type": "application/json",
//         'Authorization': 'Bearer $token',
//       },
//     );
//
//     if (response.statusCode == 200) {
//       return ProgressDashboardResponse.fromJson(json.decode(response.body));
//     } else {
//       throw Exception('Failed to load progress dashboard');
//     }
//   }
//
//   Future<TimeDashboardResponse> fetchTimeDashboard(String projectKey) async {
//     final uri = UriHelper.build('/projectmetric/time-dashboard?projectKey=$projectKey');
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('accessToken') ?? '';
//
//     final response = await http.get(
//       uri,
//       headers: {
//         "Content-Type": "application/json",
//         'Authorization': 'Bearer $token',
//       },
//     );
//
//     if (response.statusCode == 200) {
//       return TimeDashboardResponse.fromJson(json.decode(response.body));
//     } else {
//       throw Exception('Failed to load time dashboard');
//     }
//   }
//
//   Future<CostDashboardResponse> fetchCostDashboard(String projectKey) async {
//     final uri = UriHelper.build('/projectmetric/cost-dashboard?projectKey=$projectKey');
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('accessToken') ?? '';
//
//     final response = await http.get(
//       uri,
//       headers: {
//         "Content-Type": "application/json",
//         'Authorization': 'Bearer $token',
//       },
//     );
//
//     if (response.statusCode == 200) {
//       return CostDashboardResponse.fromJson(json.decode(response.body));
//     } else {
//       throw Exception('Failed to load cost dashboard');
//     }
//   }
//
//   Future<WorkloadDashboardResponse> fetchWorkloadDashboard(String projectKey) async {
//     final uri = UriHelper.build('/projectmetric/workload-dashboard?projectKey=$projectKey');
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('accessToken') ?? '';
//
//     final response = await http.get(
//       uri,
//       headers: {
//         "Content-Type": "application/json",
//         'Authorization': 'Bearer $token',
//       },
//     );
//
//     if (response.statusCode == 200) {
//       return WorkloadDashboardResponse.fromJson(json.decode(response.body));
//     } else {
//       throw Exception('Failed to load workload dashboard');
//     }
//   }
//
//   Future<List<AIRecommendationDTO>> fetchRecommendations(String projectKey) async {
//     final uri = UriHelper.build('/projectrecommendation/ai-recommendations?projectKey=$projectKey');
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('accessToken') ?? '';
//
//     final response = await http.get(
//       uri,
//       headers: {
//         "Content-Type": "application/json",
//         'Authorization': 'Bearer $token',
//       },
//     );
//
//     if (response.statusCode == 200) {
//       final json = jsonDecode(response.body);
//       final List data = json['data'] ?? [];
//       return data.map((e) => AIRecommendationDTO.fromJson(e)).toList();
//     } else {
//       throw Exception('Failed to load AI Recommendations');
//     }
//   }
//
//   Future<void> createRecommendation(AIRecommendationDTO rec, int projectId) async {
//     final uri = UriHelper.build('/projectrecommendation');
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('accessToken') ?? '';
//
//     final response = await http.post(
//       uri,
//       headers: {
//         "Content-Type": "application/json",
//         'Authorization': 'Bearer $token',
//       },
//       body: jsonEncode({
//         'projectId': projectId,
//         'type': rec.type,
//         'recommendation': rec.recommendation,
//         'details': rec.details,
//         'suggestedChanges': rec.suggestedChanges,
//       }),
//     );
//
//     if (response.statusCode != 200) {
//       throw Exception('Failed to save recommendation');
//     }
//   }
//
//   Future<void> fetchRecommendationsFromAPI(String projectKey) async {
//     setState(() {
//       isRecLoading = true;
//       showRecommendations = true;
//     });
//
//     try {
//       final recs = await fetchRecommendations(projectKey);
//       setState(() {
//         aiRecommendations = recs;
//       });
//     } catch (e) {
//       print("Failed to fetch recommendations: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to fetch recommendations: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       setState(() {
//         isRecLoading = false;
//       });
//     }
//   }
//
//   Future<void> handleAfterDeleteRecommendation() async {
//     try {
//       recommendationsFuture = fetchRecommendations(widget.projectKey);
//       setState(() {});
//     } catch (e) {
//       print('Error after deleting recommendation: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error after deleting recommendation: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }
//
//   Future<void> handleEvaluationSubmitSuccess() async {
//     try {
//       recommendationsFuture = fetchRecommendations(widget.projectKey);
//       setState(() {
//         isEvaluationPopupOpen = false;
//         aiResponseJson = '';
//       });
//     } catch (e) {
//       print('Error handling evaluation submit: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error handling evaluation submit: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }
//
//   Future<bool> confirm(BuildContext context, String message) async {
//     bool confirmed = false;
//     await showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Confirm'),
//         content: Text(message),
//         actions: [
//           TextButton(
//             onPressed: () {
//               confirmed = false;
//               Navigator.of(context).pop();
//             },
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               confirmed = true;
//               Navigator.of(context).pop();
//             },
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//     return confirmed;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F6F8),
//       appBar: AppBar(
//         title: Text('Dashboard - ${widget.projectKey}'),
//         backgroundColor: Colors.blue,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.lightbulb_outline),
//             onPressed: isRecLoading ? null : () => fetchRecommendationsFromAPI(widget.projectKey),
//             tooltip: 'View AI Suggestions',
//           ),
//         ],
//       ),
//       body: FutureBuilder<List<dynamic>>(
//         future: Future.wait([
//           healthFuture,
//           taskStatusFuture,
//           progressFuture,
//           timeFuture,
//           costFuture,
//           workloadFuture,
//           recommendationsFuture,
//         ]),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting || !isCalculateDone) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text("Error: ${snapshot.error}"));
//           } else {
//             final health = snapshot.data![0] as HealthDashboardResponse;
//             final taskStatus = snapshot.data![1] as TaskStatusDashboardResponse;
//             final progress = snapshot.data![2] as ProgressDashboardResponse;
//             final time = snapshot.data![3] as TimeDashboardResponse;
//             final cost = snapshot.data![4] as CostDashboardResponse;
//             final workload = snapshot.data![5] as WorkloadDashboardResponse;
//             final recommendations = snapshot.data![6] as List<AIRecommendationDTO>;
//
//             return ListView(
//               padding: const EdgeInsets.all(16),
//               children: [
//                 // Health Overview
//                 Card(
//                   elevation: 2,
//                   child: Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'Health Overview',
//                           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                         ),
//                         const SizedBox(height: 8),
//                         HealthOverview(data: health),
//                       ],
//                     ),
//                   ),
//                 ),
//                 // Task Status
//                 Card(
//                   elevation: 2,
//                   child: Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'Task Status',
//                           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                         ),
//                         const SizedBox(height: 8),
//                         TaskStatusChart(data: taskStatus),
//                       ],
//                     ),
//                   ),
//                 ),
//                 // Progress Per Sprint
//                 Card(
//                   elevation: 2,
//                   child: Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'Progress Per Sprint',
//                           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                         ),
//                         const SizedBox(height: 8),
//                         ProgressPerSprint(data: progress),
//                       ],
//                     ),
//                   ),
//                 ),
//                 // Time Tracking
//                 Card(
//                   elevation: 2,
//                   child: Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'Time Tracking',
//                           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                         ),
//                         const SizedBox(height: 8),
//                         TimeComparisonChart(data: time),
//                       ],
//                     ),
//                   ),
//                 ),
//                 // Cost
//                 Card(
//                   elevation: 2,
//                   child: Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'Cost',
//                           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                         ),
//                         const SizedBox(height: 8),
//                         CostBarChart(data: cost),
//                       ],
//                     ),
//                   ),
//                 ),
//                 // Workload
//                 Card(
//                   elevation: 2,
//                   child: Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'Workload',
//                           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                         ),
//                         const SizedBox(height: 8),
//                         WorkloadChart(data: workload),
//                       ],
//                     ),
//                   ),
//                 ),
//                 // AI Recommendations Dialog
//                 if (showRecommendations)
//                   _buildRecommendationsDialog(),
//               ],
//             );
//           }
//         },
//       ),
//     );
//   }
//
//   Widget _buildRecommendationsDialog() {
//     return Dialog(
//       backgroundColor: Colors.white,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'AI Suggestions',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.close),
//                   onPressed: () => setState(() {
//                     showRecommendations = false;
//                     aiResponseJson = jsonEncode(aiRecommendations);
//                     isEvaluationPopupOpen = true;
//                   }),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             if (isRecLoading)
//               const Center(child: CircularProgressIndicator())
//             else if (aiRecommendations.isNotEmpty)
//               Flexible(
//                 child: ListView.builder(
//                   shrinkWrap: true,
//                   itemCount: aiRecommendations.length,
//                   itemBuilder: (context, index) {
//                     return _buildRecommendationCard(
//                         aiRecommendations[index], index);
//                   },
//                 ),
//               )
//             else
//               const Text(
//                 'No AI suggestions available.',
//                 style: TextStyle(fontSize: 14, color: Colors.grey),
//               ),
//             if (aiRecommendations.isNotEmpty)
//               Padding(
//                 padding: const EdgeInsets.only(top: 8),
//                 child: ElevatedButton.icon(
//                   onPressed: () async {
//                     setState(() {
//                       aiResponseJson = jsonEncode(aiRecommendations);
//                       isEvaluationPopupOpen = true;
//                       showRecommendations = false;
//                     });
//                     await handleEvaluationSubmitSuccess();
//                   },
//                   icon: const Icon(Icons.save),
//                   label: const Text('Done'),
//                   style: ElevatedButton.styleFrom(
//                     foregroundColor: Colors.white,
//                     backgroundColor: Colors.blue,
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildRecommendationCard(AIRecommendationDTO rec, int index) {
//     bool isApproved = approvedIds.contains(index);
//     bool isEditing = false;
//     AIRecommendationDTO editedRec = rec;
//     Map<String, String> errors = {};
//
//     return StatefulBuilder(
//       builder: (context, setState) {
//         void validateFields() {
//           final newErrors = <String, String>{};
//           if (editedRec.recommendation.trim().isEmpty) {
//             newErrors['recommendation'] = 'Recommendation is required';
//           }
//           if (!['SCHEDULE', 'COST'].contains(editedRec.type.toUpperCase())) {
//             newErrors['type'] = 'Valid type is required';
//           }
//           errors = newErrors;
//         }
//
//         return Card(
//           elevation: 2,
//           margin: const EdgeInsets.symmetric(vertical: 8),
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: isEditing
//                 ? Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 TextField(
//                   decoration: InputDecoration(
//                     labelText: 'Recommendation',
//                     errorText: errors['recommendation'],
//                   ),
//                   onChanged: (value) => editedRec = editedRec.copyWith(recommendation: value),
//                 ),
//                 DropdownButton<String>(
//                   value: editedRec.type,
//                   items: ['SCHEDULE', 'COST']
//                       .map((type) => DropdownMenuItem(
//                     value: type,
//                     child: Text(type),
//                   ))
//                       .toList(),
//                   onChanged: (value) => setState(() {
//                     editedRec = editedRec.copyWith(type: value!);
//                   }),
//                   hint: const Text('Select type'),
//                 ),
//                 if (errors['type'] != null)
//                   Text(
//                     errors['type']!,
//                     style: const TextStyle(color: Colors.red, fontSize: 12),
//                   ),
//                 TextField(
//                   decoration: const InputDecoration(labelText: 'Details'),
//                   maxLines: 4,
//                   onChanged: (value) => editedRec = editedRec.copyWith(details: value),
//                 ),
//                 TextField(
//                   decoration: const InputDecoration(labelText: 'Suggested Changes'),
//                   onChanged: (value) =>
//                   editedRec = editedRec.copyWith(suggestedChanges: value),
//                 ),
//                 if (errors['api'] != null)
//                   Text(
//                     errors['api']!,
//                     style: const TextStyle(color: Colors.red, fontSize: 12),
//                   ),
//                 Row(
//                   children: [
//                     ElevatedButton.icon(
//                       onPressed: () async {
//                         validateFields();
//                         if (errors.isEmpty) {
//                           setState(() {
//                             aiRecommendations[index] = editedRec;
//                             isEditing = false;
//                             errors = {};
//                           });
//                         }
//                       },
//                       icon: const Icon(Icons.save),
//                       label: const Text('Save'),
//                     ),
//                     const SizedBox(width: 8),
//                     TextButton(
//                       onPressed: () => setState(() {
//                         isEditing = false;
//                         errors = {};
//                       }),
//                       child: const Text('Cancel'),
//                     ),
//                   ],
//                 ),
//               ],
//             )
//                 : Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Recommendation #${index + 1} - ${rec.type} (Priority: ${rec.priority})',
//                   style:
//                   const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
//                 ),
//                 Text(
//                   rec.recommendation,
//                   style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                 ),
//                 Text(
//                   rec.details,
//                   style: const TextStyle(fontSize: 14, color: Colors.grey),
//                 ),
//                 Text(
//                   'Expected Impact: ${rec.expectedImpact}',
//                   style: const TextStyle(fontSize: 12, color: Colors.grey),
//                 ),
//                 if (rec.suggestedChanges.isNotEmpty)
//                   Container(
//                     margin: const EdgeInsets.only(top: 8),
//                     padding: const EdgeInsets.all(8),
//                     color: Colors.grey[100],
//                     child: Text(
//                       'Suggested Changes: ${rec.suggestedChanges.toString()}',
//                       style: const TextStyle(fontSize: 14),
//                     ),
//                   ),
//                 if (errors['api'] != null)
//                   Text(
//                     errors['api']!,
//                     style: const TextStyle(color: Colors.red, fontSize: 12),
//                   ),
//                 Row(
//                   children: [
//                     ElevatedButton.icon(
//                       onPressed: isApproved
//                           ? null
//                           : () async {
//                         validateFields();
//                         if (errors.isEmpty) {
//                           try {
//                             await createRecommendation(editedRec, 1); // Placeholder projectId
//                             setState(() {
//                               approvedIds.add(index);
//                               aiRecommendations[index] = editedRec;
//                             });
//                             await handleAfterDeleteRecommendation();
//                           } catch (e) {
//                             setState(() {
//                               errors['api'] = 'Failed to save recommendation. Please try again.';
//                             });
//                           }
//                         }
//                       },
//                       icon: const Icon(Icons.check_circle),
//                       label: const Text('Approve'),
//                       style: ElevatedButton.styleFrom(
//                         foregroundColor: Colors.white,
//                         backgroundColor: Colors.green,
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     ElevatedButton.icon(
//                       onPressed: isApproved
//                           ? null
//                           : () => setState(() {
//                         isEditing = true;
//                         editedRec = rec;
//                         errors = {};
//                       }),
//                       icon: const Icon(Icons.edit),
//                       label: const Text('Edit'),
//                       style: ElevatedButton.styleFrom(
//                         foregroundColor: Colors.white,
//                         backgroundColor: Colors.blue,
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     ElevatedButton.icon(
//                       onPressed: isApproved
//                           ? null
//                           : () async {
//                         final confirmed = await confirm(
//                             context, 'Are you sure you want to delete this recommendation?');
//                         if (confirmed) {
//                           setState(() {
//                             aiRecommendations.removeAt(index);
//                             approvedIds.remove(index);
//                           });
//                           await handleAfterDeleteRecommendation();
//                         }
//                       },
//                       icon: const Icon(Icons.delete),
//                       label: const Text('Delete'),
//                       style: ElevatedButton.styleFrom(
//                         foregroundColor: Colors.white,
//                         backgroundColor: Colors.red,
//                       ),
//                     ),
//                     if (isApproved)
//                       const Padding(
//                         padding: EdgeInsets.only(left: 8),
//                         child: Text(
//                           'Approved',
//                           style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
//                         ),
//                       ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//}



import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../Helper/UriHelper.dart';
import './HealthOverview.dart';
import './ProgressPerSprint.dart';
import './TimeComparisonChart.dart';
import './CostBarChart.dart';
import './WorkloadChart.dart';
import './TaskStatusChart.dart';

// Helper function to safely convert to double
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

// Data models
class AIRecommendationDTO {
  final int? id;
  final String recommendation;
  final String details;
  final String type;
  final List<String> affectedTasks;
  final String? suggestedTask;
  final String expectedImpact;
  final String suggestedChanges;
  final int priority;

  AIRecommendationDTO({
    this.id,
    required this.recommendation,
    required this.details,
    required this.type,
    required this.affectedTasks,
    this.suggestedTask,
    required this.expectedImpact,
    required this.suggestedChanges,
    required this.priority,
  });

  factory AIRecommendationDTO.fromJson(Map<String, dynamic> json) {
    return AIRecommendationDTO(
      id: (json['id'] is num) ? json['id']?.toInt() : json['id'],
      recommendation: json['recommendation'] ?? '',
      details: json['details'] ?? '',
      type: json['type'] ?? '',
      affectedTasks: List<String>.from(json['affectedTasks'] ?? []),
      suggestedTask: json['suggestedTask'],
      expectedImpact: json['expectedImpact'] ?? '',
      suggestedChanges: json['suggestedChanges'] ?? '',
      priority: (json['priority'] is num) ? json['priority'].toInt() : (json['priority'] ?? 0),
    );
  }
}

class HealthDashboardResponse {
  final bool isSuccess;
  final int code;
  final String message;
  final HealthData data;

  HealthDashboardResponse({
    required this.isSuccess,
    required this.code,
    required this.message,
    required this.data,
  });

  factory HealthDashboardResponse.fromJson(Map<String, dynamic> json) {
    print('Health Dashboard Response: $json');
    return HealthDashboardResponse(
      isSuccess: json['isSuccess'] ?? false,
      code: (json['code'] is num) ? json['code'].toInt() : (json['code'] ?? 0),
      message: json['message'] ?? '',
      data: HealthData.fromJson(json['data'] ?? {}),
    );
  }
}

class ProjectMetricData {
  final int projectId;
  final double plannedValue;
  final double earnedValue;
  final double actualCost;
  final double budgetAtCompletion;
  final double durationAtCompletion;
  final double costVariance;
  final double scheduleVariance;
  final double costPerformanceIndex;
  final double schedulePerformanceIndex;
  final double estimateAtCompletion;
  final double estimateToComplete;
  final double varianceAtCompletion;
  final double estimateDurationAtCompletion;
  final String calculatedBy;
  final String createdAt;
  final String updatedAt;
  final bool isImproved;
  final String improvementSummary;
  final double confidenceScore;

  ProjectMetricData({
    required this.projectId,
    required this.plannedValue,
    required this.earnedValue,
    required this.actualCost,
    required this.budgetAtCompletion,
    required this.durationAtCompletion,
    required this.costVariance,
    required this.scheduleVariance,
    required this.costPerformanceIndex,
    required this.schedulePerformanceIndex,
    required this.estimateAtCompletion,
    required this.estimateToComplete,
    required this.varianceAtCompletion,
    required this.estimateDurationAtCompletion,
    required this.calculatedBy,
    required this.createdAt,
    required this.updatedAt,
    this.isImproved = false,
    this.improvementSummary = '',
    this.confidenceScore = 0.0,
  });

  factory ProjectMetricData.fromJson(Map<String, dynamic> json) {
    return ProjectMetricData(
      projectId: (json['projectId'] is num) ? json['projectId'].toInt() : (json['projectId'] ?? 0),
      plannedValue: _toDouble(json['plannedValue']),
      earnedValue: _toDouble(json['earnedValue']),
      actualCost: _toDouble(json['actualCost']),
      budgetAtCompletion: _toDouble(json['budgetAtCompletion']),
      durationAtCompletion: _toDouble(json['durationAtCompletion']),
      costVariance: _toDouble(json['costVariance']),
      scheduleVariance: _toDouble(json['scheduleVariance']),
      costPerformanceIndex: _toDouble(json['costPerformanceIndex']),
      schedulePerformanceIndex: _toDouble(json['schedulePerformanceIndex']),
      estimateAtCompletion: _toDouble(json['estimateAtCompletion']),
      estimateToComplete: _toDouble(json['estimateToComplete']),
      varianceAtCompletion: _toDouble(json['varianceAtCompletion']),
      estimateDurationAtCompletion: _toDouble(json['estimateDurationAtCompletion']),
      calculatedBy: json['calculatedBy'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      isImproved: json['isImproved'] ?? false,
      improvementSummary: json['improvementSummary'] ?? '',
      confidenceScore: _toDouble(json['confidenceScore']),
    );
  }
}

class HealthData {
  final String projectStatus;
  final String timeStatus;
  final int tasksToBeCompleted;
  final int overdueTasks;
  final double progressPercent;
  final double costStatus;
  final ProjectMetricData cost;
  final bool showAlert;

  HealthData({
    required this.projectStatus,
    required this.timeStatus,
    required this.tasksToBeCompleted,
    required this.overdueTasks,
    required this.progressPercent,
    required this.costStatus,
    required this.cost,
    required this.showAlert,
  });

  factory HealthData.fromJson(Map<String, dynamic> json) {
    dynamic costData = json['cost'];
    if (costData is String) {
      try {
        costData = jsonDecode(costData);
      } catch (e) {
        print('Error decoding cost field: $e');
        costData = {};
      }
    }
    costData = costData is Map<String, dynamic> ? costData : {};

    return HealthData(
      projectStatus: json['projectStatus'] ?? '',
      timeStatus: json['timeStatus'] ?? '',
      tasksToBeCompleted: (json['tasksToBeCompleted'] is num) ? json['tasksToBeCompleted'].toInt() : (json['tasksToBeCompleted'] ?? 0),
      overdueTasks: (json['overdueTasks'] is num) ? json['overdueTasks'].toInt() : (json['overdueTasks'] ?? 0),
      progressPercent: _toDouble(json['progressPercent']),
      costStatus: _toDouble(json['costStatus']),
      cost: ProjectMetricData.fromJson(costData),
      showAlert: json['showAlert'] ?? false,
    );
  }
}

class TaskStatusItem {
  final int key;
  final String name;
  final int count;

  TaskStatusItem({
    required this.key,
    required this.name,
    required this.count,
  });

  factory TaskStatusItem.fromJson(Map<String, dynamic> json) {
    return TaskStatusItem(
      key: (json['key'] is num) ? json['key'].toInt() : (json['key'] ?? 0),
      name: json['name'] ?? '',
      count: (json['count'] is num) ? json['count'].toInt() : (json['count'] ?? 0),
    );
  }
}

class TaskStatusDashboardResponse {
  final bool isSuccess;
  final int code;
  final String message;
  final List<TaskStatusItem> statusCounts;

  TaskStatusDashboardResponse({
    required this.isSuccess,
    required this.code,
    required this.message,
    required this.statusCounts,
  });

  factory TaskStatusDashboardResponse.fromJson(Map<String, dynamic> json) {
    print('Task Status Dashboard Response: $json');
    return TaskStatusDashboardResponse(
      isSuccess: json['isSuccess'] ?? false,
      code: (json['code'] is num) ? json['code'].toInt() : (json['code'] ?? 0),
      message: json['message'] ?? '',
      statusCounts: (json['data']['statusCounts'] as List? ?? []).map((e) => TaskStatusItem.fromJson(e)).toList(),
    );
  }
}

class ProgressItem {
  final int sprintId;
  final String sprintName;
  final double percentComplete;

  ProgressItem({
    required this.sprintId,
    required this.sprintName,
    required this.percentComplete,
  });

  factory ProgressItem.fromJson(Map<String, dynamic> json) {
    return ProgressItem(
      sprintId: (json['sprintId'] is num) ? json['sprintId'].toInt() : (json['sprintId'] ?? 0),
      sprintName: json['sprintName'] ?? '',
      percentComplete: _toDouble(json['percentComplete']),
    );
  }
}

class ProgressDashboardResponse {
  final bool isSuccess;
  final int code;
  final String message;
  final List<ProgressItem> data;

  ProgressDashboardResponse({
    required this.isSuccess,
    required this.code,
    required this.message,
    required this.data,
  });

  factory ProgressDashboardResponse.fromJson(Map<String, dynamic> json) {
    print('Progress Dashboard Response: $json');
    return ProgressDashboardResponse(
      isSuccess: json['isSuccess'] ?? false,
      code: (json['code'] is num) ? json['code'].toInt() : (json['code'] ?? 0),
      message: json['message'] ?? '',
      data: (json['data'] as List? ?? []).map((e) => ProgressItem.fromJson(e)).toList(),
    );
  }
}

class TimeDashboardResponse {
  final bool isSuccess;
  final int code;
  final String message;
  final TimeData data;

  TimeDashboardResponse({
    required this.isSuccess,
    required this.code,
    required this.message,
    required this.data,
  });

  factory TimeDashboardResponse.fromJson(Map<String, dynamic> json) {
    print('Time Dashboard Response: $json');
    return TimeDashboardResponse(
      isSuccess: json['isSuccess'] ?? false,
      code: (json['code'] is num) ? json['code'].toInt() : (json['code'] ?? 0),
      message: json['message'] ?? '',
      data: TimeData.fromJson(json['data'] ?? {}),
    );
  }
}

class TimeData {
  final double plannedCompletion;
  final double actualCompletion;
  final String status;

  TimeData({
    required this.plannedCompletion,
    required this.actualCompletion,
    required this.status,
  });

  factory TimeData.fromJson(Map<String, dynamic> json) {
    return TimeData(
      plannedCompletion: _toDouble(json['plannedCompletion']),
      actualCompletion: _toDouble(json['actualCompletion']),
      status: json['status'] ?? '',
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
      memberName: json['memberName'] ?? '',
      completed: (json['completed'] is num) ? json['completed'].toInt() : (json['completed'] ?? 0),
      remaining: (json['remaining'] is num) ? json['remaining'].toInt() : (json['remaining'] ?? 0),
      overdue: (json['overdue'] is num) ? json['overdue'].toInt() : (json['overdue'] ?? 0),
    );
  }
}

class WorkloadDashboardResponse {
  final bool isSuccess;
  final int code;
  final String message;
  final List<WorkloadMember> data;

  WorkloadDashboardResponse({
    required this.isSuccess,
    required this.code,
    required this.message,
    required this.data,
  });

  factory WorkloadDashboardResponse.fromJson(Map<String, dynamic> json) {
    print('Workload Dashboard Response: $json');
    return WorkloadDashboardResponse(
      isSuccess: json['isSuccess'] ?? false,
      code: (json['code'] is num) ? json['code'].toInt() : (json['code'] ?? 0),
      message: json['message'] ?? '',
      data: (json['data'] as List? ?? []).map((e) => WorkloadMember.fromJson(e)).toList(),
    );
  }
}

class CostDashboardResponse {
  final bool isSuccess;
  final int code;
  final String message;
  final CostData data;

  CostDashboardResponse({
    required this.isSuccess,
    required this.code,
    required this.message,
    required this.data,
  });

  factory CostDashboardResponse.fromJson(Map<String, dynamic> json) {
    print('Cost Dashboard Response: $json');
    return CostDashboardResponse(
      isSuccess: json['isSuccess'] ?? false,
      code: (json['code'] is num) ? json['code'].toInt() : (json['code'] ?? 0),
      message: json['message'] ?? '',
      data: CostData.fromJson(json['data'] ?? {}),
    );
  }
}

class CostData {
  final double actualCost;
  final double actualTaskCost;
  final double actualResourceCost;
  final double plannedCost;
  final double plannedTaskCost;
  final double plannedResourceCost;
  final double budget;

  CostData({
    required this.actualCost,
    required this.actualTaskCost,
    required this.actualResourceCost,
    required this.plannedCost,
    required this.plannedTaskCost,
    required this.plannedResourceCost,
    required this.budget,
  });

  factory CostData.fromJson(Map<String, dynamic> json) {
    return CostData(
      actualCost: _toDouble(json['actualCost']),
      actualTaskCost: _toDouble(json['actualTaskCost']),
      actualResourceCost: _toDouble(json['actualResourceCost']),
      plannedCost: _toDouble(json['plannedCost']),
      plannedTaskCost: _toDouble(json['plannedTaskCost']),
      plannedResourceCost: _toDouble(json['plannedResourceCost']),
      budget: _toDouble(json['budget']),
    );
  }
}

// Extension for AIRecommendationDTO to support copyWith
extension AIRecommendationDTOExtension on AIRecommendationDTO {
  AIRecommendationDTO copyWith({
    int? id,
    String? recommendation,
    String? details,
    String? type,
    List<String>? affectedTasks,
    String? suggestedTask,
    String? expectedImpact,
    String? suggestedChanges,
    int? priority,
  }) {
    return AIRecommendationDTO(
      id: id ?? this.id,
      recommendation: recommendation ?? this.recommendation,
      details: details ?? this.details,
      type: type ?? this.type,
      affectedTasks: affectedTasks ?? this.affectedTasks,
      suggestedTask: suggestedTask ?? this.suggestedTask,
      expectedImpact: expectedImpact ?? this.expectedImpact,
      suggestedChanges: suggestedChanges ?? this.suggestedChanges,
      priority: priority ?? this.priority,
    );
  }
}

class DashboardPage extends StatefulWidget {
  final String projectKey;

  const DashboardPage({Key? key, required this.projectKey}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // late Future<HealthDashboardResponse> healthFuture;
  // late Future<TaskStatusDashboardResponse> taskStatusFuture;
  // late Future<ProgressDashboardResponse> progressFuture;
  // late Future<TimeDashboardResponse> timeFuture;
  // late Future<CostDashboardResponse> costFuture;
  // late Future<WorkloadDashboardResponse> workloadFuture;
  Future<List<dynamic>>? _dashboardFuture;
  bool showRecommendations = false;
  bool isRecLoading = false;
  bool isCalculateDone = false;
  List<AIRecommendationDTO> aiRecommendations = [];
  List<int> approvedIds = [];
  String aiResponseJson = '';
  bool isEvaluationPopupOpen = false;

  @override
  void initState() {
    super.initState();
    //_calculateAndInitializeFutures();
    _dashboardFuture = _calculateAndInitializeFutures();
  }

  Future<List<dynamic>> _calculateAndInitializeFutures() async {
    setState(() {
      isCalculateDone = false;
    });
    try {
      // Step 1: Call calculateMetricsBySystem
      await calculateMetricsBySystem(widget.projectKey);

      // Step 2: Fetch all dashboard data
      final results = await Future.wait([
        fetchHealthDashboard(widget.projectKey),
        fetchTaskStatusDashboard(widget.projectKey),
        fetchProgressDashboard(widget.projectKey),
        fetchTimeDashboard(widget.projectKey),
        fetchCostDashboard(widget.projectKey),
        fetchWorkloadDashboard(widget.projectKey),
      ]);

      setState(() {
        isCalculateDone = true;
      });
      return results;
    } catch (e) {
      print('Error calculating metrics: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error calculating metrics: $e'),
          backgroundColor: Colors.red,
        ),
      );
      // Fetch existing data even if calculation fails
      final results = await Future.wait([
        fetchHealthDashboard(widget.projectKey),
        fetchTaskStatusDashboard(widget.projectKey),
        fetchProgressDashboard(widget.projectKey),
        fetchTimeDashboard(widget.projectKey),
        fetchCostDashboard(widget.projectKey),
        fetchWorkloadDashboard(widget.projectKey),
      ]);
      setState(() {
        isCalculateDone = true;
      });
      return results;
    }
  }

  // void _initializeFutures() {
  //   healthFuture = fetchHealthDashboard(widget.projectKey);
  //   taskStatusFuture = fetchTaskStatusDashboard(widget.projectKey);
  //   progressFuture = fetchProgressDashboard(widget.projectKey);
  //   timeFuture = fetchTimeDashboard(widget.projectKey);
  //   costFuture = fetchCostDashboard(widget.projectKey);
  //   workloadFuture = fetchWorkloadDashboard(widget.projectKey);
  // }
  //
  // Future<void> _calculateAndInitializeFutures() async {
  //   setState(() {
  //     isCalculateDone = false;
  //   });
  //   try {
  //     await calculateMetricsBySystem(widget.projectKey);
  //     _initializeFutures();
  //     setState(() {
  //       isCalculateDone = true;
  //     });
  //   } catch (e) {
  //     print('Error calculating metrics: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Error calculating metrics: $e'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //     _initializeFutures(); // Load existing data even if calculation fails
  //     setState(() {
  //       isCalculateDone = true;
  //     });
  //   }
  // }

  Future<void> calculateMetricsBySystem(String projectKey) async {
    final uri = UriHelper.build('/projectmetric/calculate-by-system?projectKey=$projectKey');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';

    print('Calling calculateMetricsBySystem with URI: $uri');
    print('Access Token: $token');

    if (token.isEmpty) {
      throw Exception('No access token found. Please log in again.');
    }

    try {
      final response = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({}),
      ).timeout(Duration(seconds: 10));

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode != 200) {
        String errorMessage = response.body;
        try {
          final json = jsonDecode(response.body);
          errorMessage = json['message'] ?? response.body;
        } catch (_) {}
        throw Exception('Failed to calculate metrics: ${response.statusCode} - $errorMessage');
      }
    } on SocketException catch (e) {
      throw Exception('Network error: Unable to reach server. Please check your connection.');
    } on TimeoutException catch (e) {
      throw Exception('Request timed out. Please try again later.');
    } catch (e) {
      print('Error in calculateMetricsBySystem: $e');
      rethrow;
    }
  }

  Future<HealthDashboardResponse> fetchHealthDashboard(String projectKey) async {
    final uri = UriHelper.build('/projectmetric/health-dashboard?projectKey=$projectKey');
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
      final json = jsonDecode(response.body);
      print('Health Dashboard Response: $json');
      return HealthDashboardResponse.fromJson(json);
    } else {
      throw Exception('Failed to load health dashboard: ${response.statusCode}');
    }
  }

  Future<TaskStatusDashboardResponse> fetchTaskStatusDashboard(String projectKey) async {
    final uri = UriHelper.build('/projectmetric/tasks-dashboard?projectKey=$projectKey');
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
      final json = jsonDecode(response.body);
      print('Task Status Dashboard Response: $json');
      return TaskStatusDashboardResponse.fromJson(json);
    } else {
      throw Exception('Failed to load task status dashboard: ${response.statusCode}');
    }
  }

  Future<ProgressDashboardResponse> fetchProgressDashboard(String projectKey) async {
    final uri = UriHelper.build('/projectmetric/progress-dashboard?projectKey=$projectKey');
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
      final json = jsonDecode(response.body);
      print('Progress Dashboard Response: $json');
      return ProgressDashboardResponse.fromJson(json);
    } else {
      throw Exception('Failed to load progress dashboard: ${response.statusCode}');
    }
  }

  Future<TimeDashboardResponse> fetchTimeDashboard(String projectKey) async {
    final uri = UriHelper.build('/projectmetric/time-dashboard?projectKey=$projectKey');
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
      final json = jsonDecode(response.body);
      print('Time Dashboard Response: $json');
      return TimeDashboardResponse.fromJson(json);
    } else {
      throw Exception('Failed to load time dashboard: ${response.statusCode}');
    }
  }

  Future<CostDashboardResponse> fetchCostDashboard(String projectKey) async {
    final uri = UriHelper.build('/projectmetric/cost-dashboard?projectKey=$projectKey');
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
      final json = jsonDecode(response.body);
      print('Cost Dashboard Response: $json');
      return CostDashboardResponse.fromJson(json);
    } else {
      throw Exception('Failed to load cost dashboard: ${response.statusCode}');
    }
  }

  Future<WorkloadDashboardResponse> fetchWorkloadDashboard(String projectKey) async {
    final uri = UriHelper.build('/projectmetric/workload-dashboard?projectKey=$projectKey');
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
      final json = jsonDecode(response.body);
      print('Workload Dashboard Response: $json');
      return WorkloadDashboardResponse.fromJson(json);
    } else {
      throw Exception('Failed to load workload dashboard: ${response.statusCode}');
    }
  }

  Future<List<AIRecommendationDTO>> fetchRecommendations(String projectKey) async {
    final uri = UriHelper.build('/projectrecommendation/ai-recommendations?projectKey=$projectKey');
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
      final json = jsonDecode(response.body);
      print('Recommendations Response: $json');
      final List data = json['data'] ?? [];
      return data.map((e) => AIRecommendationDTO.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load AI Recommendations: ${response.statusCode}');
    }
  }

  Future<void> createRecommendation(AIRecommendationDTO rec, int projectId) async {
    final uri = UriHelper.build('/projectrecommendation');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';

    final response = await http.post(
      uri,
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'projectId': projectId,
        'type': rec.type,
        'recommendation': rec.recommendation,
        'details': rec.details,
        'suggestedChanges': rec.suggestedChanges,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to save recommendation: ${response.statusCode}');
    }
  }

  Future<void> fetchRecommendationsFromAPI() async {
    setState(() {
      isRecLoading = true;
      showRecommendations = true;
    });

    try {
      final recs = await fetchRecommendations(widget.projectKey);
      setState(() {
        aiRecommendations = recs;
      });
    } catch (e) {
      print("Failed to fetch recommendations: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to fetch recommendations: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isRecLoading = false;
      });
    }
  }

  Future<void> handleAfterDeleteRecommendation() async {
    try {
      final recs = await fetchRecommendations(widget.projectKey);
      setState(() {
        aiRecommendations = recs;
      });
    } catch (e) {
      print('Error after deleting recommendation: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error after deleting recommendation: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> handleEvaluationSubmitSuccess() async {
    try {
      final recs = await fetchRecommendations(widget.projectKey);
      setState(() {
        isEvaluationPopupOpen = false;
        aiResponseJson = '';
        aiRecommendations = recs;
      });
    } catch (e) {
      print('Error handling evaluation submit: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error handling evaluation submit: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool> confirm(BuildContext context, String message) async {
    bool confirmed = false;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              confirmed = false;
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              confirmed = true;
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
    return confirmed;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: Text('Dashboard - ${widget.projectKey}'),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<List<dynamic>>(
        // future: Future.wait([
        //   healthFuture,
        //   taskStatusFuture,
        //   progressFuture,
        //   timeFuture,
        //   costFuture,
        //   workloadFuture,
        // ]),
        future: _dashboardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting || !isCalculateDone) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            String errorMessage = 'Error loading dashboard: ${snapshot.error}';
            if (snapshot.error.toString().contains("type 'int' is not a subtype of type 'double'")) {
              errorMessage += '\nThis is likely due to an API response containing integers where decimals are expected.';
            }
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _calculateAndInitializeFutures();
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else {
            final health = snapshot.data![0] as HealthDashboardResponse;
            final taskStatus = snapshot.data![1] as TaskStatusDashboardResponse;
            final progress = snapshot.data![2] as ProgressDashboardResponse;
            final time = snapshot.data![3] as TimeDashboardResponse;
            final cost = snapshot.data![4] as CostDashboardResponse;
            final workload = snapshot.data![5] as WorkloadDashboardResponse;

            // Check SPI and CPI conditions
            final bool showAlertCard = health.isSuccess &&
                (health.data.cost.schedulePerformanceIndex < 1 ||
                    health.data.cost.costPerformanceIndex < 1);

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Alert Card (shown if SPI < 1 or CPI < 1)
                if (showAlertCard)
                  AlertCard(
                    spi: health.data.cost.schedulePerformanceIndex,
                    cpi: health.data.cost.costPerformanceIndex,
                    showRecommendations: showRecommendations,
                    onShowAIRecommendations: fetchRecommendationsFromAPI,
                    isRecLoading: isRecLoading,
                    aiRecommendations: aiRecommendations,
                  ),
                // Health Overview
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Health Overview',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        HealthOverview(data: health),
                      ],
                    ),
                  ),
                ),
                // Task Status
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Task Status',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        TaskStatusChart(data: taskStatus),
                      ],
                    ),
                  ),
                ),
                // Progress Per Sprint
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Progress Per Sprint',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ProgressPerSprint(data: progress),
                      ],
                    ),
                  ),
                ),
                // Time Tracking
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Time Tracking',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        TimeComparisonChart(data: time),
                      ],
                    ),
                  ),
                ),
                // Cost
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Cost',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        CostBarChart(data: cost),
                      ],
                    ),
                  ),
                ),
                // Workload
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Workload',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        WorkloadChart(data: workload),
                      ],
                    ),
                  ),
                ),
                // AI Recommendations Dialog
                if (showRecommendations)
                  _buildRecommendationsDialog(),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildRecommendationsDialog() {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'AI Suggestions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() {
                    showRecommendations = false;
                    aiResponseJson = jsonEncode(aiRecommendations);
                    isEvaluationPopupOpen = true;
                  }),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (isRecLoading)
              const Center(child: CircularProgressIndicator())
            else if (aiRecommendations.isNotEmpty)
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: aiRecommendations.length,
                  itemBuilder: (context, index) {
                    return _buildRecommendationCard(
                        aiRecommendations[index], index);
                  },
                ),
              )
            else
              const Text(
                'No AI suggestions available.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            if (aiRecommendations.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    setState(() {
                      aiResponseJson = jsonEncode(aiRecommendations);
                      isEvaluationPopupOpen = true;
                      showRecommendations = false;
                    });
                    await handleEvaluationSubmitSuccess();
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Done'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(AIRecommendationDTO rec, int index) {
    bool isApproved = approvedIds.contains(index);
    bool isEditing = false;
    AIRecommendationDTO editedRec = rec;
    Map<String, String> errors = {};

    return StatefulBuilder(
      builder: (context, setState) {
        void validateFields() {
          final newErrors = <String, String>{};
          if (editedRec.recommendation.trim().isEmpty) {
            newErrors['recommendation'] = 'Recommendation is required';
          }
          if (!['SCHEDULE', 'COST'].contains(editedRec.type.toUpperCase())) {
            newErrors['type'] = 'Valid type is required';
          }
          errors = newErrors;
        }

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: isEditing
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Recommendation',
                    errorText: errors['recommendation'],
                  ),
                  onChanged: (value) => editedRec = editedRec.copyWith(recommendation: value),
                ),
                DropdownButton<String>(
                  value: editedRec.type,
                  items: ['SCHEDULE', 'COST']
                      .map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  ))
                      .toList(),
                  onChanged: (value) => setState(() {
                    editedRec = editedRec.copyWith(type: value!);
                  }),
                  hint: const Text('Select type'),
                ),
                if (errors['type'] != null)
                  Text(
                    errors['type']!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Details'),
                  maxLines: 4,
                  onChanged: (value) => editedRec = editedRec.copyWith(details: value),
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Suggested Changes'),
                  onChanged: (value) =>
                  editedRec = editedRec.copyWith(suggestedChanges: value),
                ),
                if (errors['api'] != null)
                  Text(
                    errors['api']!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        validateFields();
                        if (errors.isEmpty) {
                          setState(() {
                            aiRecommendations[index] = editedRec;
                            isEditing = false;
                            errors = {};
                          });
                        }
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('Save'),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () => setState(() {
                        isEditing = false;
                        errors = {};
                      }),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ],
            )
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recommendation #${index + 1} - ${rec.type} (Priority: ${rec.priority})',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                Text(
                  rec.recommendation,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Text(
                  rec.details,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  'Expected Impact: ${rec.expectedImpact}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                if (rec.suggestedChanges.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(8),
                    color: Colors.grey[100],
                    child: Text(
                      'Suggested Changes: ${rec.suggestedChanges}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                if (errors['api'] != null)
                  Text(
                    errors['api']!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: isApproved
                          ? null
                          : () async {
                        validateFields();
                        if (errors.isEmpty) {
                          try {
                            await createRecommendation(editedRec, 1);
                            setState(() {
                              approvedIds.add(index);
                              aiRecommendations[index] = editedRec;
                            });
                            await handleAfterDeleteRecommendation();
                          } catch (e) {
                            setState(() {
                              errors['api'] = 'Failed to save recommendation. Please try again.';
                            });
                          }
                        }
                      },
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: isApproved
                          ? null
                          : () => setState(() {
                        isEditing = true;
                        editedRec = rec;
                        errors = {};
                      }),
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: isApproved
                          ? null
                          : () async {
                        final confirmed = await confirm(
                            context, 'Are you sure you want to delete this recommendation?');
                        if (confirmed) {
                          setState(() {
                            aiRecommendations.removeAt(index);
                            approvedIds.remove(index);
                          });
                          await handleAfterDeleteRecommendation();
                        }
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red,
                      ),
                    ),
                    if (isApproved)
                      const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Text(
                          'Approved',
                          style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class AlertCard extends StatelessWidget {
  final double spi;
  final double cpi;
  final bool showRecommendations;
  final VoidCallback onShowAIRecommendations;
  final bool isRecLoading;
  final List<AIRecommendationDTO> aiRecommendations;

  const AlertCard({
    Key? key,
    required this.spi,
    required this.cpi,
    required this.showRecommendations,
    required this.onShowAIRecommendations,
    required this.isRecLoading,
    required this.aiRecommendations,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isSPIBad = spi < 1;
    final bool isCPIBad = cpi < 1;
    return Card(
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '⚠️ Project Alerts',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (isSPIBad)
              const Text('• Schedule Performance Index (SPI) is below 1.'),
            if (isCPIBad)
              const Text('• Cost Performance Index (CPI) is below 1.'),
            const Text('• Please review suggested actions from AI below.'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isRecLoading ? null : onShowAIRecommendations,
              child: const Text('Show AI Recommendations'),
            ),
            if (isRecLoading)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: CircularProgressIndicator(),
              ),
            // if (showRecommendations && aiRecommendations.isNotEmpty) ...[
            //   const SizedBox(height: 16),
            //   const Text(
            //     'AI Recommendations:',
            //     style: TextStyle(fontWeight: FontWeight.bold),
            //   ),
            //   ...aiRecommendations.map(
            //         (rec) => ListTile(
            //       title: Text(rec.recommendation),
            //       subtitle: Text(rec.details),
            //     ),
            //   ),
            // ],
          ],
        ),
      ),
    );
  }
}