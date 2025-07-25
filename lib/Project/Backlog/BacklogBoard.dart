import 'package:flutter/material.dart';
import 'TaskCard.dart';

class BacklogBoard extends StatelessWidget {
  BacklogBoard({Key? key}) : super(key: key);

  // Dữ liệu tĩnh cho các task trong Backlog
  final List<Map<String, dynamic>> _backlogTasks = [
    {
      'id': 1,
      'title': 'Backlog Task 1',
      'code': 'BK-001',
      'status': 'To Do',
      'epicLabel': 'Epic A',
      'isDone': false,
    },
    {
      'id': 2,
      'title': 'Backlog Task 2',
      'code': 'BK-002',
      'status': 'In Progress',
      'epicLabel': 'Epic B',
      'isDone': false,
    },
    {
      'id': 3,
      'title': 'Backlog Task 3',
      'code': 'BK-003',
      'status': 'Done',
      'epicLabel': 'Epic A',
      'isDone': true,
    },
    {
      'id': 4,
      'title': 'Backlog Task 4',
      'code': 'BK-004',
      'status': 'To Do',
      'epicLabel': 'Epic C',
      'isDone': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Backlog',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8.0),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _backlogTasks.length,
          itemBuilder: (context, index) {
            final task = _backlogTasks[index];
            return TaskCard(
              title: task['title'],
              code: task['code'],
              status: task['status'],
              epicLabel: task['epicLabel'],
              isDone: task['isDone'] ?? false,
            );
          },
        ),
      ],
    );
  }
}
