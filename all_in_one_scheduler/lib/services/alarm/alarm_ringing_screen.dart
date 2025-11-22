import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:alarm/alarm.dart';
import 'quiz/alarm_quiz_math.dart';

class AlarmRingingScreen extends StatefulWidget {
  final dynamic alarm; // Alarm 객체
  final String alarmTime;
  final String alarmLabel;

  const AlarmRingingScreen({
    Key? key,
    this.alarm,
    required this.alarmTime,
    this.alarmLabel = '알람',
  }) : super(key: key);

  @override
  State<AlarmRingingScreen> createState() => _AlarmRingingScreenState();
}

class _AlarmRingingScreenState extends State<AlarmRingingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    // 애니메이션 컨트롤러 초기화
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  Future<void> _stopAlarm() async {
    await Alarm.stop(1);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  // 퀴즈 시작 또는 알람 끄기
  Future<void> _handleMainAction() async {
    // 퀴즈 설정 확인
    if (widget.alarm != null &&
        widget.alarm['quizSetting'] != null &&
        widget.alarm['quizSetting']['typeName'] != '없음') {

      if (mounted) {
        // 퀴즈 화면으로 이동
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => AlarmQuizMathScreen(
              alarm: widget.alarm,
            ),
          ),
        );

        // 퀴즈를 통과하면 알람 종료
        if (result == true) {
          _animationController.dispose();
          await Alarm.stopAll();
          if (mounted) {
            Navigator.of(context).pop();
          }
        }
      }
    } else {
      // 퀴즈가 없으면 바로 알람 끄기
      await _stopAlarm();
    }
  }

  // 현재 날짜와 요일 가져오기
  String _getCurrentDateString() {
    final now = DateTime.now();
    final weekdays = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
    final weekday = weekdays[now.weekday - 1];
    return '${now.month}월 ${now.day}일 $weekday';
  }

  String _getButtonText() {
    if (widget.alarm != null &&
        widget.alarm['quizSetting'] != null &&
        widget.alarm['quizSetting']['typeName'] != '없음') {
      return '퀴즈 시작';
    }
    return '알람 끄기';
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // 뒤로가기 버튼 비활성화
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 60),

                // 날짜 표시
                Text(
                  _getCurrentDateString(),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),

                // 시간 표시
                Text(
                  widget.alarmTime,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 80,
                    fontWeight: FontWeight.w300,
                    letterSpacing: -2,
                  ),
                ),

                const Spacer(),

                // 버튼들
                Column(
                  children: [
                    // 메인 버튼 (알람 끄기 또는 퀴즈 시작)
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: _handleMainAction,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF4757),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          _getButtonText(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}