import 'dart:convert';
import 'Task.dart';

class Sprint {
  final int id;
  final int projectId;
  final String name;
  final String? goal;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? status;
  final DateTime? plannedStartDate;
  final DateTime? plannedEndDate;
  final List<Task>? tasks;

  Sprint({
    required this.id,
    required this.projectId,
    required this.name,
    this.goal,
    this.startDate,
    this.endDate,
    required this.createdAt,
    required this.updatedAt,
    this.status,
    this.plannedStartDate,
    this.plannedEndDate,
    this.tasks,
  });

  factory Sprint.fromJson(Map<String, dynamic> json) {
    return Sprint(
      id: json['id'] as int,
      projectId: json['projectId'] as int,
      name: json['name'] as String,
      goal: json['goal'] as String?,
      startDate:
          json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      status: json['status'] as String?,
      plannedStartDate:
          json['plannedStartDate'] != null
              ? DateTime.parse(json['plannedStartDate'])
              : null,
      plannedEndDate:
          json['plannedEndDate'] != null
              ? DateTime.parse(json['plannedEndDate'])
              : null,
      tasks:
          (json['tasks'] as List<dynamic>?) // Đảm bảo tasks là danh sách JSON
              ?.map(
                (taskJson) => Task.fromJson(taskJson as Map<String, dynamic>),
              ) // Ép kiểu rõ ràng
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'name': name,
      'goal': goal,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'plannedStartDate': plannedStartDate?.toIso8601String(),
      'plannedEndDate': plannedEndDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'status': status,
      'tasks': tasks?.map((task) => task.toJson()).toList(),
    };
  }
}
