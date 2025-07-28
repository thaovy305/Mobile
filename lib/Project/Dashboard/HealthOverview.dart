import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../Helper/UriHelper.dart';

class HealthOverview extends StatefulWidget {
  final String projectKey;

  const HealthOverview({super.key, required this.projectKey});

  @override
  State<HealthOverview> createState() => _HealthOverviewState();
}

class _HealthOverviewState extends State<HealthOverview> {
  late Future<HealthDashboardResponse> _healthFuture;

  @override
  void initState() {
    super.initState();
    _healthFuture = fetchHealthDashboard(widget.projectKey);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<HealthDashboardResponse>(
      future: _healthFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text(
            'Loading...',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          );
        } else if (snapshot.hasError) {
          return Text(
            'Error: ${snapshot.error}',
            style: const TextStyle(fontSize: 14, color: Colors.red),
          );
        } else if (snapshot.data == null || snapshot.data!.data == null) {
          return Text(
            'No data: ${jsonEncode(snapshot.data)}',
            style: const TextStyle(fontSize: 14, color: Colors.orange),
          );
        }

        final health = snapshot.data!.data!;
        final cost = health.cost;

        return Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RowItem(label: 'Time', value: health.timeStatus ?? 'No data'),
                  RowItem(
                    label: 'Tasks',
                    value: '${health.tasksToBeCompleted} tasks to be completed',
                  ),
                  RowItem(
                    label: 'Workload',
                    value: '${health.overdueTasks} tasks overdue',
                  ),
                  RowItem(
                    label: 'Progress',
                    value: '${health.progressPercent}% complete',
                  ),
                  RowItem(
                    label: 'Cost Performance Index',
                    value:
                        (health.costStatus == 0 || health.costStatus == null)
                            ? 'No budget specified.'
                            : '${health.costStatus}',
                  ),
                  RowItem(
                    label: 'Schedule Performance Index',
                    value: '${cost.schedulePerformanceIndex}',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class RowItem extends StatelessWidget {
  final String label;
  final String value;

  const RowItem({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

Future<HealthDashboardResponse> fetchHealthDashboard(String projectKey) async {
  final url = UriHelper.build(
    '/projectmetric/health-dashboard?projectKey=$projectKey',
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
    return HealthDashboardResponse.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load health dashboard');
  }
}

class HealthDashboardResponse {
  final bool isSuccess;
  final int code;
  final String message;
  final HealthData? data;

  HealthDashboardResponse({
    required this.isSuccess,
    required this.code,
    required this.message,
    required this.data,
  });

  factory HealthDashboardResponse.fromJson(Map<String, dynamic> json) {
    return HealthDashboardResponse(
      isSuccess: json['isSuccess'],
      code: json['code'],
      message: json['message'],
      data: json['data'] != null ? HealthData.fromJson(json['data']) : null,
    );
  }
}

class HealthData {
  final String timeStatus;
  final int tasksToBeCompleted;
  final int overdueTasks;
  final double progressPercent;
  final double costStatus;
  final ProjectMetric cost;

  HealthData({
    required this.timeStatus,
    required this.tasksToBeCompleted,
    required this.overdueTasks,
    required this.progressPercent,
    required this.costStatus,
    required this.cost,
  });

  factory HealthData.fromJson(Map<String, dynamic> json) {
    return HealthData(
      timeStatus: json['timeStatus'],
      tasksToBeCompleted: json['tasksToBeCompleted'],
      overdueTasks: json['overdueTasks'],
      progressPercent: json['progressPercent'].toDouble(),
      costStatus: json['costStatus'],
      cost: ProjectMetric.fromJson(json['cost']),
    );
  }
}

class ProjectMetric {
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

  ProjectMetric({
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

  factory ProjectMetric.fromJson(Map<String, dynamic> json) {
    return ProjectMetric(
      projectId: json['projectId'],
      plannedValue: json['plannedValue'].toDouble(),
      earnedValue: json['earnedValue'].toDouble(),
      actualCost: json['actualCost'].toDouble(),
      budgetAtCompletion: json['budgetAtCompletion'].toDouble(),
      durationAtCompletion: json['durationAtCompletion'].toDouble(),
      costVariance: json['costVariance'].toDouble(),
      scheduleVariance: json['scheduleVariance'].toDouble(),
      costPerformanceIndex: json['costPerformanceIndex'].toDouble(),
      schedulePerformanceIndex: json['schedulePerformanceIndex'].toDouble(),
      estimateAtCompletion: json['estimateAtCompletion'].toDouble(),
      estimateToComplete: json['estimateToComplete'].toDouble(),
      varianceAtCompletion: json['varianceAtCompletion'].toDouble(),
      estimateDurationAtCompletion:
          json['estimateDurationAtCompletion'].toDouble(),
      calculatedBy: json['calculatedBy'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}
