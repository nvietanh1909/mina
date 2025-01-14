// lib/sleep/SleepScreen.dart
import 'package:flutter/material.dart';

class InsightScreen extends StatelessWidget {
  const InsightScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Daily Page Content',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}