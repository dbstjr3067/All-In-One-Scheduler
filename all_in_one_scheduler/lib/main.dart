import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

import 'package:all_in_one_scheduler/pages/reminder_page.dart';
import 'package:all_in_one_scheduler/pages/scheduler_page.dart';
import 'package:all_in_one_scheduler/pages/statistics_page.dart';
import 'package:all_in_one_scheduler/pages/alarm_page.dart';

const platform = MethodChannel('com.example.all_in_one_scheduler/unlock');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
//이 아래로 코드 작성, 위는 무시
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '올인원 스케쥴러',
      home: const HomePage(),
    ); //MaterialApp
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final List<Widget> _pages = const [
    ReminderPage(),
    SchedulerPage(),
    StatisticsPage(),
    AlarmPage()
  ];

  @override
  void initState() {
    super.initState();
    platform.setMethodCallHandler((call) async {
      if (call.method == "fromUnlock") {
        final int index = call.arguments as int;
        setState(() {
          _selectedIndex = index;
        });
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; //탭 클릭 시 인덱스 변경
    });
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // 4개 이상이면 이게 필요
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_file),
            label: '오늘 할 일',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: '계획',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: '통계',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.alarm),
            label: '알람',
          ),
        ]
      ),
    );
  }
}