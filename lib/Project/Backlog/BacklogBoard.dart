import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../Helper/UriHelper.dart';
import '../../Models/Task.dart';
import 'TaskCard.dart';

class BacklogBoard extends StatefulWidget {
  final String projectKey;

  const BacklogBoard({Key? key, required this.projectKey}) : super(key: key);

  @override
  _BacklogBoardState createState() => _BacklogBoardState();
}

class _BacklogBoardState extends State<BacklogBoard> {
  List<Task> backlogTasks = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchBacklogTasks();
  }

  Future<void> fetchBacklogTasks() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('email') ?? '';
      final token = prefs.getString('accessToken') ?? '';

      if (email.isEmpty) {
        setState(() {
          errorMessage = 'Email not found in preferences';
          isLoading = false;
        });
        return;
      }

      final uri = UriHelper.build('/task/backlog?projectKey=${widget.projectKey}');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': '*/*',
        },
      );

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        if (jsonBody['isSuccess'] == true) {
          final data = jsonBody['data'] as List;
          setState(() {
            backlogTasks = data.map((taskJson) => Task.fromJson(taskJson)).toList();
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = jsonBody['message'] ?? 'Failed to load backlog tasks';
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


  Future<void> updateTaskSprint(String taskId, int sprintId) async {
    final uri = UriHelper.build('/task/$taskId/sprint');
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('email') ?? '';
      final token = prefs.getString('accessToken') ?? '';

      if (email.isEmpty) {
        setState(() {
          errorMessage = 'Email not found in preferences';
          isLoading = false;
        });
        return;
      }
      final response = await http.patch(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': '*/*',
        },
        body: jsonEncode(sprintId),
      );
      print('Update task response: ${response.statusCode}, body: ${response.body}');
      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        if (jsonBody['isSuccess'] == true) {
          await fetchBacklogTasks(); // Làm mới danh sách Backlog
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update task: ${jsonBody['message']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error occurred')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (errorMessage != null) {
      return Center(child: Text(errorMessage!, style: const TextStyle(color: Colors.red)));
    }

    return DragTarget<String>(
      onWillAccept: (_) => true,
      onAccept: (taskId) => updateTaskSprint(taskId, 0), // Đặt sprintId = 0 cho Backlog
      builder: (context, candidateData, rejectedData) {
        return Container(
          padding: const EdgeInsets.all(12.0),
          margin: const EdgeInsets.only(top: 8.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Backlog',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '${backlogTasks.length ?? 0} work items',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 8.0),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: backlogTasks.length,
                itemBuilder: (context, index) {
                  final task = backlogTasks[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: TaskCard(
                      title: task.title,
                      code: task.id,
                      status: task.status ?? 'Unknown',
                      epicLabel: task.epicName,
                      isDone: task.status?.toUpperCase() == 'DONE',
                      taskAssignments: task.taskAssignments,
                      type: task.type,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}