import 'package:flutter/material.dart';
import 'package:intelli_pm/Meeting/MeetingPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'HomePage.dart';
import 'Project/ProjectListByAccountPage.dart';
import 'BottomNavBar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String _username = 'User';
  bool _isLoading = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'User';
      _isLoading = false;
    });
  }

  // void _onNavBarTap(int index) {
  //   if (index == 0 || index == 1) {
  //     setState(() {
  //       _currentIndex = index;
  //     });
  //   }
  //   // Các tab khác (2, 3, 4) không làm gì vì chưa có trang
  // }

  void _onNavBarTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),

      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : IndexedStack(
                index: _currentIndex,
                children: [
                  HomePage(),
                  ProjectListByAccountPage(username: _username),
                  MeetingPage(),
                  const Center(child: Text('All work - Chưa triển khai')),
                  const Center(child: Text('Dashboard - Chưa triển khai')),
                  const Center(child: Text('Notifications - Chưa triển khai')),
                ],
              ),
      bottomNavigationBar: BottomNavBar(
        username: _username,
        currentIndex: _currentIndex,
        onTap: _onNavBarTap, // Thêm tham số onTap
      ),
    );
  }
}
