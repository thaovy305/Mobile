import 'package:flutter/material.dart';
import '../../Models/Task.dart';
import 'TaskCard.dart';

class KanbanColumn extends StatelessWidget {
  final String title;
  final String statusName;
  final List<Task> tasks;
  final Function(String, String) onTaskDropped;
  final Function(DragTargetDetails<String>) onDragUpdate;

  const KanbanColumn({
    super.key,
    required this.title,
    required this.statusName,
    required this.tasks,
    required this.onTaskDropped,
    required this.onDragUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<String>(
      onWillAcceptWithDetails: (details) {
        onDragUpdate(details); // Gọi hàm tự động cuộn khi kéo
        return true; // Cho phép tất cả task được kéo vào
      },
      onAccept: (taskId) {
        onTaskDropped(taskId, statusName);
      },
      onAcceptWithDetails: (details) {
        // Làm mới giao diện sau khi thả
        (context as Element).markNeedsBuild();
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: candidateData != null ? Colors.grey.shade400 : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Text(
                  '$title  ${tasks.length}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),

              // Body + Create button wrapper
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    children: [
                      // Tasks hoặc rỗng với chiều cao tự động
                      Expanded(
                        child: tasks.isNotEmpty
                            ? ListView.builder(
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: TaskCard(
                                key: ValueKey(tasks[index].id),
                                task: tasks[index],
                              ),
                            );
                          },
                        )
                            : const SizedBox.shrink(),
                      ),

                      // Footer actions (luôn nằm dưới cùng)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              '+ Create',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            Icon(Icons.attachment_outlined, color: Colors.blue, size: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}