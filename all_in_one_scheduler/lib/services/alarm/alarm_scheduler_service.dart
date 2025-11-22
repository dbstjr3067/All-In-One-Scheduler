import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/material.dart';

class AlarmSchedulerService {
  static final AlarmSchedulerService _instance = AlarmSchedulerService._internal();
  factory AlarmSchedulerService() => _instance;
  AlarmSchedulerService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // 전역 네비게이터 키 (main.dart에서 설정)
  static GlobalKey<NavigatorState>? navigatorKey;

  /// 초기화
  Future<void> initialize() async {
    // Android Alarm Manager 초기화
    await AndroidAlarmManager.initialize();

    // 알림 초기화
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Android 13+ 알림 권한 요청
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// Alarm 객체를 받아서 알람 스케줄링
  Future<void> scheduleAlarmFromObject(dynamic alarm, int index) async {
    if (!alarm.isEnabled) {
      // 알람이 비활성화되어 있으면 기존 알람 취소
      await cancelAlarm(index);
      return;
    }

    final now = DateTime.now();
    final alarmTime = alarm.alarmTime as TimeOfDay;

    // repeatDays가 비어있으면 일회성 알람
    if (alarm.repeatDays.isEmpty) {
      DateTime scheduledTime = DateTime(
        now.year,
        now.month,
        now.day,
        alarmTime.hour,
        alarmTime.minute,
      );

      // 현재 시간보다 이전이면 다음날로 설정
      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }

      await _scheduleOneTimeAlarm(index, scheduledTime, alarm);
    } else {
      // 반복 알람 - 다음 울릴 시간 계산
      DateTime nextAlarmTime = _getNextAlarmTime(now, alarmTime, alarm.repeatDays);
      await _scheduleOneTimeAlarm(index, nextAlarmTime, alarm);
    }
  }

  /// 다음 알람 시간 계산 (반복 요일 기반)
  DateTime _getNextAlarmTime(DateTime now, TimeOfDay alarmTime, List<int> repeatDays) {
    DateTime candidateTime = DateTime(
      now.year,
      now.month,
      now.day,
      alarmTime.hour,
      alarmTime.minute,
    );

    // 오늘 시간이 지났으면 내일부터 시작
    if (candidateTime.isBefore(now)) {
      candidateTime = candidateTime.add(const Duration(days: 1));
    }

    // 최대 7일 동안 검색
    for (int i = 0; i < 7; i++) {
      int weekday = candidateTime.weekday; // 1(월) ~ 7(일)

      if (repeatDays.contains(weekday)) {
        return candidateTime;
      }

      candidateTime = candidateTime.add(const Duration(days: 1));
    }

    return candidateTime;
  }

  /// 일회성 알람 스케줄링
  Future<void> _scheduleOneTimeAlarm(int id, DateTime scheduledTime, dynamic alarm) async {
    // 알람 정보 저장
    await _saveAlarmInfo(id, scheduledTime, alarm);

    // Android Alarm Manager로 정확한 시간에 실행
    await AndroidAlarmManager.oneShotAt(
      scheduledTime,
      id,
      _alarmCallback,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
    );

    print('알람 스케줄링 완료: ID=$id, 시간=$scheduledTime');
  }

  /// 알람 취소
  Future<void> cancelAlarm(int id) async {
    await AndroidAlarmManager.cancel(id);
    await _removeAlarmInfo(id);
    await _notificationsPlugin.cancel(id);
    print('알람 취소: $id');
  }

  /// 모든 알람 재스케줄링 (알람 목록 전체)
  Future<void> rescheduleAllAlarms(List<dynamic> alarms) async {
    print('전체 알람 재스케줄링 시작: ${alarms.length}개');

    for (int i = 0; i < alarms.length; i++) {
      await scheduleAlarmFromObject(alarms[i], i);
    }

    print('전체 알람 재스케줄링 완료');
  }

  /// 알람 정보 저장
  Future<void> _saveAlarmInfo(int id, DateTime time, dynamic alarm) async {
    final prefs = await SharedPreferences.getInstance();
    final alarmData = {
      'id': id,
      'time': time.toIso8601String(),
      'alarmJson': alarm.toJson(),
    };
    await prefs.setString('alarm_$id', jsonEncode(alarmData));
  }

  /// 알람 정보 삭제
  Future<void> _removeAlarmInfo(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('alarm_$id');
  }

  /// 알람 정보 가져오기
  Future<Map<String, dynamic>?> getAlarmInfo(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('alarm_$id');
    if (data != null) {
      return jsonDecode(data);
    }
    return null;
  }

  /// 알림 탭 처리
  void _onNotificationTapped(NotificationResponse response) {
    print('알림 탭됨: ${response.payload}');
    _triggerAlarmScreen();
  }

  /// 알람 콜백 (백그라운드에서 실행)
  @pragma('vm:entry-point')
  static Future<void> _alarmCallback() async {
    print('알람 콜백 실행됨');

    final service = AlarmSchedulerService();
    await service._showAlarmNotification();
  }

  /// 알람 알림 표시 (Full Screen Intent)
  Future<void> _showAlarmNotification() async {
    final androidDetails = AndroidNotificationDetails(
      'alarm_channel',
      '알람',
      channelDescription: '알람 알림',
      importance: Importance.max,
      priority: Priority.max,
      category: AndroidNotificationCategory.alarm,
      fullScreenIntent: true,
      playSound: true,
      enableVibration: true,
      ongoing: true,
      autoCancel: false,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.critical,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      0,
      '알람',
      '알람이 울립니다',
      notificationDetails,
      payload: 'alarm_triggered',
    );

    // 알람 화면 트리거
    _triggerAlarmScreen();
  }

  /// 알람 화면 트리거
  void _triggerAlarmScreen() {
    if (navigatorKey?.currentContext != null) {
      // 알람 화면으로 이동하는 로직
      // main.dart에서 처리
    }
  }
}