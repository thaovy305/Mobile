import 'package:flutter/material.dart';
import 'SprintBoard.dart';
import 'BacklogBoard.dart';

class BacklogMainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Backlog Overview',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16.0),
          SprintBoard(), // Bảng Sprints
          const Divider(thickness: 1.0, color: Colors.grey),
          BacklogBoard(), // Bảng Backlog
        ],
      ),
    );
  }
}