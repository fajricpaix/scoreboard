import 'package:flutter/material.dart';
import 'package:scoreboard/pages/create/index.dart';
import 'package:scoreboard/theme/index.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Text(
            'Home Page',
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateMatchPage()),
          );
        },
        backgroundColor: primaryColor,
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add,
          size: 32,
        ),
      ),
    );
  }
}