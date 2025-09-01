import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
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
  final String costStatus;
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
      costStatus: json['costStatus'] ?? '',
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
    _dashboardFuture = _calculateAndInitializeFutures();
  }

  Future<List<dynamic>> _calculateAndInitializeFutures() async {
    setState(() {
      isCalculateDone = false;
    });
    try {
      await calculateMetricsBySystem(widget.projectKey);

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
          'Accept': '*/*',
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
        'Accept': '*/*',
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
        'Accept': '*/*',
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
        'Accept': '*/*',
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
        'Accept': '*/*',
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
        'Accept': '*/*',
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
        'Accept': '*/*',
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
        'Accept': '*/*',
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
        'Accept': '*/*',
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

            final bool showAlertCard = health.isSuccess &&
                (health.data.cost.schedulePerformanceIndex < 1 ||
                    health.data.cost.costPerformanceIndex < 1);
//
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (health.data.showAlert)
                  AlertCard(
                    spi: health.data.cost.schedulePerformanceIndex,
                    cpi: health.data.cost.costPerformanceIndex,
                    showRecommendations: showRecommendations,
                    onShowAIRecommendations: fetchRecommendationsFromAPI,
                    isRecLoading: isRecLoading,
                    aiRecommendations: aiRecommendations,
                  ),
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
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Project Forecast',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ForecastCard(
                          pv: health.data.cost.plannedValue,
                          ev: health.data.cost.earnedValue,
                          ac: health.data.cost.actualCost,
                          spi: health.data.cost.schedulePerformanceIndex,
                          cpi: health.data.cost.costPerformanceIndex,
                          eac: health.data.cost.estimateAtCompletion,
                          etc: health.data.cost.estimateToComplete,
                          vac: health.data.cost.varianceAtCompletion,
                          edac: health.data.cost.estimateDurationAtCompletion,
                        ),
                      ],
                    ),
                  ),
                ),
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
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        child: SingleChildScrollView(
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
                      return _buildRecommendationCard(aiRecommendations[index], index);
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
      ),
    );
  }

  Widget _buildRecommendationCard(AIRecommendationDTO rec, int index) {
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
                  onChanged: (value) => editedRec = editedRec.copyWith(suggestedChanges: value),
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
              ],
            ),
          ),
        );
      },
    );
  }
}

// class ForecastCard extends StatelessWidget {
//   final double pv;
//   final double ev;
//   final double ac;
//   final double spi;
//   final double cpi;
//   final double eac;
//   final double etc;
//   final double vac;
//   final double edac;
//
//   const ForecastCard({
//     Key? key,
//     required this.pv,
//     required this.ev,
//     required this.ac,
//     required this.spi,
//     required this.cpi,
//     required this.eac,
//     required this.etc,
//     required this.vac,
//     required this.edac,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Planned Value (PV): ${pv.toStringAsFixed(2)} VND',
//           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//         ),
//         Text(
//           'Earned Value (EV): ${ev.toStringAsFixed(2)} VND',
//           style: const TextStyle(fontSize: 14),
//         ),
//         Text(
//           'Actual Cost (AC): ${ac.toStringAsFixed(2)} VND',
//           style: const TextStyle(fontSize: 14),
//         ),
//         Text(
//           'Schedule Performance Index (SPI): ${spi.toStringAsFixed(2)}',
//           style: const TextStyle(fontSize: 14),
//         ),
//         Text(
//           'Cost Performance Index (CPI): ${cpi.toStringAsFixed(2)}',
//           style: const TextStyle(fontSize: 14),
//         ),
//         Text(
//           'Estimate at Completion (EAC): ${eac.toStringAsFixed(2)} VND',
//           style: const TextStyle(fontSize: 14),
//         ),
//         Text(
//           'Estimate to Complete (ETC): ${etc.toStringAsFixed(2)} VND',
//           style: const TextStyle(fontSize: 14),
//         ),
//         Text(
//           'Variance at Completion (VAC): ${vac.toStringAsFixed(2)} VND',
//           style: const TextStyle(fontSize: 14),
//         ),
//         Text(
//           'Estimated Duration (EDAC): ${edac.toStringAsFixed(2)} months',
//           style: const TextStyle(fontSize: 14),
//         ),
//       ],
//     );
//   }
// }

class ForecastCard extends StatelessWidget {
  final double pv;
  final double ev;
  final double ac;
  final double spi;
  final double cpi;
  final double eac;
  final double etc;
  final double vac;
  final double edac;

  const ForecastCard({
    Key? key,
    required this.pv,
    required this.ev,
    required this.ac,
    required this.spi,
    required this.cpi,
    required this.eac,
    required this.etc,
    required this.vac,
    required this.edac,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final NumberFormat formatter = NumberFormat('#,##0', 'en_US');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Planned Value (PV): ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              TextSpan(
                text: '${formatter.format(pv)} VND',
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Earned Value (EV): ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              TextSpan(
                text: '${formatter.format(ev)} VND',
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Actual Cost (AC): ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              TextSpan(
                text: '${formatter.format(ac)} VND',
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Schedule Performance Index (SPI): ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              TextSpan(
                text: '${spi.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Cost Performance Index (CPI): ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              TextSpan(
                text: '${cpi.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Estimate at Completion (EAC): ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              TextSpan(
                text: '${formatter.format(eac)} VND',
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Estimate to Complete (ETC): ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              TextSpan(
                text: '${formatter.format(etc)} VND',
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Variance at Completion (VAC): ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              TextSpan(
                text: '${formatter.format(vac)} VND',
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Estimated Duration (EDAC): ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              TextSpan(
                text: '${formatter.format(edac)} months',
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
      ],
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
            //const Text('• Please review suggested actions from AI below.'),
            // const SizedBox(height: 16),
            // ElevatedButton(
            //   onPressed: isRecLoading ? null : onShowAIRecommendations,
            //   child: const Text('Show AI Recommendations'),
            // ),
            // if (isRecLoading)
            //   const Padding(
            //     padding: EdgeInsets.only(top: 8.0),
            //     child: CircularProgressIndicator(),
            //   ),
          ],
        ),
      ),
    );
  }
}