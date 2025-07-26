import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../Helper/UriHelper.dart';
import '../../Models/Task.dart';
import 'KanbanColumn.dart';

class KanbanBoardMain extends StatefulWidget {
  final String projectKey;

  const KanbanBoardMain({super.key, required this.projectKey});

  @override
  State<KanbanBoardMain> createState() => _KanbanBoardMainState();
}

class _KanbanBoardMainState extends State<KanbanBoardMain> {
  List<Task> allTasks = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final uri = UriHelper.build('/sprint/by-project-id-with-tasks?projectKey=${widget.projectKey}');
      print('Fetching tasks from: $uri');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': '*/*',
        },
      );
      print('Fetch tasks response: ${response.statusCode}, body: ${response.body}');
      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        if (jsonBody['isSuccess'] == true) {
          final sprints = jsonBody['data'] as List;
          List<Task> tasks = [];
          for (var sprint in sprints) {
            if (sprint['tasks'] != null) {
              tasks.addAll((sprint['tasks'] as List).map((t) => Task.fromJson(t)).toList());
            }
          }
          setState(() {
            allTasks = tasks;
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = jsonBody['message'] ?? 'Failed to load tasks';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Server error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Network error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $errorMessage', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchTasks,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final todoTasks = allTasks.where((t) => t.status == 'TO_DO').toList();
    final inProgressTasks = allTasks.where((t) => t.status == 'IN_PROGRESS').toList();
    final doneTasks = allTasks.where((t) => t.status == 'DONE').toList();

    final columns = [
      KanbanColumn(title: 'TO DO', tasks: todoTasks),
      KanbanColumn(title: 'IN PROGRESS', tasks: inProgressTasks),
      KanbanColumn(title: 'DONE', tasks: doneTasks),
    ];

    return PageView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: columns.length,
      itemBuilder: (context, index) {
        return columns[index];
      },
    );
  }
}