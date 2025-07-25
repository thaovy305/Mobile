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
            crossAxisAlignment: CrossAxisAlignment.start, // Căn chỉnh đầu dòng
            children: [
              // Icon trạng thái
              Icon(
                isDone ? Icons.task_alt : Icons.task_alt_outlined,
                color: Colors.blueAccent,
                size: 24,
              ),
              const SizedBox(width: 12),

              // Phần giữa: tiêu đề và mã task + epic label
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tiêu đề task
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis, // Cắt ngắn nếu quá dài
                    ),
                    const SizedBox(height: 4),

                    // Mã task và epic label
                    Row(
                      children: [
                        // Mã task
                        Flexible(
                          child: Text(
                            code,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                              decoration: isDone ? TextDecoration.lineThrough : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis, // Cắt ngắn nếu quá dài
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Epic label
                        if (epicLabel != null)
                          Flexible(
                            child: Container(
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
                                overflow: TextOverflow.ellipsis, // Cắt ngắn nếu quá dài
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Phần bên phải: trạng thái + assignee + drag handle
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Trạng thái
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis, // Cắt ngắn nếu quá dài
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Assignee
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        CircleAvatar(
                          radius: 10,
                          backgroundColor: Color(0xFFB0BEC5),
                          child: Icon(Icons.person, size: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Drag handle
              const Padding(
                padding: EdgeInsets.only(left: 10),
                child: Icon(Icons.drag_handle, size: 18, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}