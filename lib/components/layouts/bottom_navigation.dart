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
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            offset: Offset(0, -4),
            blurRadius: 4,
            color: Color.fromRGBO(0, 0, 0, 0.3),
          ),
        ],
      ),
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
        backgroundColor: Theme.of(context).colorScheme.surface,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: onItemTapped,
      ),
    );
  }
}