import 'package:all_in_one_scheduler/services/alarm/quiz_type.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Alarm {
  // 알람이 울리는 요일 (월: 1, 화: 2, ..., 일: 7)
  // [1, 3, 5, 7] 은 월, 수, 금, 일을 의미합니다.
  List<int> repeatDays;

  // 알람이 울리는 시각 (예: TimeOfDay를 사용하여 시간과 분을 표현)
  TimeOfDay alarmTime;

  // 알람 On/Off 여부
  bool isEnabled;

  // 알람음 파일 경로 또는 이름
  String soundAsset;

  // 수학 퀴즈 시스템 설정 객체
  QuizType quizSetting;

  // 생성자
  Alarm({
    required this.alarmTime,
    this.repeatDays = const [], // 기본 설정: 매일
    this.isEnabled = true,
    this.soundAsset = 'assets/sounds/default_alarm.mp3',
    // 퀴즈 설정을 기본값으로 초기화
    QuizType? quizSetting,
  }) : this.quizSetting = quizSetting ?? QuizType(); // QuizType이 제공되지 않으면 기본 설정 사용

  // 객체의 특정 필드만 변경하여 새로운 Alarm 객체를 생성하는 메서드
  Alarm copyWith({
    TimeOfDay? alarmTime,
    List<int>? repeatDays,
    bool? isEnabled,
    soundAsset,
    QuizType? quizSetting,
  }) {
    return Alarm(
      alarmTime: alarmTime ?? this.alarmTime, // 값이 제공되지 않으면 기존 값 사용
      repeatDays: repeatDays ?? this.repeatDays,
      isEnabled: isEnabled ?? this.isEnabled,
      soundAsset: soundAsset ?? this.soundAsset,
      quizSetting: quizSetting ?? this.quizSetting,
    );
  }
  // 알람 시간을 HH:mm 형식의 문자열로 변환
  String get formattedTime {
    final hour = alarmTime.hour.toString().padLeft(2, '0');
    final minute = alarmTime.minute.toString().padLeft(2, '0');
    if (int.parse(hour) > 12){
      final hour2 = (alarmTime.hour - 12).toString().padLeft(2, '0');
      return '오후 $hour2:$minute';
    }
    else
      return '오전 $hour:$minute';
  }

  // TimeOfDay 객체를 Firestore Timestamp로 변환
  // 알람 시간만 저장하기 위해 임의의 날짜(2000/1/1) 사용
  Timestamp _timeOfDayToTimestamp(TimeOfDay time) {
    final dt = DateTime(2000, 1, 1, time.hour, time.minute);
    return Timestamp.fromDate(dt);
  }
  // 반복 요일 목록을 한글 문자열로 변환 (예: "월 수 금 일")
  String get repeatDaysString {
    if (repeatDays.length == 7) return '매일';
    else if(repeatDays.isEmpty){
      final now = DateTime.now();
      final tomorrow = DateTime.now().add(Duration(days: 1));
      final days = ['월', '화', '수', '목', '금', '토', '일'];
      if(DateTime.now().hour < alarmTime.hour || DateTime.now().hour == alarmTime.hour && DateTime.now().minute < alarmTime.minute) {
        final formatter = DateFormat('M월 d일');
        final weekday = days[now.weekday - 1]; // DateTime.weekday는 1(월)~7(일)
        return '오늘 - ${formatter.format(now)} ($weekday)';
      }
      else{
        final formatter = DateFormat('M월 d일');
        final weekday = days[tomorrow.weekday - 1]; // DateTime.weekday는 1(월)~7(일)
        return '내일 - ${formatter.format(tomorrow)} ($weekday)';
      }
    }
    const dayMap = {
      1: '월', 2: '화', 3: '수', 4: '목', 5: '금', 6: '토', 7: '일'
    };
    return '매주 '+repeatDays.map((day) => dayMap[day]).join(' ');
  }

  // 현재 알람 객체의 모든 정보를 Map<String, dynamic>으로 변환 (데이터 저장 시 유용)
  Map<String, dynamic> toJson() {
    return {
      'repeatDays': repeatDays,
      'alarmTime': {
        'hour': alarmTime.hour,
        'minute': alarmTime.minute,
      },
      'isEnabled': isEnabled,
      'soundAsset': soundAsset,
      'quizSetting': {
        'typeName': quizSetting.typeName,
        'difficulty': quizSetting.difficulty.index, // Enum은 인덱스로 저장
        'requiredCount': quizSetting.requiredCount,
      },
    };
  }

  // Map<String, dynamic>을 Alarm 객체로 변환 (데이터 로드 시 유용)
  factory Alarm.fromJson(Map<String, dynamic> json) {
    return Alarm(
      alarmTime: TimeOfDay(
        hour: json['alarmTime']['hour'] as int,
        minute: json['alarmTime']['minute'] as int,
      ),
      repeatDays: List<int>.from(json['repeatDays']),
      isEnabled: json['isEnabled'],
      soundAsset: json['soundAsset'],
      quizSetting: QuizType(
        typeName: json['quizSetting']['typeName'],
        difficulty: QuizDifficulty.values[json['quizSetting']['difficulty']],
        requiredCount: json['quizSetting']['requiredCount'],
      ),
    );
  }
}