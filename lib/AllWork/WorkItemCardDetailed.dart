import 'package:flutter/material.dart';

class WorkItemCardDetailed extends StatelessWidget {
  final String id;
  final String title;
  final String status;
  final String type;
  final VoidCallback onTap;

  const WorkItemCardDetailed({
    super.key,
    required this.id,
    required this.title,
    required this.status,
    required this.type,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text('ID: $id', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 4),
              Text('Status: $status', style: const TextStyle(fontSize: 12, color: Colors.green)),
              Text('Type: $type', style: const TextStyle(fontSize: 12, color: Colors.orange)),
            ],
          ),
        ),
      ),
    );
  }
}