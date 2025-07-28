import 'package:flutter/material.dart';
import 'package:intelli_pm/Project/Dashboard/CostBarChart.dart';
import 'package:intelli_pm/Project/Dashboard/ProgressPerSprint.dart';
import 'package:intelli_pm/Project/Dashboard/TaskStatusChart.dart';
import 'package:intelli_pm/Project/Dashboard/TimeComparisonChart.dart';
import 'package:intelli_pm/Project/Dashboard/WorkloadChart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Helper/UriHelper.dart';
import 'ForecastCard.dart';
import 'AlertCard.dart';
import 'HealthOverview.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProjectMetricResponse {
  final bool isSuccess;
  final int code;
  final String message;
  final ProjectMetricData data;

  ProjectMetricResponse({
    required this.isSuccess,
    required this.code,
    required this.message,
    required this.data,
  });

  factory ProjectMetricResponse.fromJson(Map<String, dynamic> json) {
    return ProjectMetricResponse(
      isSuccess: json['isSuccess'],
      code: json['code'],
      message: json['message'],
      data: ProjectMetricData.fromJson(json['data']),
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
  });

  factory ProjectMetricData.fromJson(Map<String, dynamic> json) {
    return ProjectMetricData(
      projectId: json['projectId'],
      plannedValue: (json['plannedValue'] ?? 0).toDouble(),
      earnedValue: (json['earnedValue'] ?? 0).toDouble(),
      actualCost: (json['actualCost'] ?? 0).toDouble(),
      budgetAtCompletion: (json['budgetAtCompletion'] ?? 0).toDouble(),
      durationAtCompletion: (json['durationAtCompletion'] ?? 0).toDouble(),
      costVariance: (json['costVariance'] ?? 0).toDouble(),
      scheduleVariance: (json['scheduleVariance'] ?? 0).toDouble(),
      costPerformanceIndex: (json['costPerformanceIndex'] ?? 0).toDouble(),
      schedulePerformanceIndex:
          (json['schedulePerformanceIndex'] ?? 0).toDouble(),
      estimateAtCompletion: (json['estimateAtCompletion'] ?? 0).toDouble(),
      estimateToComplete: (json['estimateToComplete'] ?? 0).toDouble(),
      varianceAtCompletion: (json['varianceAtCompletion'] ?? 0).toDouble(),
      estimateDurationAtCompletion:
          (json['estimateDurationAtCompletion'] ?? 0).toDouble(),
      calculatedBy: json['calculatedBy'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}

class AIRecommendationDTO {
  final String recommendation;
  final String details;
  final String type;
  final List<String> affectedTasks;
  final String? suggestedTask;
  final String expectedImpact;
  final Map<String, dynamic> suggestedChanges;

  AIRecommendationDTO({
    required this.recommendation,
    required this.details,
    required this.type,
    required this.affectedTasks,
    required this.suggestedTask,
    required this.expectedImpact,
    required this.suggestedChanges,
  });

  factory AIRecommendationDTO.fromJson(Map<String, dynamic> json) {
    return AIRecommendationDTO(
      recommendation: json['recommendation'],
      details: json['details'],
      type: json['type'],
      affectedTasks: List<String>.from(json['affectedTasks']),
      suggestedTask: json['suggestedTask'],
      expectedImpact: json['expectedImpact'],
      suggestedChanges: Map<String, dynamic>.from(json['suggestedChanges']),
    );
  }
}

class DashboardPage extends StatefulWidget {
  final String projectKey;

  const DashboardPage({Key? key, required this.projectKey}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Future<ProjectMetricResponse> metricFuture;
  bool showRecommendations = false;
  bool isRecLoading = false;
  List<AIRecommendationDTO> aiRecommendations = [];

  @override
  void initState() {
    super.initState();
    metricFuture = fetchProjectMetric(widget.projectKey);
  }

  Future<ProjectMetricResponse> fetchProjectMetric(String projectKey) async {
    final uri = UriHelper.build(
      '/projectmetric/by-project-key?projectKey=$projectKey',
    );
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
      return ProjectMetricResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load metric');
    }
  }

  Future<List<AIRecommendationDTO>> fetchRecommendations(
    String projectKey,
  ) async {
    final url = UriHelper.build(
      '/projectrecommendation/ai-recommendations?projectKey=$projectKey',
    );
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List data = json['data'];
      return data.map((e) => AIRecommendationDTO.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load AI Recommendations');
    }
  }

  Future<void> fetchRecommendationsFromAPI(String projectKey) async {
    setState(() {
      isRecLoading = true;
      showRecommendations = true;
    });

    try {
      final recs = await fetchRecommendations(projectKey);
      setState(() {
        aiRecommendations = recs;
      });
    } catch (e) {
      print("Failed to fetch recommendations: $e");
    } finally {
      setState(() {
        isRecLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      // appBar: AppBar(
      //   title: Text('Dashboard - ${widget.projectKey}'),
      //   backgroundColor: Colors.blue,
      // ),
      body: FutureBuilder<ProjectMetricResponse>(
        future: metricFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else {
            final metric = snapshot.data!.data;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ForecastCard(metric: metric), // ForecastCard
                const SizedBox(height: 16),
                AlertCard(
                  spi: metric.schedulePerformanceIndex,
                  cpi: metric.costPerformanceIndex,
                  showRecommendations: showRecommendations,
                  onShowAIRecommendations: () => fetchRecommendationsFromAPI(widget.projectKey),
                  isRecLoading: isRecLoading,
                  aiRecommendations: aiRecommendations,
                ),
                HealthOverview(projectKey: widget.projectKey), // HealthOverview
                TaskStatusChart(projectKey: widget.projectKey), // TaskStatusChart
                ProgressPerSprint(projectKey: widget.projectKey), // ProgressPerSprint
                TimeComparisonChart(projectKey: widget.projectKey), // TimeComparisonChart
                CostBarChart(projectKey: widget.projectKey), // CostBarChart
                WorkloadChart(projectKey: widget.projectKey), // WorkloadChart
              ],
            );
          }
        },
      ),
    );
  }
}
