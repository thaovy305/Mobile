import 'package:flutter/material.dart';

class TaskCard extends StatelessWidget {
  final String title;
  final String code;
  final String status;
  final String? epicLabel;
  final bool isDone;

  const TaskCard({
    super.key,
    required this.title,
    required this.code,
    required this.status,
    this.epicLabel,
    this.isDone = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFDDDDDD), // Màu xám mờ
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
            children: [
              Icon(
                isDone ? Icons.task_alt : Icons.task_alt_outlined,
                color: Colors.blueAccent,
                size: 24,
              ),
              const SizedBox(width: 12),

              // Expanded center section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    Row(
                      children: [
                        Text(
                          code,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                            decoration: isDone ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Epic label
                        if (epicLabel != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.purple.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              epicLabel!,
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
                    ),
                  ],
                ),
              ),

              // Right section: status + assignee + drag
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.greenAccent.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      SizedBox(width: 6),
                      CircleAvatar(
                        radius: 10,
                        backgroundColor: Color(0xFFB0BEC5),
                        child: Icon(Icons.person, size: 12),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(width: 10),
              const Icon(Icons.drag_handle, size: 18, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
