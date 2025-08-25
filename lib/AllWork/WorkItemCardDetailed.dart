import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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

  String getIconAsset() {
    switch (type.toUpperCase()) {
      case 'EPIC':
        return 'assets/type_epic.svg';
      case 'TASK':
        return 'assets/type_task.svg';
      case 'STORY':
        return 'assets/type_story.svg';
      case 'SUBTASK':
      case 'SUBSTACK':
        return 'assets/type_subtask.svg';
      case 'BUG':
        return 'assets/type_bug.svg';
      default:
        return 'assets/type_task.svg';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 12.0),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      getIconAsset(),
                      width: 20,
                      height: 20,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.left,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            id,
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Divider(
                    color: Colors.grey.shade300,
                    thickness: 1.0,
                    height: 12.0,
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