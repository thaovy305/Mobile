import 'package:flutter/material.dart';
import 'Backlog/BacklogMainPage.dart';
import 'KanbanBoard/KanbanBoardMain.dart';

class ProjectOverviewPage extends StatelessWidget {
  final String projectName;
  final String projectKey;

  ProjectOverviewPage({
    Key? key,
    required this.projectName,
    required this.projectKey,
  }) : super(key: key);

  final List<String> tabs = [
    "Backlog",
    "Board",
    "Summary",
    "Calendar",
    "Forms",
    "Timeline",
    "Reports",
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          automaticallyImplyLeading: true,
          title: Text(
            projectName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.black),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48.0),
            child: TabBar(
              isScrollable: true,
              indicatorColor: Colors.blue,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600),
              padding: EdgeInsets.zero,
              labelPadding: const EdgeInsets.symmetric(horizontal: 12),
              tabs: tabs.map((tab) => Tab(text: tab)).toList(),
            ),
          ),
        ),
        body: TabBarView(
          children: tabs.map((tab) {
            if (tab == "Backlog") {
              return BacklogMainPage(projectKey: projectKey);
            }
            if (tab == "Board") {
              return KanbanBoardMain(projectKey: projectKey);
            }

            return Center(
              child: Text(
                'Page: $tab',
                style: const TextStyle(fontSize: 18),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}