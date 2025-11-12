import 'package:flutter/material.dart';

class ReminderPage extends StatelessWidget {
  const ReminderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final todayTasks = [
      '운동 30분',
      '회의 14:00',
      'Flutter 프로젝트 수정',
      '책 20쪽 읽기',
    ];
    return SafeArea(
      child: Column(
        children: [
        // Header
        Container(
          color: const Color(0xFFD4D4E8),
          padding: const EdgeInsets.all(16),
          child: const Align(
            alignment: Alignment.bottomLeft,
            child: Text(
              '오늘 할 일',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
        ]
      ),
    );
  }
}