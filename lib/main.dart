import 'package:flutter/material.dart';
import 'pages/home/index.dart';
import 'pages/history/index.dart';
import 'pages/user/index.dart';
import 'components/layouts/bottom_navigation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: Color(0xFFFF2E63),
        scaffoldBackgroundColor: Color(0xFF121212),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFFFF2E63),
          brightness: Brightness.dark,
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // Default ke Home

  static const List<Widget> _pages = <Widget>[
    HomePage(),
    UserPage(),
    HistoryPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigation(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
