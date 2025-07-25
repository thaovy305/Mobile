import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../Helper/UriHelper.dart';
import '../Models/Task.dart';
//import 'TaskDetailModel.dart'; // import model

class TaskDetailPage extends StatefulWidget {
  final String taskId;

  const TaskDetailPage({Key? key, required this.taskId}) : super(key: key);

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  Task? taskDetail;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTaskDetail();
  }

  Future<void> fetchTaskDetail() async {
    final uri = UriHelper.build('/task/${widget.taskId}');
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          taskDetail = Task.fromJson(jsonData);
          isLoading = false;
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('API error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.taskId,
            style: const TextStyle(color: Colors.black)),
        actions: const [
          Icon(Icons.remove_red_eye_outlined, color: Colors.black),
          SizedBox(width: 12),
          Icon(Icons.edit_note_outlined, color: Colors.black),
          SizedBox(width: 12),
          Icon(Icons.more_vert, color: Colors.black),
          SizedBox(width: 8),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// Task title
          Text(
            taskDetail!.title,
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          /// Status
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              taskDetail!.status ?? 'Unknown',
              style: const TextStyle(color: Colors.blue),
            ),
          ),
          const SizedBox(height: 24),

          /// Description
          _sectionCard(
            'Description',
            Text(
              (taskDetail!.description?.isEmpty ?? true)
                  ? 'Add a description...'
                  : taskDetail!.description!,
            ),
          ),

          const SizedBox(height: 12),

          /// Details
          _sectionCard(
            'Details',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailRow('Issue Type', taskDetail!.type ?? 'None'),
                _detailRow('Sprint', taskDetail!.sprintName ?? 'None'),
                _detailRow('Start date',
                    formatDate(taskDetail!.plannedStartDate)),
                _detailRow('End date',
                    formatDate(taskDetail!.plannedEndDate)),
                _detailRow('Created',
                    formatDate(taskDetail!.createdAt)),
                _detailRow('Updated',
                    formatDate(taskDetail!.updatedAt)),
                const SizedBox(height: 8),
                const Text('Reporter',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundImage: NetworkImage(
                          taskDetail!.reporterPicture ?? ''),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(taskDetail!.reporterName ?? 'Unknown'),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard(String title, Widget child) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child:
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        child,
      ]),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label)),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String formatDate(String? isoString) {
    if (isoString == null) return 'None';
    final date = DateTime.tryParse(isoString);
    if (date == null) return 'Invalid';
    return '${date.day}/${date.month}/${date.year}';
  }
}
