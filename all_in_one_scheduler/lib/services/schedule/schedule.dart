import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Schedule {
  // 일정 제목
  String title;

  // 일정이 시작하는 시간
  Timestamp? startTime;
  // 매주 일정 실행?
  bool isAllDay;
  bool isRecurring;
  DateFormat sdf = new DateFormat("yyyy-MM-dd HH:mm:ss");
  // 생성자
  Schedule({
    required this.title,
    required this.isAllDay,
    this.startTime,
    required this.isRecurring,
  });
  String get formattedTime {
    if(isAllDay){
      final dateDayFormatter = DateFormat('MM월 dd일 (E)', 'ko_KR');
      final DayPart = dateDayFormatter.format(startTime!.toDate());
      return '$DayPart - 하루 종일';
    }
    else {
      final dateDayFormatter = DateFormat('MM월 dd일 (E)', 'ko_KR');
      final timeFormatter = DateFormat('a h:mm', 'ko_KR');
      final DayPart = dateDayFormatter.format(startTime!.toDate());
      final TimePart = timeFormatter.format(startTime!.toDate());
      return '$DayPart - $TimePart';
    }
  }
  // 현재 Schedule 객체의 모든 정보를 Map<String, dynamic>으로 변환 (데이터 저장 시 유용)
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'isAllDay': isAllDay,
      'startTime': startTime!.toDate().toIso8601String(),
      'isRecurring': isRecurring,
    };
  }

  // Map<String, dynamic>을 Schedule 객체로 변환 (데이터 로드 시 유용)
  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      title: json['title'],
      isAllDay: json['isAllDay'],
      startTime: Timestamp.fromDate(DateTime.parse(json['startTime'])),
      isRecurring: json['isRecurring'],
    );
  }
}