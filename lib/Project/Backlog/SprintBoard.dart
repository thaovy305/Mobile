import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../Helper/UriHelper.dart';
import '../../Models/Sprint.dart';
import 'TaskCard.dart';

class SprintBoard extends StatefulWidget {
  final String projectKey;

  const SprintBoard({Key? key, required this.projectKey}) : super(key: key);

  @override
  _SprintBoardState createState() => _SprintBoardState();
}

class _SprintBoardState extends State<SprintBoard> {
  List<Sprint> sprints = [];
  final Map<int, bool> expandedSprints = {};
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchSprints();
  }

  Future<void> fetchSprints() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final uri = UriHelper.build('/sprint/by-project-id-with-tasks?projectKey=${widget.projectKey}');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': '*/*',
        },
      );

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        if (jsonBody['isSuccess'] == true) {
          final data = jsonBody['data'] as List;
          setState(() {
            sprints = data.map((sprintJson) => Sprint.fromJson(sprintJson)).toList();
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = jsonBody['message'] ?? 'Failed to load sprints';
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
      return Center(child: Text(errorMessage!, style: const TextStyle(color: Colors.red)));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: sprints.map((sprint) {
          final sprintId = sprint.id;
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
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        expandedSprints[sprintId] = !isExpanded;
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
                                  sprint.name,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${sprint.tasks?.length ?? 0} work items',
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
                  if (isExpanded && sprint.tasks != null)
                    ...List.generate(sprint.tasks!.length, (index) {
                      final task = sprint.tasks![index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: TaskCard(
                          title: task.title,
                          code: task.id,
                          status: task.status ?? 'Unknown',
                          epicLabel: task.epicName,
                          isDone: task.status?.toUpperCase() == 'DONE',
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