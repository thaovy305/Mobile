import 'package:flutter/material.dart';
import 'WorkItemList.dart';
import 'WorkItemDetailed.dart';

// Define enum at file scope
enum ViewType { list, detailed }

class AllWorkMain extends StatefulWidget {
  const AllWorkMain({super.key});

  @override
  State<AllWorkMain> createState() => _AllWorkMainState();
}

class _AllWorkMainState extends State<AllWorkMain> {
  // Initial selected view
  ViewType _selectedView = ViewType.list;

  // Widget to display based on the selected view
  Widget _getCurrentView() {
    switch (_selectedView) {
      case ViewType.list:
        return const WorkItemList();
      case ViewType.detailed:
        return const WorkItemDetailed();
      default:
        return const WorkItemList(); // Default to list view
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Work Item Management'),
      ),
      body: Column(
        children: [
          // SegmentedButton centered at the top
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SegmentedButton<ViewType>(
              segments: const <ButtonSegment<ViewType>>[
                ButtonSegment<ViewType>(
                  value: ViewType.list,
                  label: Text('List'),
                  icon: Icon(Icons.list),
                ),
                ButtonSegment<ViewType>(
                  value: ViewType.detailed,
                  label: Text('Detailed'),
                  icon: Icon(Icons.details),
                ),
              ],
              selected: {_selectedView},
              onSelectionChanged: (Set<ViewType> newSelection) {
                setState(() {
                  _selectedView = newSelection.first;
                });
              },
              style: const ButtonStyle(
                padding: MaterialStatePropertyAll(EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0)),
              ),
            ),
          ),
          // Expanded to take remaining space and display the selected view
          Expanded(
            child: _getCurrentView(),
          ),
        ],
      ),
    );
  }
}