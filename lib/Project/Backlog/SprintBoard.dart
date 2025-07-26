import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../Helper/UriHelper.dart';
import '../../Models/Sprint.dart';
import 'TaskCard.dart';
import 'StartSprintBottomSheet.dart';

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
      print('Fetching sprints from: $uri');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': '*/*',
        },
      );
      print('Response status: ${response.statusCode}, body: ${response.body}');

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

  Future<void> deleteSprint(int sprintId) async {
    final uri = UriHelper.build('/sprint/$sprintId/with-task');
    try {
      print('Deleting sprint from: $uri');
      final response = await http.delete(
        uri,
        headers: {
          'Accept': '*/*',
        },
      );
      print('Response status: ${response.statusCode}, body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        if (jsonBody['isSuccess'] == true) {
          setState(() {
            sprints.removeWhere((sprint) => sprint.id == sprintId);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sprint deleted successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete sprint: ${jsonBody['message']}')),
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

  Future<void> updateSprint(int sprintId, String name, String goal, DateTime startDate, DateTime endDate) async {
    print('Updating sprint with id: $sprintId');
    final uri = UriHelper.build('/sprint/$sprintId');
    final formattedStartDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(startDate.toUtc());
    final formattedEndDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(endDate.toUtc());
    final sprint = sprints.firstWhere((s) => s.id == sprintId, orElse: () => throw Exception('Sprint with id $sprintId not found'));
    final body = jsonEncode({
      'projectId': sprint.projectId,
      'name': name,
      'goal': goal.isEmpty ? null : goal,
      'startDate': formattedStartDate,
      'endDate': formattedEndDate,
      'plannedStartDate': formattedStartDate,
      'plannedEndDate': formattedEndDate,
      'status': sprint.status,
    });
    print('Updating sprint to: $uri with body: $body');

    try {
      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': '*/*',
        },
        body: body,
      );
      print('Response status: ${response.statusCode}, body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        if (jsonBody['isSuccess'] == true) {
          final updatedSprint = Sprint.fromJson(jsonBody['data']);
          setState(() {
            final index = sprints.indexWhere((sprint) => sprint.id == sprintId);
            if (index != -1) {
              sprints[index] = updatedSprint;
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sprint updated successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update sprint: ${jsonBody['message']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error occurred or sprint not found')),
      );
    }
  }

  void _showUpdateSprintDialog(int sprintId, Sprint sprint, int workItemCount) async {
    final TextEditingController nameController = TextEditingController(text: sprint.name ?? '');
    final TextEditingController goalController = TextEditingController(text: sprint.goal ?? '');
    DateTime? selectedStartDate = sprint.startDate;
    DateTime? selectedEndDate = sprint.endDate;
    final TextEditingController startDateController = TextEditingController(
      text: selectedStartDate != null ? DateFormat('yyyy-MM-dd').format(selectedStartDate) : '',
    );
    final TextEditingController startTimeController = TextEditingController(
      text: selectedStartDate != null ? DateFormat('HH:mm').format(selectedStartDate) : '08:00',
    );
    final TextEditingController endDateController = TextEditingController(
      text: selectedEndDate != null ? DateFormat('yyyy-MM-dd').format(selectedEndDate) : '',
    );
    final TextEditingController endTimeController = TextEditingController(
      text: selectedEndDate != null ? DateFormat('HH:mm').format(selectedEndDate) : '08:00',
    );
    String duration = '1 week';
    String? startDateError = null;
    String? endDateError = null;
    String? generalError = null;
    final List<int> validWeeks = [1, 2, 3, 4];
    bool hasChangedStart = false;
    bool hasChangedEnd = false;

    if (selectedEndDate != null && selectedStartDate != null) {
      final diffWeeks = (selectedEndDate.difference(selectedStartDate).inDays / 7).round();
      duration = diffWeeks >= 1 && diffWeeks <= 4 && validWeeks.contains(diffWeeks)
          ? '$diffWeeks week${diffWeeks > 1 ? 's' : ''}'
          : 'custom';
    }

    void _selectDate(bool isStartDate) async {
      final initialDate = isStartDate ? (selectedStartDate ?? DateTime.now()) : (selectedEndDate ?? DateTime.now());
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (picked != null) {
        final time = isStartDate ? startTimeController.text : endTimeController.text;
        final newDateTime = DateTime(picked.year, picked.month, picked.day, int.parse(time.split(':')[0]), int.parse(time.split(':')[1]));
        setState(() {
          if (isStartDate) {
            selectedStartDate = newDateTime;
            startDateController.text = DateFormat('yyyy-MM-dd').format(newDateTime);
            hasChangedStart = true;
          } else {
            selectedEndDate = newDateTime;
            endDateController.text = DateFormat('yyyy-MM-dd').format(newDateTime);
            hasChangedEnd = true;
          }
        });
      }
    }

    void _selectTime(bool isStartDate) async {
      final TimeOfDay initialTime = isStartDate
          ? (selectedStartDate != null ? TimeOfDay.fromDateTime(selectedStartDate!) : const TimeOfDay(hour: 8, minute: 0))
          : (selectedEndDate != null ? TimeOfDay.fromDateTime(selectedEndDate!) : const TimeOfDay(hour: 8, minute: 0));
      final TimeOfDay? picked = await showTimePicker(context: context, initialTime: initialTime);
      if (picked != null) {
        final date = isStartDate ? selectedStartDate ?? DateTime.now() : selectedEndDate ?? DateTime.now();
        final newDateTime = DateTime(date.year, date.month, date.day, picked.hour, picked.minute);
        setState(() {
          if (isStartDate) {
            selectedStartDate = newDateTime;
            startTimeController.text = DateFormat('HH:mm').format(newDateTime);
            hasChangedStart = true;
          } else {
            selectedEndDate = newDateTime;
            endTimeController.text = DateFormat('HH:mm').format(newDateTime);
            hasChangedEnd = true;
          }
        });
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Sprint Dates'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (generalError != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(generalError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                      ),
                    Text(
                      '$workItemCount work item${workItemCount != 1 ? 's' : ''} will be included in this sprint.',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Sprint Name *', labelStyle: TextStyle(fontSize: 12)),
                      onChanged: (value) => setDialogState(() {}),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: duration,
                      items: [
                        ...validWeeks.map((week) => DropdownMenuItem(
                          value: '$week week${week > 1 ? 's' : ''}',
                          child: Text('$week week${week > 1 ? 's' : ''}', style: const TextStyle(fontSize: 12)),
                        )),
                        const DropdownMenuItem(value: 'custom', child: Text('Custom', style: TextStyle(fontSize: 12))),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            duration = value;
                            if (value != 'custom' && selectedStartDate != null) {
                              final weeks = int.parse(value.split(' ')[0]);
                              selectedEndDate = selectedStartDate!.add(Duration(days: weeks * 7));
                              endDateController.text = DateFormat('yyyy-MM-dd').format(selectedEndDate!);
                              endTimeController.text = startTimeController.text;
                            }
                          });
                        }
                      },
                      decoration: const InputDecoration(labelText: 'Duration *', labelStyle: TextStyle(fontSize: 12)),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: startDateController,
                            decoration: InputDecoration(
                              labelText: 'Start Date *',
                              labelStyle: const TextStyle(fontSize: 12),
                              errorText: startDateError,
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.calendar_today, size: 16),
                                onPressed: () => _selectDate(true),
                              ),
                            ),
                            readOnly: true,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: startTimeController,
                            decoration: InputDecoration(
                              labelText: 'Start Time *',
                              labelStyle: const TextStyle(fontSize: 12),
                              errorText: startDateError,
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.access_time, size: 16),
                                onPressed: () => _selectTime(true),
                              ),
                            ),
                            readOnly: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: endDateController,
                            decoration: InputDecoration(
                              labelText: 'End Date *',
                              labelStyle: const TextStyle(fontSize: 12),
                              errorText: endDateError,
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.calendar_today, size: 16),
                                onPressed: duration == 'custom' ? () => _selectDate(false) : null,
                              ),
                            ),
                            readOnly: true,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: endTimeController,
                            decoration: InputDecoration(
                              labelText: 'End Time *',
                              labelStyle: const TextStyle(fontSize: 12),
                              errorText: endDateError,
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.access_time, size: 16),
                                onPressed: duration == 'custom' ? () => _selectTime(false) : null,
                              ),
                            ),
                            readOnly: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: goalController,
                      decoration: const InputDecoration(labelText: 'Sprint Goal', labelStyle: TextStyle(fontSize: 12)),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel', style: TextStyle(fontSize: 12)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: const Text('Save', style: TextStyle(color: Colors.blue, fontSize: 12)),
                  onPressed: () async {
                    if (nameController.text.isEmpty) {
                      setDialogState(() => generalError = 'Please fill the Sprint Name');
                      return;
                    }

                    if (selectedStartDate == null) {
                      setDialogState(() => generalError = 'Please select a start date and time');
                      return;
                    }

                    if (duration == 'custom' && selectedEndDate == null) {
                      setDialogState(() => generalError = 'Please select an end date and time');
                      return;
                    }

                    final startDateTime = selectedStartDate!;
                    final endDateTime = duration == 'custom'
                        ? selectedEndDate!
                        : selectedStartDate!.add(Duration(days: int.parse(duration.split(' ')[0]) * 7));

                    if (endDateTime.isBefore(startDateTime)) {
                      setDialogState(() => endDateError = 'End date must be after start date');
                      return;
                    }

                    await updateSprint(sprintId, nameController.text, goalController.text, startDateTime, endDateTime);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showStartSprintBottomSheet(int sprintId, Sprint sprint, int workItemCount) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StartSprintBottomSheet(
          sprintId: sprintId,
          sprint: sprint,
          workItemCount: workItemCount,
          projectKey: widget.projectKey,
          initialStartDate: sprint.startDate ?? DateTime.now(),
          initialEndDate: sprint.endDate ?? DateTime.now().add(const Duration(days: 7)),
          onTaskUpdated: () async {
            await fetchSprints();
            setState(() {});
          },
        );
      },
    );
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
          final workItemCount = sprint.tasks?.length ?? 0;
          final displayName = sprint.status == 'ACTIVE' ? '${sprint.name} (Active)' : sprint.name;

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
                                  displayName,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$workItemCount work items',
                                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'start' && sprint.status != "ACTIVE") {
                                _showStartSprintBottomSheet(sprintId, sprint, workItemCount);
                              } else if (value == 'complete' && sprint.status == "ACTIVE") {
                                print('Complete Sprint: ${sprint.name}');
                              } else if (value == 'update') {
                                _showUpdateSprintDialog(sprintId, sprint, workItemCount);
                              } else if (value == 'delete') {
                                _showDeleteConfirmationDialog(sprintId, sprint.name);
                              }
                            },
                            position: PopupMenuPosition.under,
                            itemBuilder: (BuildContext context) => [
                              if (sprint.status != "ACTIVE" && sprint.tasks != null && sprint.tasks!.isNotEmpty)
                                const PopupMenuItem<String>(
                                  value: 'start',
                                  child: Text('Start Sprint', style: TextStyle(fontSize: 14, color: Colors.black87)),
                                ),
                              if (sprint.status == "ACTIVE")
                                const PopupMenuItem<String>(
                                  value: 'complete',
                                  child: Text('Complete Sprint', style: TextStyle(fontSize: 14, color: Colors.black87)),
                                ),
                              const PopupMenuItem<String>(
                                value: 'update',
                                child: Text('Update Sprint', style: TextStyle(fontSize: 14, color: Colors.black87)),
                              ),
                              if (sprint.status != "ACTIVE")
                                const PopupMenuItem<String>(
                                  value: 'delete',
                                  child: Text('Delete Sprint', style: TextStyle(fontSize: 14, color: Colors.redAccent)),
                                ),
                            ],
                            icon: const Icon(Icons.more_vert),
                            tooltip: 'Sprint actions',
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
                          taskAssignments: task.taskAssignments,
                          type: task.type,
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

  void _showDeleteConfirmationDialog(int sprintId, String sprintName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete sprint "$sprintName"? This action cannot be undone.'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                deleteSprint(sprintId);
              },
            ),
          ],
        );
      },
    );
  }
}