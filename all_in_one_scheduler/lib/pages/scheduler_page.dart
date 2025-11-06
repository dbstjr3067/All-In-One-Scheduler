import 'package:flutter/material.dart';

class SchedulerPage extends StatelessWidget {
  const SchedulerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        '계획 세우기 페이지',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}