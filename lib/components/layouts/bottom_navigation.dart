import 'package:flutter/material.dart';

class BottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.zero,
      child: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              size: 28,
              ),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              size: 28,
              ),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(
              Icons.history,
              size: 28,
              ),
            label: '',
          ),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        backgroundColor: const Color(0xFF1E1E1E),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: onItemTapped,
      ),
    );
  }
}