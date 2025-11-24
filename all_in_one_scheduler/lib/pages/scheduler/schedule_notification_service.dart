import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ScheduleNotificationService {
  static final ScheduleNotificationService _instance = ScheduleNotificationService._internal();
  factory ScheduleNotificationService() => _instance;
  ScheduleNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  static const String _scheduledNotificationsKey = 'scheduled_notifications';

  // 알림 ID 범위
  static const int dailySummaryIdStart = 10000; // 일일 요약 알림 ID
  static const int individualNotificationIdStart = 20000; // 개별 알림 ID

  /// 초기화
  Future<void> initialize() async {
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

    // 권한 요청
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// 알림 탭 처리
  void _onNotificationTapped(NotificationResponse response) {
    print('알림 탭됨: ${response.payload}');
  }

  /// Schedule 객체 목록으로부터 알림 예약
  Future<void> scheduleNotificationsFromSchedules(List<dynamic> schedules) async {
    print('schedule_notification_service: 스케줄 알림 예약 시작 - ${schedules.length}개');

    // 1. 기존 모든 알림 취소
    await cancelAllScheduleNotifications();

    // 2. 날짜별로 스케줄 그룹화
    final Map<String, List<dynamic>> schedulesByDate = _groupSchedulesByDate(schedules);
    // 3. 각 날짜에 대해 아침 8시 요약 알림 예약
    int summaryId = dailySummaryIdStart;
    for (var entry in schedulesByDate.entries) {
      final date = entry.key;
      final daySchedules = entry.value;

      await _scheduleDailySummaryNotification(
        summaryId++,
        DateTime.parse(date),
        daySchedules,
      );
    }

    // 4. 개별 스케줄 30분 전 알림 예약 (하루 종일이 아닌 경우만)
    int individualId = individualNotificationIdStart;
    for (var schedule in schedules) {
      final isAllDay = schedule['isAllDay'] ?? true;
      final startTime = schedule['startTime'];

      if (!isAllDay && startTime != null) {
        await _scheduleIndividualNotification(
          individualId++,
          schedule,
        );
      }
    }

    // 5. 예약된 알림 정보 저장
    await _saveScheduledNotifications(schedulesByDate);

    print('schedule_notification_service: 스케줄 알림 예약 완료');
  }

  /// 날짜별로 스케줄 그룹화
  Map<String, List<dynamic>> _groupSchedulesByDate(List<dynamic> schedules) {
    final Map<String, List<dynamic>> grouped = {};
    final now = DateTime.now();

    for (var schedule in schedules) {
      final String startTime = schedule['startTime'];

      final DateTime startDate = DateTime.parse(startTime);
      final bool isRecurring = schedule['isRecurring'] ?? false;

      if (isRecurring) {
        // 주마다 반복: 다음 14일 동안의 해당 요일에 추가
        final int weekday = startDate.weekday;

        for (int i = 0; i < 14; i++) {
          final checkDate = now.add(Duration(days: i));
          if (checkDate.weekday == weekday) {
            final dateKey = _getDateKey(checkDate);
            grouped[dateKey] = grouped[dateKey] ?? [];
            grouped[dateKey]!.add(schedule);
          }
        }
      } else {
        // 일회성 스케줄
        if (startDate.isAfter(now.subtract(const Duration(days: 1)))) {
          final dateKey = _getDateKey(startDate);
          grouped[dateKey] = grouped[dateKey] ?? [];
          grouped[dateKey]!.add(schedule);
        }
      }
    }

    return grouped;
  }

  /// 일일 요약 알림 예약 (아침 8시)
  Future<void> _scheduleDailySummaryNotification(
      int id,
      DateTime date,
      List<dynamic> daySchedules,
      ) async {
    // 해당 날짜의 아침 8시
    final scheduledDate = DateTime(date.year, date.month, date.day, 8, 0);

    // 과거 시간이면 예약하지 않음
    if (scheduledDate.isBefore(DateTime.now())) {
      //과거 날짜 알림 스킵
      return;
    }

    // 알림 제목
    final title = '오늘은 ${daySchedules.length}개의 스케줄이 있어요';

    // 알림 내용 (스케줄 목록)
    final buffer = StringBuffer();
    for (var schedule in daySchedules) {
      final title = schedule['title'] ?? '제목 없음';
      final isAllDay = schedule['isAllDay'] ?? true;
      final startTime = Timestamp.fromDate(DateTime.parse(schedule['startTime']));

      if (isAllDay) {
        buffer.writeln('$title - 하루 종일');
      } else {
        final timeFormatter = DateFormat('a h:mm', 'ko_KR');
        final timeStr = timeFormatter.format(startTime.toDate());
        buffer.writeln('$title - $timeStr');
      }
    }
    final body = buffer.toString().trim();

    await _scheduleNotification(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      payload: 'daily_summary_${_getDateKey(date)}',
    );
    print('schedule_notification_service: 요약 알림 예약 - $scheduledDate - $title');
  }

  /// 개별 스케줄 30분 전 알림 예약
  Future<void> _scheduleIndividualNotification(
      int id,
      dynamic schedule,
      ) async {
    final String startTime = schedule['startTime'];

    final String title = schedule['title'] ?? '스케줄';
    final bool isRecurring = schedule['isRecurring'] ?? false;
    final DateTime startDateTime = DateTime.parse(startTime);

    if (isRecurring) {
      // 주마다 반복: 다음 2주치 예약
      final int weekday = startDateTime.weekday;
      final now = DateTime.now();

      int scheduleCount = 0;
      for (int i = 0; i < 14; i++) {
        final checkDate = now.add(Duration(days: i));
        if (checkDate.weekday == weekday) {
          final scheduleDateTime = DateTime(
            checkDate.year,
            checkDate.month,
            checkDate.day,
            startDateTime.hour,
            startDateTime.minute,
          );

          // 30분 전
          final notificationTime = scheduleDateTime.subtract(const Duration(minutes: 30));

          if (notificationTime.isAfter(DateTime.now())) {
            final timeFormatter = DateFormat('a h:mm', 'ko_KR');
            final timeStr = timeFormatter.format(scheduleDateTime);
            await _scheduleNotification(
              id: id + scheduleCount,
              title: '$timeStr 에 완수할 스케줄이 있어요',
              body: '$title - $timeStr',
              scheduledDate: notificationTime,
              payload: 'individual_${schedule['title']}_${_getDateKey(checkDate)}',
            );
            scheduleCount++;
            print('개별 알림 예약: $notificationTime - $title');
          }
        }
      }
    } else {
      // 일회성 스케줄
      // 30분 전
      final notificationTime = startDateTime.subtract(const Duration(minutes: 30));

      if (notificationTime.isAfter(DateTime.now())) {
        final timeFormatter = DateFormat('a h:mm', 'ko_KR');
        final timeStr = timeFormatter.format(startDateTime);
        await _scheduleNotification(
          id: id,
          title: '$timeStr 에 완수할 스케줄이 있어요.',
          body: '$title - $timeStr',
          scheduledDate: notificationTime,
          payload: 'individual_$title',
        );

        print('개별 알림 예약: $notificationTime - $title');
      }
    }
  }

  /// 알림 예약 (공통)
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'schedule_channel',
      '스케줄 알림',
      channelDescription: '일정 알림',
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(body),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  /// 모든 스케줄 알림 취소
  Future<void> cancelAllScheduleNotifications() async {
    await _notificationsPlugin.cancelAll();
    print('모든 스케줄 알림 취소됨');
  }

  /// 특정 알림 취소
  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  /// 예약된 알림 정보 저장
  Future<void> _saveScheduledNotifications(Map<String, List<dynamic>> schedulesByDate) async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'lastScheduled': DateTime.now().toIso8601String(),
      'scheduleCount': schedulesByDate.values.fold(0, (sum, list) => sum + list.length),
    };
    await prefs.setString(_scheduledNotificationsKey, jsonEncode(data));
  }

  /// 날짜 키 생성 (yyyy-MM-dd)
  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}