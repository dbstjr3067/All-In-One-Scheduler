import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';

class AlarmSchedulerService {
  static final AlarmSchedulerService _instance = AlarmSchedulerService._internal();
  factory AlarmSchedulerService() => _instance;
  AlarmSchedulerService._internal();

  // 전역 네비게이터 키 (main.dart에서 설정)
  static GlobalKey<NavigatorState>? navigatorKey;

  // 알람 트리거 콜백 (main.dart에서 설정)
  static Function? onAlarmTriggered;

  /// 초기화
  Future<void> initialize() async {
    // Alarm 패키지 초기화
    await Alarm.init();
    print('Alarm 패키지 초기화 완료');
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

      await _scheduleOneTimeAlarm(index+1, scheduledTime, alarm);
    } else {
      // 반복 알람 - 다음 울릴 시간 계산
      DateTime nextAlarmTime = _getNextAlarmTime(now, alarmTime, alarm.repeatDays);
      await _scheduleOneTimeAlarm(index+1, nextAlarmTime, alarm);
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

    // AlarmSettings 생성
    final alarmSettings = AlarmSettings(
      id: id,
      dateTime: scheduledTime,
      assetAudioPath: alarm.soundAsset ?? 'assets/sounds/alarm.mp3',
      loopAudio: true,
      vibrate: true,
      allowAlarmOverlap: false,
      androidFullScreenIntent: true,
      warningNotificationOnKill: Platform.isIOS,
      notificationSettings: const NotificationSettings(
        title: '알람',
        body: '알람을 끌까요?',
        stopButton: '끄기',
        icon: 'notification_icon',
        iconColor: Color(0xFF7C6FDB),
      ),
      volumeSettings: VolumeSettings.fade(
        volume: 0.8, 
        fadeDuration: Duration(seconds: 10),
      )
    );

    // 알람 설정
    await Alarm.set(alarmSettings: alarmSettings);

    print('알람 스케줄링 완료: ID=$id, 시간=$scheduledTime');
  }

  /// 알람 취소
  Future<void> cancelAlarm(int id) async {
    await Alarm.stop(id);
    await _removeAlarmInfo(id);
    print('알람 취소: $id');
  }

  /// 모든 알람 재스케줄링 (알람 목록 전체)
  Future<void> rescheduleAllAlarms(List<dynamic> alarms) async {
    print('전체 알람 재스케줄링 시작: ${alarms.length}개');

    // 기존 알람 모두 취소
    await Alarm.stopAll();

    // 새로 스케줄링
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

  /// 알람 스트림 리스닝 시작
  void startListening() {
    // Alarm 패키지의 알람 스트림 구독
    Alarm.ringStream.stream.listen((alarmSettings) {
      print('알람 울림 감지: ID=${alarmSettings.id}');
      _triggerAlarmScreen();
    });
  }

  /// 알람 화면 트리거
  static void _triggerAlarmScreen() async {
    // main.dart에서 설정한 콜백 호출
    if (onAlarmTriggered != null) {
      await onAlarmTriggered!();
    } else {
      print('알람 트리거 콜백이 설정되지 않았습니다.');
    }
  }
}