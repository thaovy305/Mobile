import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../Helper/UriHelper.dart';
import '../../Models/Task.dart';
import '../../Models/TaskAssignment.dart';
import '../../WorkItem/TaskDetailPage.dart';

class TaskCard extends StatefulWidget {
  final String title;
  final String code;
  final String status;
  final String? epicLabel;
  final bool isDone;
  final List<TaskAssignment>? taskAssignments;
  final String? type;

  const TaskCard({
    super.key,
    required this.title,
    required this.code,
    required this.status,
    this.epicLabel,
    this.isDone = false,
    this.taskAssignments,
    this.type,
  });

  @override
  _TaskCardState createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  String _getIconForWorkItem() {
    switch (widget.type?.toUpperCase()) {
      case 'EPIC':
        return 'assets/type_epic.svg';
      case 'TASK':
        return 'assets/type_task.svg';
      case 'STORY':
        return 'assets/type_story.svg';
      case 'BUG':
        return 'assets/type_bug.svg';
      default:
        return 'assets/type_task.svg';
    }
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'DONE':
        return const Color(0xFF78CC7F);
      case 'IN_PROGRESS':
        return const Color(0xFF5BA6E3);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskDetailPage(taskId: widget.code),
          ),
        );
      },
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Color(0xFFDDDDDD),
              width: 0.8,
            ),
          ),
        ),
        child: Card(
          color: Colors.white,
          margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.type != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: SvgPicture.asset(
                      _getIconForWorkItem(),
                      width: 20,
                      height: 20,
                    ),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.code,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                          decoration: widget.isDone ? TextDecoration.lineThrough : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.epicLabel != null && widget.epicLabel!.isNotEmpty) ...[
                        const SizedBox(height: 4), // Khoảng cách giữa code và epicLabel
                        Container(
                          constraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            widget.epicLabel!,
                            style: const TextStyle(
                              color: Colors.purple,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _statusColor(widget.status),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          widget.status.toString().toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.taskAssignments != null && widget.taskAssignments!.isNotEmpty)
                            ...widget.taskAssignments!.take(2).map((assignment) {
                              return Padding(
                                padding: const EdgeInsets.only(left: 4.0),
                                child: CircleAvatar(
                                  radius: 10,
                                  backgroundColor: const Color(0xFFB0BEC5),
                                  backgroundImage: assignment.accountPicture != null
                                      ? NetworkImage(assignment.accountPicture!)
                                      : null,
                                ),
                              );
                            }).toList(),
                          if (widget.taskAssignments != null && widget.taskAssignments!.length > 2)
                            Padding(
                              padding: const EdgeInsets.only(left: 4.0),
                              child: CircleAvatar(
                                radius: 10,
                                backgroundColor: const Color(0xFFB0BEC5),
                                child: Text(
                                  '+${widget.taskAssignments!.length - 2}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Icon(Icons.drag_handle, size: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}