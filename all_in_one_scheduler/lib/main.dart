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

import 'package:permission_handler/permission_handler.dart';

const platform = MethodChannel('com.example.all_in_one_scheduler/unlock');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: 'All-In-One-Scheduler',
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


    _pages = [
      ReminderPage(), // ReminderPage에 Key 할당
      SchedulerPage(), // SchedulerPage에 콜백 전달
      const StatisticsPage(),
      const AlarmPage(),
      const MyPage()
    ];
    _checkOverlayPermission();
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

  Future<void> _checkOverlayPermission() async {
    // 위젯이 완전히 빌드된 후에 다이얼로그 표시
    await Future.delayed(const Duration(milliseconds: 100));

    if (!mounted) return;

    // 오버레이 권한 확인
    final status = await Permission.systemAlertWindow.status;

    if (!status.isGranted) {
      _showPermissionDialog();
    }
  }
  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '권한 요청',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  '리마인더 기능 실행을 위해 권한을 허용해주세요',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '(다른 앱 위에 표시 권한이 필수로 필요합니다)',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          '설정할게요',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          '괜찮아요',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _requestOverlayPermission() async {
    // 안드로이드 설정 화면으로 이동
    final status = await Permission.systemAlertWindow.request();

    if (status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('권한이 허용되었습니다')),
        );
      }
    }
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
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: '내정보',
            ),
          ]
      ),
    );
  }
}