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
          SizedBox(height: 16.0),
          SprintBoard(projectKey: projectKey),
          Divider(thickness: 1.0, color: Colors.grey.shade200),
          BacklogBoard(projectKey: projectKey),
        ],
      ),
    );
  }
}