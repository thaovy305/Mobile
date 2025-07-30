import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final String username;
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    Key? key,
    required this.username,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.folder), label: 'Projects'),
        BottomNavigationBarItem(icon: Icon(Icons.list), label: 'All work'),
        BottomNavigationBarItem(icon: Icon(Icons.video_call), label: 'Meeting'),

        // BottomNavigationBarItem(
        //   icon: Icon(Icons.dashboard),
        //   label: 'Dashboards',
        // ),
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
              ),
            ],
          ),
          label: 'Notifications',
        ),
      ],
    );
  }
}
