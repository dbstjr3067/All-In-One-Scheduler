import 'package:all_in_one_scheduler/services/alarm/quiz_type.dart';
import 'package:flutter/material.dart';

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

  // --- 추가 편의 기능 (선택 사항) ---

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

  // 반복 요일 목록을 한글 문자열로 변환 (예: "월 수 금 일")
  String get repeatDaysString {
    if (repeatDays.isEmpty) return '매일';

    const dayMap = {
      1: '월', 2: '화', 3: '수', 4: '목', 5: '금', 6: '토', 7: '일'
    };

    return repeatDays.map((day) => dayMap[day]).join(' ');
  }

  // 현재 알람 객체의 모든 정보를 Map<String, dynamic>으로 변환 (데이터 저장 시 유용)
  Map<String, dynamic> toJson() {
    return {
      'repeatDays': repeatDays,
      'alarmTimeHour': alarmTime.hour,
      'alarmTimeMinute': alarmTime.minute,
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
    final hour = json['alarmTimeHour'] as int;
    final minute = json['alarmTimeMinute'] as int;
    return Alarm(
      alarmTime: TimeOfDay(hour: hour, minute: minute),
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