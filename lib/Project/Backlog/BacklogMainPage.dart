import 'package:flutter/material.dart';
import 'SprintBoard.dart';
import 'BacklogBoard.dart';

class BacklogMainPage extends StatelessWidget {
  final String projectKey;

  const BacklogMainPage({Key? key, required this.projectKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Backlog Overview - $projectKey',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16.0),
          SprintBoard(projectKey: projectKey),
          const Divider(thickness: 1.0, color: Colors.grey),
          BacklogBoard(projectKey: projectKey),
        ],
      ),
    );
  }
}