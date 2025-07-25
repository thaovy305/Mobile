import 'package:flutter/material.dart';
import 'TaskAssignment.dart';

class Task {
  final String id;
  final int? reporterId;
  final String? reporterName;
  final String? reporterPicture;
  final int? projectId;
  final String? projectName;
  final String? epicId;
  final String? epicName;
  final int? sprintId;
  final String? sprintName;
  final String? type;
  final bool? manualInput;
  final bool? generationAiInput;
  final String title;
  final String? description;
  final String? plannedStartDate;
  final String? plannedEndDate;
  final String? actualStartDate;
  final String? actualEndDate;
  final String? duration;
  final String? priority;
  final String? status;
  final String? createdAt;
  final String? updatedAt;
  final List<TaskAssignment>? taskAssignments;

  Task({
    required this.id,
    this.reporterId,
    this.reporterName,
    this.reporterPicture,
    this.projectId,
    this.projectName,
    this.epicId,
    this.epicName,
    this.sprintId,
    this.sprintName,
    this.type,
    this.manualInput,
    this.generationAiInput,
    required this.title,
    this.description,
    this.plannedStartDate,
    this.plannedEndDate,
    this.actualStartDate,
    this.actualEndDate,
    this.duration,
    this.priority,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.taskAssignments,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      reporterId: json['reporterId'] as int?,
      reporterName: json['reporterName'] as String?,
      reporterPicture: json['reporterPicture'] as String?,
      projectId: json['projectId'] as int?,
      projectName: json['projectName'] as String?,
      epicId: json['epicId'] as String?,
      epicName: json['epicName'] as String?,
      sprintId: json['sprintId'] as int?,
      sprintName: json['sprintName'] as String?,
      type: json['type'] as String?,
      manualInput: json['manualInput'] as bool?,
      generationAiInput: json['generationAiInput'] as bool?,
      title: json['title'] as String,
      description: json['description'] as String?,
      plannedStartDate: json['plannedStartDate'] as String?,
      plannedEndDate: json['plannedEndDate'] as String?,
      actualStartDate: json['actualStartDate'] as String?,
      actualEndDate: json['actualEndDate'] as String?,
      duration: json['duration'] as String?,
      priority: json['priority'] as String?,
      status: json['status'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      taskAssignments:
          (json['taskAssignments'] as List<dynamic>?)
              ?.map((item) => TaskAssignment.fromJson(item))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reporterId': reporterId,
      'reporterName': reporterName,
      'reporterPicture': reporterPicture,
      'projectId': projectId,
      'projectName': projectName,
      'epicId': epicId,
      'epicName': epicName,
      'sprintId': sprintId,
      'sprintName': sprintName,
      'type': type,
      'manualInput': manualInput,
      'generationAiInput': generationAiInput,
      'title': title,
      'description': description,
      'plannedStartDate': plannedStartDate,
      'plannedEndDate': plannedEndDate,
      'actualStartDate': actualStartDate,
      'actualEndDate': actualEndDate,
      'duration': duration,
      'priority': priority,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'taskAssignments':
          taskAssignments?.map((assignment) => assignment.toJson()).toList(),
    };
  }
}
