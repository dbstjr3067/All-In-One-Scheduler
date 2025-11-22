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
  State<StatisticsPage> createState() => StatisticsPageState();
}

class StatisticsPageState extends State<StatisticsPage> with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  List<Schedule> _allSchedules = [];
  List<Completion> _completions = [];
  List<Completion> _todayCompletions = [];

  static const String _schedulesKey = 'saved_schedules';
  static const String _completionsKey = 'saved_completions';
  final FirestoreService _firestoreService = FirestoreService();

  int _completedCount = 0;
  int _totalCount = 0;
  double _achievementRate = 0.0;
  bool _isLoading = true;

  // 캘린더용 변수
  late DateTime selectedDate;
  late DateTime displayMonth;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final now = DateTime.now();
    selectedDate = now;
    displayMonth = DateTime(now.year, now.month);

    _loadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      refreshData();
    }
  }

  // Public 메서드: 외부에서 데이터 새로고침 호출 가능
  Future<void> refreshData() async {
    print('statistics_page: refreshData 호출됨');
    await _loadData();
  }

  Future<void> _loadData() async {
    print('statistics_page: _loadData 시작');
    setState(() {
      _isLoading = true;
    });

    await _loadSchedules();
    await _loadCompletions();
    _calculateTodayStatistics();

    setState(() {
      _isLoading = false;
    });
    print('statistics_page: _loadData 완료');
  }

  Future<void> _loadSchedules() async {
    final User? user = FirebaseAuth.instance.currentUser;
    List<Schedule> allSchedules = [];

    if (user != null) {
      try {
        allSchedules = await _firestoreService.loadSchedules(user);
        print('statistics_page: Firestore에서 ${allSchedules.length}개의 스케줄 로드');
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
          print('statistics_page: 로컬에서 ${allSchedules.length}개의 스케줄 로드');
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
        print('statistics_page: Firestore에서 ${completions.length}개의 Completion 로드');
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
          print('statistics_page: 로컬에서 ${completions.length}개의 Completion 로드');
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

    print('statistics_page: 통계 계산 완료 - 완료: $_completedCount / 전체: $_totalCount (${_achievementRate.toInt()}%)');
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

  // 특정 날짜의 달성률 계산
  double _getAchievementRateForDate(DateTime date) {
    // 해당 날짜의 스케줄 필터링
    final dateSchedules = _allSchedules.where((schedule) {
      if (schedule.startTime == null) return false;

      final scheduleDate = schedule.startTime!.toDate();

      if (schedule.isRecurring) {
        return scheduleDate.weekday == date.weekday &&
            scheduleDate.isBefore(date.add(Duration(days: 1)));
      } else {
        return scheduleDate.year == date.year &&
            scheduleDate.month == date.month &&
            scheduleDate.day == date.day;
      }
    }).toList();

    if (dateSchedules.isEmpty) return -1; // 스케줄 없음

    // 해당 날짜의 Completion 필터링
    final dateCompletions = _completions.where((completion) {
      return completion.progress.any((p) {
        final pDate = p.date.toDate();
        return pDate.year == date.year &&
            pDate.month == date.month &&
            pDate.day == date.day;
      });
    }).toList();

    if (dateCompletions.isEmpty) return 0.0; // Completion 없음 = 0%

    // 완료된 항목 개수 계산
    int completedCount = 0;
    for (var completion in dateCompletions) {
      final dateProgress = completion.progress.firstWhere(
            (p) {
          final pDate = p.date.toDate();
          return pDate.year == date.year &&
              pDate.month == date.month &&
              pDate.day == date.day;
        },
        orElse: () => ProgressRecord(date: Timestamp.now(), isCompleted: false),
      );

      if (dateProgress.isCompleted) {
        completedCount++;
      }
    }

    return (completedCount / dateSchedules.length) * 100;
  }

  // 달성률에 따른 색상 반환
  Color _getStreakColor(double achievementRate) {
    if (achievementRate < 0) {
      // 스케줄 없음 (흰색)
      return Colors.grey[300]!;
    } else if (achievementRate >= 100) {
      // 100% 달성 (진한 보라)
      return const Color(0xFF5B4FCF);
    } else if (achievementRate >= 50) {
      // 50% 이상 (중간 보라)
      return const Color(0xFFD0BCFF);
    } else if (achievementRate >= 33) {
      // 33% 이상 (연한 보라)
      return const Color(0xFFECE2FF);
    } else {
      // 33% 미만 (회색)
      return const Color(0xFFD9D9D9);
    }
  }

  String getMonthName(int month) {
    const months = [
      '1월', '2월', '3월', '4월', '5월', '6월',
      '7월', '8월', '9월', '10월', '11월', '12월'
    ];
    return months[month - 1];
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
                  '통계',
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
              child: _isLoading
                  ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: Color(0xFF7C6FDB),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '로딩중..',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
                  : SingleChildScrollView(
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
                              strokeWidth: 25,
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
                          incompleteCompletions.isEmpty
                              ? '모든 할 일을 완료했어요! 🎉'
                              : '오늘 목표의 ${_achievementRate.toInt()}%를 달성했어요!',
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
                      if (incompleteCompletions.isNotEmpty)
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
                      if (incompleteCompletions.isNotEmpty)
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
                                          schedule.formattedTime(selectedDate),
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

                      const SizedBox(height: 40),

                      // 월별 스케줄 달성 타이틀
                      const Text(
                        '월별 스케줄 달성',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 캘린더
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBF5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            // Month Navigation
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${displayMonth.year}년 ${getMonthName(displayMonth.month)}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.chevron_left),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: () {
                                          setState(() {
                                            displayMonth = DateTime(
                                              displayMonth.year,
                                              displayMonth.month - 1,
                                            );
                                          });
                                        },
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.chevron_right),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: () {
                                          setState(() {
                                            (displayMonth.year == DateTime.now().year &&
                                                displayMonth.month == DateTime.now().month) ?
                                            null : displayMonth = DateTime(
                                              displayMonth.year,
                                              displayMonth.month + 1,
                                            );
                                          });
                                        },
                                        color: (displayMonth.year == DateTime.now().year &&
                                            displayMonth.month == DateTime.now().month) ? Colors.grey : Colors.black,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Weekday Headers
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: ['월', '화', '수', '목', '금', '토', '일']
                                  .map((day) => SizedBox(
                                width: 45,
                                child: Center(
                                  child: Text(
                                    day,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ))
                                  .toList(),
                            ),

                            const SizedBox(height: 1),

                            // Calendar Grid
                            _buildCalendarGrid(screenWidth),
                          ],
                        ),
                      ),
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

  Widget _buildCalendarGrid(double screenWidth) {
    final firstDayOfMonth = DateTime(displayMonth.year, displayMonth.month, 1);
    final lastDayOfMonth = DateTime(displayMonth.year, displayMonth.month + 1, 0);
    // 캘린더는 월요일(1)부터 시작하므로, 첫날이 월요일이 아니면 그만큼 빈칸이 필요함
    final firstWeekday = firstDayOfMonth.weekday - 1;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 날짜 블록의 크기
    const double dayBlockSize = 36;
    // 간격 조정을 위한 패딩 값
    const double dayPadding = 4.0;
    // 실제 Row에서 차지하는 공간 (36 + 4*2 = 44)
    final double daySpace = dayBlockSize + dayPadding * 2;

    List<Widget> dayWidgets = [];

    // Empty cells before the first day
    for (int i = 0; i < firstWeekday; i++) {
      dayWidgets.add(SizedBox(width: daySpace, height: daySpace)); // 간격과 동일한 크기의 빈 공간
    }

    // Days of the month
    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      final date = DateTime(displayMonth.year, displayMonth.month, day);
      final achievementRate = _getAchievementRateForDate(date);
      final streakColor = _getStreakColor(achievementRate);
      final hasNoSchedule = achievementRate < 0;

      Widget dayWidget = Container(
        width: dayBlockSize,
        height: dayBlockSize,
        decoration: BoxDecoration(
          color: (hasNoSchedule || date.isAfter(today)) ? Colors.transparent : streakColor,
          borderRadius: BorderRadius.circular(10), // 모서리 둥글게
          border: hasNoSchedule || date.isAfter(today)
              ? Border.all(
            color: Colors.grey[300]!,
            width: 2,
            strokeAlign: BorderSide.strokeAlignInside,
          ) : null,
        ),
      );

      // 각 날짜 위젯에 패딩을 주어 간격 확보
      dayWidgets.add(
        Padding(
          padding: const EdgeInsets.all(dayPadding),
          child: dayWidget,
        ),
      );
    }

    // Fill remaining cells to complete the last row
    while (dayWidgets.length % 7 != 0) {
      dayWidgets.add(SizedBox(width: daySpace, height: daySpace));
    }

    return Column(
      children: List.generate(
        (dayWidgets.length / 7).ceil(),
            (weekIndex) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2), // 주간 간격 추가
            child: Row(
              // mainAxisAlignment: MainAxisAlignment.spaceAround 대신 중앙 정렬로 변경
              mainAxisAlignment: MainAxisAlignment.center,
              children: dayWidgets.skip(weekIndex * 7).take(7).toList(),
            ),
          );
        },
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