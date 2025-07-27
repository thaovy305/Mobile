import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../Models/Task.dart';
import '../../Models/TaskAssignment.dart';
import '../../WorkItem/TaskDetailPage.dart';

class TaskCard extends StatefulWidget {
  final Task task;

  const TaskCard({
    super.key,
    required this.task,
  });

  @override
  _TaskCardState createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  bool _isDraggingEnabled = false;

  String _getIconForWorkItem() {
    switch (widget.task.type?.toUpperCase()) {
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

  Color _statusColor(String? status) {
    switch (status?.toUpperCase()) {
      case 'DONE':
        return const Color(0xFFb2da73); // Lấy từ API task_status
      case 'IN_PROGRESS':
        return const Color(0xFF87b1e1);
      case 'TO_DO':
        return const Color(0xFFdddee1);
      default:
        return Colors.grey;
    }
  }

  void _enableDragging() {
    setState(() {
      _isDraggingEnabled = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: _enableDragging, // Kích hoạt kéo thả khi giữ lâu
      child: Draggable<String>(
        data: _isDraggingEnabled ? widget.task.id : null, // Chỉ kéo khi enabled
        feedback: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: MediaQuery.of(context).size.width - 64, // Giảm để tránh tràn
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              widget.task.title,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        childWhenDragging: Opacity(
          opacity: 0.3,
          child: _buildCard(context),
        ),
        child: _buildCard(context),
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    return Container(
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
              if (widget.task.type != null)
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
                      widget.task.title,
                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.task.id,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        decoration: widget.task.status?.toUpperCase() == 'DONE'
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.task.epicName != null && widget.task.epicName!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Container(
                        constraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          widget.task.epicName!,
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
                        color: _statusColor(widget.task.status),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        widget.task.status?.toUpperCase() ?? 'UNKNOWN',
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
                        if (widget.task.taskAssignments != null &&
                            widget.task.taskAssignments!.isNotEmpty)
                          ...widget.task.taskAssignments!.take(2).map((assignment) {
                            return Padding(
                              padding: const EdgeInsets.only(left: 4.0),
                              child: CircleAvatar(
                                radius: 10,
                                backgroundColor: const Color(0xFFB0BEC5),
                                backgroundImage: assignment.accountPicture != null
                                    ? NetworkImage(assignment.accountPicture!)
                                    : null,
                                child: assignment.accountPicture == null
                                    ? Text(
                                  assignment.accountFullname?.substring(0, 1) ?? '?',
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                )
                                    : null,
                              ),
                            );
                          }).toList(),
                        if (widget.task.taskAssignments != null &&
                            widget.task.taskAssignments!.length > 2)
                          Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: CircleAvatar(
                              radius: 10,
                              backgroundColor: const Color(0xFFB0BEC5),
                              child: Text(
                                '+${widget.task.taskAssignments!.length - 2}',
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
    );
  }
}