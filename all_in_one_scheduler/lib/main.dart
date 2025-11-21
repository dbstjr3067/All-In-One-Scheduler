import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';

import 'package:all_in_one_scheduler/pages/reminder_page.dart';
import 'package:all_in_one_scheduler/pages/scheduler_page.dart';
import 'package:all_in_one_scheduler/pages/statistics_page.dart';
import 'package:all_in_one_scheduler/pages/alarm_page.dart';
import 'package:all_in_one_scheduler/pages/my_page.dart';

const platform = MethodChannel('com.example.all_in_one_scheduler/unlock');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting('ko_KR', null);
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
  /*final List<Widget> _pages = const [
    ReminderPage(),
    SchedulerPage(),
    StatisticsPage(),
    AlarmPage(),
    MyPage()
  ];*/
  final GlobalKey<ReminderPageState> _reminderPageKey = GlobalKey();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    void handleScheduleDeletion(String title) {
      if (_reminderPageKey.currentState == null) {
        print('DEBUG ERROR: ReminderPageState의 currentState가 NULL입니다. (아직 빌드되지 않았거나 메모리에서 제거됨)');
      } else {
        print('DEBUG SUCCESS: ReminderPageState의 currentState 접근 성공. 함수 호출 시도.');
        // Key를 사용하여 ReminderPage의 public 함수를 호출합니다.
        _reminderPageKey.currentState?.deleteCompletionByTitle(title);
      }
    }

    _pages = [
      ReminderPage(key: _reminderPageKey), // ReminderPage에 Key 할당
      SchedulerPage(onScheduleDeleted: handleScheduleDeletion), // SchedulerPage에 콜백 전달
      const StatisticsPage(),
      const AlarmPage(),
      const MyPage()
    ];

    platform.setMethodCallHandler((call) async {
      if (call.method == "fromUnlock") {
        debugPrint("언락 메시지 받았음");
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
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages
      ),
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
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '내정보',
          ),
        ]
      ),
    );
  }
}