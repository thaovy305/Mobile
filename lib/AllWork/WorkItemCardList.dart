import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WorkItemCardList extends StatelessWidget {
  final String id;
  final String title;
  final String status;
  final String type;
  final VoidCallback onTap;

  const WorkItemCardList({
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
        return 'assets/type_subtask.svg';
      case 'BUG':
        return 'assets/type_bug.svg';
      default:
        return 'assets/type_task.svg';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0), // Reduced vertical padding
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            borderRadius: BorderRadius.circular(8.0), // Added rounded corners
          ),
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(2), // Issue column
              1: FlexColumnWidth(1), // Key column
            },
            border: TableBorder(
              verticalInside: BorderSide(color: Colors.grey.shade300),
            ),
            children: [
              TableRow(
                children: [
                  // Issue column with icon and title (aligned left)
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          getIconAsset(),
                          width: 20,
                          height: 20,

                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Key column (aligned right)
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      id,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}