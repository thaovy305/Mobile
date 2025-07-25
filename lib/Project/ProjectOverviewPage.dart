import 'package:flutter/material.dart';
import 'Backlog/BacklogMainPage.dart';

class ProjectOverviewPage extends StatelessWidget {
  final String projectName;

  ProjectOverviewPage({Key? key, required this.projectName}) : super(key: key);

  final List<String> tabs = [
    "Summary",
    "Board",
    "Backlog",
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
              // Loại bỏ padding mặc định và điều chỉnh labelPadding
              padding: EdgeInsets.zero,
              // Xóa padding của TabBar
              labelPadding: const EdgeInsets.symmetric(horizontal: 12),
              // Đều cho tất cả tab
              tabs: tabs.map((tab) => Tab(text: tab)).toList(),
            ),
          ),
        ),
        body: TabBarView(
          children:
              tabs.map((tab) {
                if (tab == "Backlog") {
                  return BacklogMainPage();
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
