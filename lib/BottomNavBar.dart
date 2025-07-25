import 'package:flutter/material.dart';
import 'package:intelli_pm/Project/ProjectListByAccountPage.dart';
import 'package:intelli_pm/HomePage.dart';

class BottomNavBar extends StatelessWidget {
  final String username;
  final int currentIndex;

  const BottomNavBar({
    Key? key,
    required this.username,
    required this.currentIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        if (index == 0) {
          // Index 0 corresponds to 'Home'
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(),
            ),
          );
        } else if (index == 1) {
          // Index 1 corresponds to 'Projects'
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ProjectListByAccountPage(username: username),
            ),
          );
        }
      },
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.folder), label: 'Projects'),
        BottomNavigationBarItem(icon: Icon(Icons.list), label: 'All work'),
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboards'),
        BottomNavigationBarItem(
          icon: Stack(
            children: [
              Icon(Icons.notifications),
              Positioned(
                right: 0,
                child: CircleAvatar(
                  radius: 6,
                  backgroundColor: Colors.red,
                  child: Text(
                    '1',
                    style: TextStyle(fontSize: 9, color: Colors.white),
                  ),
                ),
              )
            ],
          ),
          label: 'Notifications',
        ),
      ],
    );
  }
}