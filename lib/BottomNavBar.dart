import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final String username;
  final int currentIndex;
  final Function(int) onTap;
  final int unreadCount;

  const BottomNavBar({
    Key? key,
    required this.username,
    required this.currentIndex,
    required this.onTap,
    required this.unreadCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      items: [
        const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        const BottomNavigationBarItem(icon: Icon(Icons.folder), label: 'Projects'),
        const BottomNavigationBarItem(icon: Icon(Icons.list), label: 'All work'),
        const BottomNavigationBarItem(icon: Icon(Icons.video_call), label: 'Meeting'),
        BottomNavigationBarItem(
          icon: Stack(
            children: [
              const Icon(Icons.notifications),
              if (unreadCount > 0)
                Positioned(
                  right: 0,
                  child: CircleAvatar(
                    radius: 6,
                    backgroundColor: Colors.red,
                    child: Text(
                      unreadCount.toString(),
                      style: const TextStyle(fontSize: 9, color: Colors.white),
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
