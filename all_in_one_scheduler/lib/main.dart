import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:alarm/alarm.dart';

import 'firebase_options.dart';

import 'package:permission_handler/permission_handler.dart';
import 'services/alarm/alarm_scheduler_service.dart';
import 'services/alarm/alarm_ringing_screen.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'package:all_in_one_scheduler/pages/reminder_page.dart';
import 'package:all_in_one_scheduler/pages/scheduler_page.dart';
import 'package:all_in_one_scheduler/pages/statistics_page.dart';
import 'package:all_in_one_scheduler/pages/alarm_page.dart';
import 'package:all_in_one_scheduler/pages/my_page.dart';

const platform = MethodChannel('com.example.all_in_one_scheduler/unlock');

// 전역 네비게이터 키
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //Alarm 패키지 초기화
  await Alarm.init();
  // Firebase 초기화
  await Firebase.initializeApp(
    name: '올인원 스케줄러',
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initializeDateFormatting('ko_KR', null);
  tz.initializeTimeZones();
  await _initializeNotifications();

  // 알람 스케줄러 초기화
  AlarmSchedulerService.navigatorKey = navigatorKey;
  await AlarmSchedulerService().initialize();

  runApp(const MyApp());
}

Future<void> _initializeNotifications() async {
  // 1. Android 초기화 설정
  // 'app_icon' 부분은 반드시 Android 리소스에 존재하는 파일 이름이어야 합니다.
  // (예: android/app/src/main/res/mipmap/app_icon.png)
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings(
      'mipmap/launcher_icon' // <-- **이 부분을 확인하세요! NullPointerException을 막습니다.**
  );

  // 2. iOS 및 macOS 초기화 설정
  // 요청할 권한을 설정합니다.
  const DarwinInitializationSettings initializationSettingsDarwin =
  DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  // 3. 전체 플랫폼 초기화 설정
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
    macOS: initializationSettingsDarwin,
  );

  // 4. 플러그인 초기화 실행
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    // onDidReceiveBackgroundNotificationResponse: onDidReceiveNotificationResponse, // 백그라운드 응답 처리 (필요시 추가)
  );
}

void onDidReceiveNotificationResponse(NotificationResponse notificationResponse) async {
  final String? payload = notificationResponse.payload;
  if (notificationResponse.payload != null) {
    debugPrint('Notification payload: $payload');
  }
  // 여기서 알림 페이로드에 따라 특정 화면으로 이동하거나 작업을 수행할 수 있습니다.
  // 예: navigatorKey.currentState?.pushNamed('/details', arguments: payload);
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _setupAlarmListener();
  }

  /// 알람 리스너 설정
  void _setupAlarmListener() {
    // 알람 스케줄러의 트리거 함수를 커스터마이즈
    AlarmSchedulerService.onAlarmTriggered = _showAlarmScreen;

    // 알람 스트림 리스닝 시작
    AlarmSchedulerService().startListening();
  }

  /// 알람 화면 표시
  Future<void> _showAlarmScreen() async {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    // 저장된 알람 정보 불러오기
    final prefs = await SharedPreferences.getInstance();
    final alarmsJson = prefs.getString('saved_alarms');

    String alarmTime = TimeOfDay.now().format(context);
    String alarmLabel = '알람';
    dynamic alarm;

    if (alarmsJson != null && alarmsJson.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(alarmsJson);
        final now = DateTime.now();

        // 현재 시간과 가장 가까운 활성화된 알람 찾기
        for (var alarmJson in decoded) {
          if (alarmJson['isEnabled'] == true) {
            final hour = alarmJson['alarmTime']['hour'];
            final minute = alarmJson['alarmTime']['minute'];

            // 현재 시간과 비교 (±5분 이내)
            final alarmDateTime = DateTime(now.year, now.month, now.day, hour, minute);
            final difference = now.difference(alarmDateTime).inMinutes.abs();

            if (difference <= 5) {
              alarm = alarmJson;
              alarmTime = TimeOfDay(hour: hour, minute: minute).format(context);
              break;
            }
          }
        }
      } catch (e) {
        print('알람 정보 파싱 오류: $e');
      }
    }

    // 알람 화면 표시
    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (context) => AlarmRingingScreen(
            alarm: alarm,
            alarmTime: alarmTime,
            alarmLabel: alarmLabel,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: '올인원 스케줄러',
      home: const HomePage(),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pages = [
       ReminderPage(),
       SchedulerPage(),
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
      _selectedIndex = index;
    });
  }

  Future<void> _checkOverlayPermission() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;

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
                        onPressed: () async {
                          await _requestOverlayPermission();
                          if (mounted) {
                            Navigator.of(context).pop();
                          }
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
          type: BottomNavigationBarType.fixed,
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
              label: '스케줄',
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
              label: '내 정보',
            ),
          ]
      ),
    );
  }
}