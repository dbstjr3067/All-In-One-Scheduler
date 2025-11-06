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
    return Scaffold(
      appBar: AppBar(
        title: const Text('오늘 할 일'),
        titleTextStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 50),
        centerTitle: false,
      ),
      body: Text('오늘 할 일임')
      /*body: ListView.builder(
        itemCount: todayTasks.length,
        itemBuilder: (context, index) {
          return
        }*/
    );
  }
}