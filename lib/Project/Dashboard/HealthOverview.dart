import 'package:flutter/material.dart';
import 'Dashboard.dart';

class HealthOverview extends StatelessWidget {
  final HealthDashboardResponse data;

  const HealthOverview({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Project Status
        Row(
          children: [
            const Text(
              'Project Status: ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Flexible(
              child: Text(
                data.data.projectStatus,
                style: const TextStyle(fontSize: 16),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Time Status
        Row(
          children: [
            const Text(
              'Time Status: ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Flexible(
              child: Text(
                data.data.timeStatus,
                style: const TextStyle(fontSize: 16),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Progress Percent
        Row(
          children: [
            const Text(
              'Progress: ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Flexible(
              child: Text(
                '${data.data.progressPercent.toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 16),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Tasks to Complete
        Row(
          children: [
            const Text(
              'Tasks to Complete: ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '${data.data.tasksToBeCompleted}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Overdue Tasks
        Row(
          children: [
            const Text(
              'Overdue Tasks: ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '${data.data.overdueTasks}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Cost Status
        Row(
          children: [
            const Text(
              'Cost Status: ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Flexible(
              child: Text(
                data.data.costStatus,
                style: const TextStyle(fontSize: 16),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
