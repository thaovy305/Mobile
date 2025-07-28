import 'package:flutter/material.dart';

class CommentSection extends StatefulWidget {
  const CommentSection({super.key});

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  String selectedActivity = 'Comments';

  List<String> activities = ['Comments', 'History', 'Worklog', 'All'];

  List<Map<String, String>> comments = [
    {
      'name': 'Ngo Pham...y (K16_HCM)',
      'avatarUrl': '',
      'message': 'Hi',
    },
    {
      'name': 'Ngo Pham...y (K16_HCM)',
      'avatarUrl': '',
      'message': 'Hdjsjej',
    },
  ];

  String commentInput = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Dropdown Activity
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            PopupMenuButton<String>(
              initialValue: selectedActivity,
              onSelected: (value) {
                setState(() {
                  selectedActivity = value;
                });
              },
              itemBuilder: (context) => activities
                  .map((e) => PopupMenuItem<String>(
                value: e,
                child: Row(
                  children: [
                    if (selectedActivity == e)
                      Icon(Icons.check, size: 16),
                    if (selectedActivity == e) SizedBox(width: 8),
                    Text(e),
                  ],
                ),
              ))
                  .toList(),
              child: Row(
                children: [
                  Text(
                    selectedActivity,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
            const Text("Oldest first"),
          ],
        ),
        const SizedBox(height: 8),

        /// Comment list
        Column(
          children: comments.map((comment) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 1,
              child: ListTile(
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                leading: CircleAvatar(
                  backgroundImage: comment['avatarUrl'] != ''
                      ? NetworkImage(comment['avatarUrl']!)
                      : null,
                  child: comment['avatarUrl'] == ''
                      ? const Icon(Icons.person)
                      : null,
                ),
                title: Text(
                  comment['name']!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(comment['message']!),
                    const SizedBox(height: 4),
                    TextButton.icon(
                      onPressed: () {
                      },
                      icon: const Icon(Icons.reply, size: 16),
                      label: const Text("Reply"),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(50, 20),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),

        /// Input comment
        Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: (value) => commentInput = value,
                decoration: const InputDecoration(
                  hintText: "Nhập một nhận xét...",
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () {
                setState(() {
                  comments.add({
                    'name': 'Bạn',
                    'avatarUrl': '',
                    'message': commentInput,
                  });
                  commentInput = '';
                });
              },
            ),
          ],
        ),
      ],
    );
  }
}
