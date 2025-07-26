import 'package:flutter/material.dart';
import '../../Models/Task.dart';
import 'TaskCard.dart';

class KanbanColumn extends StatelessWidget {
  final String title;
  final List<Task> tasks;

  const KanbanColumn({
    super.key,
    required this.title,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            color: Colors.white,
            width: double.infinity,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: tasks.isEmpty
                ? const Center(
              child: Text(
                'No tasks available',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TaskCard(
                    title: tasks[index].title,
                    code: tasks[index].id,
                    status: tasks[index].status ?? 'Unknown',
                    epicLabel: tasks[index].epicName,
                    isDone: tasks[index].status?.toUpperCase() == 'DONE',
                    taskAssignments: tasks[index].taskAssignments,
                    type: tasks[index].type,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}