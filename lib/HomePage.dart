import 'package:flutter/material.dart';
import 'package:intelli_pm/Login/LoginPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intelli_pm/WorkItem/TaskDetailPage.dart';
import 'WorkItem/EpicDetailPage.dart';
import 'WorkItem/SubtaskDetailPage.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _username = 'User';

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'User';
    });
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');

    // Quay về LoginPage và xóa stack
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginPage()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F6F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, color: Colors.white),
            ),
            SizedBox(width: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('fpt-tuandatcoder', style: TextStyle(fontSize: 12)),
            ),
            Spacer(),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'logout') _logout(); // 👉 gọi hàm logout
              },
              itemBuilder: (context) => [
                PopupMenuItem(value: 'logout', child: Text('Logout')),
              ],
              icon: Icon(Icons.more_vert, color: Colors.black),
            ),
          ],
        ),
      ),



      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hello $_username 👋',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
                contentPadding: EdgeInsets.symmetric(vertical: 0),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Quick access',
                    style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                Text('Edit',
                    style: TextStyle(color: Colors.blue, fontSize: 14)),
              ],
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.assignment, size: 36, color: Colors.orange),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Personalize this space',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text(
                          'Add your most important stuff here, for fast access.',
                          style:
                          TextStyle(fontSize: 12, color: Colors.grey[700]),
                        ),
                        SizedBox(height: 4),
                        Text('Add items',
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            Text('Project List',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 16),
              _buildRecentItemWithWidgetIcon(
                SvgPicture.asset(
                  'assets/type_task.svg',
                  width: 24,
                  height: 24,
                ),
                'Edit flower product',
                'FLOWER-7',
                null,
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TaskDetailPage(taskId: 'FLOWER-7'),
                    ),
                  );
                },
              ),

              _buildRecentItemWithWidgetIcon(
                SvgPicture.asset(
                  'assets/type_epic.svg',
                  width: 24,
                  height: 24,
                ),
                'Edit flower product',
                'FLOWER-1',
                null,
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EpicDetailPage(epicId: 'FLOWER-1'),
                    ),
                  );
                },
              ),

              _buildRecentItemWithWidgetIcon(
                SvgPicture.asset(
                  'assets/type_subtask.svg',
                  width: 24,
                  height: 24,
                ),
                'Edit flower product',
                'FLOWER-19',
                null,
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SubtaskDetailPage(subtaskId: 'FLOWER-19'),
                    ),
                  );
                },
              ),

          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.folder), label: 'Projects'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'All work'),
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'Dashboards'),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                Icon(Icons.notifications),
                Positioned(
                  right: 0,
                  child: CircleAvatar(
                    radius: 6,
                    backgroundColor: Colors.red,
                    child: Text('1',
                        style: TextStyle(fontSize: 9, color: Colors.white)),
                  ),
                )
              ],
            ),
            label: 'Notifications',
          ),
        ],
      ),
    );
  }

  Widget _buildRecentItemWithWidgetIcon(
      Widget iconWidget, String title, String subtitle,
      [String? color, VoidCallback? onTap]) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                //color: _getColor(color),
                borderRadius: BorderRadius.circular(8),
              ),
              child: iconWidget,
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                Text(subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            )
          ],
        ),
      ),
    );
  }
}
