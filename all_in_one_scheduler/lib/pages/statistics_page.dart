import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math' as math;
import 'package:all_in_one_scheduler/services/schedule/schedule.dart';
import 'package:all_in_one_scheduler/services/schedule/completion.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:all_in_one_scheduler/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> with AutomaticKeepAliveClientMixin {
  List<Schedule> _allSchedules = [];
  List<Completion> _completions = [];
  List<Completion> _todayCompletions = [];

  static const String _schedulesKey = 'saved_schedules';
  static const String _completionsKey = 'saved_completions';
  final FirestoreService _firestoreService = FirestoreService();

  int _completedCount = 0;
  int _totalCount = 0;
  double _achievementRate = 0.0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadSchedules();
    await _loadCompletions();
    _calculateTodayStatistics();
  }

  Future<void> _loadSchedules() async {
    final User? user = FirebaseAuth.instance.currentUser;
    List<Schedule> allSchedules = [];

    if (user != null) {
      try {
        allSchedules = await _firestoreService.loadSchedules(user);
      } catch (e) {
        print('statistics_page: Firestore 로드 실패: $e');
      }
    }

    if (allSchedules.isEmpty) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final String? schedulesJson = prefs.getString(_schedulesKey);

        if (schedulesJson != null && schedulesJson.isNotEmpty) {
          final List<dynamic> decoded = jsonDecode(schedulesJson);
          allSchedules = decoded
              .map((json) => Schedule.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      } catch (e) {
        print('statistics_page: 로컬 로드 실패: $e');
      }
    }

    setState(() {
      _allSchedules = allSchedules;
    });
  }

  Future<void> _loadCompletions() async {
    final User? user = FirebaseAuth.instance.currentUser;
    List<Completion> completions = [];

    if (user != null) {
      try {
        completions = await _firestoreService.loadCompletions(user);
      } catch (e) {
        print('statistics_page: Firestore Completion 로드 실패: $e');
      }
    }

    if (completions.isEmpty) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final String? completionsJson = prefs.getString(_completionsKey);

        if (completionsJson != null && completionsJson.isNotEmpty) {
          final List<dynamic> decoded = jsonDecode(completionsJson);
          completions = decoded
              .map((json) => Completion.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      } catch (e) {
        print('statistics_page: 로컬 Completion 로드 실패: $e');
      }
    }

    setState(() {
      _completions = completions;
    });
  }

  void _calculateTodayStatistics() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 오늘 날짜의 스케줄 필터링
    final todaySchedules = _allSchedules.where((schedule) {
      if (schedule.startTime == null) return false;

      final scheduleDate = schedule.startTime!.toDate();

      if (schedule.isRecurring) {
        return scheduleDate.weekday == today.weekday &&
            scheduleDate.isBefore(today.add(Duration(days: 1)));
      } else {
        return scheduleDate.year == today.year &&
            scheduleDate.month == today.month &&
            scheduleDate.day == today.day;
      }
    }).toList();

    // 오늘 날짜의 Completion 필터링
    final todayCompletions = _completions.where((completion) {
      return completion.progress.any((p) {
        final pDate = p.date.toDate();
        return pDate.year == today.year &&
            pDate.month == today.month &&
            pDate.day == today.day;
      });
    }).toList();

    // 완료된 항목 개수 계산
    int completedCount = 0;
    for (var completion in todayCompletions) {
      final todayProgress = completion.progress.firstWhere(
            (p) {
          final pDate = p.date.toDate();
          return pDate.year == today.year &&
              pDate.month == today.month &&
              pDate.day == today.day;
        },
        orElse: () => ProgressRecord(date: Timestamp.now(), isCompleted: false),
      );

      if (todayProgress.isCompleted) {
        completedCount++;
      }
    }

    setState(() {
      _todayCompletions = todayCompletions;
      _totalCount = todaySchedules.length;
      _completedCount = completedCount;
      _achievementRate = _totalCount > 0 ? (_completedCount / _totalCount) * 100 : 0;
    });
  }

  List<Completion> _getIncompleteCompletions() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return _todayCompletions.where((completion) {
      final todayProgress = completion.progress.firstWhere(
            (p) {
          final pDate = p.date.toDate();
          return pDate.year == today.year &&
              pDate.month == today.month &&
              pDate.day == today.day;
        },
        orElse: () => ProgressRecord(date: Timestamp.now(), isCompleted: false),
      );

      return !todayProgress.isCompleted;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final screenWidth = MediaQuery.of(context).size.width;
    final incompleteCompletions = _getIncompleteCompletions();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: const Color(0xFFD4D4E8),
              padding: const EdgeInsets.all(16),
              child: const Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  '목표',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 목표달성률 타이틀
                      const Text(
                        '목표달성률',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),

                      const SizedBox(height: 30),

                      // 원형 진행률 그래프
                      Center(
                        child: SizedBox(
                          width: 250,
                          height: 250,
                          child: CustomPaint(
                            painter: CircularProgressPainter(
                              progress: _achievementRate / 100,
                              strokeWidth: 13,
                            ),
                            child: Center(
                              child: Text(
                                '${_achievementRate.toInt()}%',
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 달성 메시지
                      Center(
                        child: Text(
                          (incompleteCompletions.isEmpty) ?
                          '모든 할 일을 완료했어요! 🎉' : '오늘 목표의 ${_achievementRate.toInt()}%를 달성했어요!',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // 완료/전체 개수
                      Center(
                        child: Text(
                          '($_completedCount/$_totalCount 완료)',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // 남은 할 일 타이틀
                      if (!incompleteCompletions.isEmpty)
                        const Text(
                        '남은 할 일이 있어요!!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 미완료 항목 리스트
                      if (!incompleteCompletions.isEmpty)
                        ...incompleteCompletions.map((completion) {
                          final schedule = _allSchedules.firstWhere(
                                (s) => s.title == completion.title,
                            orElse: () => Schedule(
                              title: completion.title,
                              startTime: null,
                              isRecurring: false,
                              isAllDay: false,
                            ),
                          );

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.05,
                                vertical: screenWidth * 0.03,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEBEBFF),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(13),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // 체크박스 (비활성화)
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                        color: const Color(0xFF7C6FDB),
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  // 할 일 내용
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          completion.title,
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.045,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          schedule.formattedTime,
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.035,
                                            color: Colors.black.withOpacity(0.6),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 원형 진행률 그래프를 그리는 CustomPainter
class CircularProgressPainter extends CustomPainter {
  final double progress; // 0.0 ~ 1.0
  final double strokeWidth;

  CircularProgressPainter({
    required this.progress,
    this.strokeWidth = 20,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // 배경 원 (회색)
    final backgroundPaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // 진행률 원 (보라색)
    final progressPaint = Paint()
      ..color = const Color(0xFF7C6FDB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // 시작 각도 (12시 방향)
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}