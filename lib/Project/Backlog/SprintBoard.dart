import 'package:flutter/material.dart';
import 'TaskCard.dart';

class SprintBoard extends StatefulWidget {
  @override
  _SprintBoardState createState() => _SprintBoardState();
}

class _SprintBoardState extends State<SprintBoard> {
  final List<Map<String, dynamic>> sprints = [
    {
      'id': 1,
      'name': 'TB Sprint (Active)',
      'tasks': [
        {
          'title': 'bcbcbcv',
          'code': 'TB-18',
          'status': 'Done',
          'epicLabel': 'Đạt Epic',
          'isDone': true,
        },
        {
          'title': '999999',
          'code': 'TB-21',
          'status': 'To Do',
          'epicLabel': 'epic 1',
          'isDone': false,
        },
        {
          'title': 'dgggggggg',
          'code': 'TB-6',
          'status': 'In Progress',
          'epicLabel': 'tuấn đạt',
          'isDone': false,
        },
        {
          'title': 'datastra',
          'code': 'TB-22',
          'status': 'To Do',
          'epicLabel': null,
          'isDone': false,
        },
      ]
    },
    {
      'id': 2,
      'name': 'TB 3',
      'tasks': [
        {
          'title': 'gdsfgsdfg',
          'code': 'TB-25',
          'status': 'To Do',
          'epicLabel': null,
          'isDone': false,
        },
      ]
    },
    {
      'id': 3,
      'name': 'TB 4',
      'tasks': [
        {
          'title': 'fsgsdfg',
          'code': 'TB-26',
          'status': 'To Do',
          'epicLabel': null,
          'isDone': false,
        },
      ]
    },
  ];

  final Map<int, bool> expandedSprints = {};

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(0),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: sprints.map((sprint) {
          final sprintId = sprint['id'];
          final isExpanded = expandedSprints[sprintId] ?? true;

          return Card(
            color: Colors.white,
            margin: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with toggle
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        expandedSprints[sprintId] = !(expandedSprints[sprintId] ?? true);
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12.0),

                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            isExpanded ? Icons.expand_less : Icons.expand_more,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sprint['name'],
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${(sprint['tasks'] as List).length} work items',
                                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),



                  const SizedBox(height: 8.0),

                  // Tasks
                  if (isExpanded)
                    ...List.generate((sprint['tasks'] as List).length, (index) {
                      final task = sprint['tasks'][index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: TaskCard(
                          title: task['title'],
                          code: task['code'],
                          status: task['status'],
                          epicLabel: task['epicLabel'],
                          isDone: task['isDone'],
                        ),
                      );
                    }),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
