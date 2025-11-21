import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:all_in_one_scheduler/services/schedule/schedule.dart';
import 'package:all_in_one_scheduler/services/schedule/completion.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:all_in_one_scheduler/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReminderPage extends StatefulWidget {
  const ReminderPage({super.key});

  @override
  State<ReminderPage> createState() => ReminderPageState();
}

class ReminderPageState extends State<ReminderPage> with AutomaticKeepAliveClientMixin {
  List<Schedule> _allSchedules = [];
  List<Schedule> _todaySchedules = [];
  List<Completion> _completions = [];
  List<Completion> _todayCompletions = [];

  static const String _schedulesKey = 'saved_schedules';
  static const String _completionsKey = 'saved_completions';
  final FirestoreService _firestoreService = FirestoreService();

  late DateTime _selectedDate;

  // AutomaticKeepAliveClientMixin 필수 오버라이드
  @override
  bool get wantKeepAlive => true;

  // 오늘 날짜의 자정(00:00:00)을 반환하는 Getter
  DateTime get _todayMidnight {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    print('reminder_page: 이닛스테이트');
    final User? user = FirebaseAuth.instance.currentUser;
    if(user != null)
      _loadCompletionsFromFirestore();
    else
      _loadCompletionsFromLocal();
    _loadSchedules();
    _filterCompletionsForToday();
  }

  // ==================== 스케줄 불러오기 ====================

  Future<void> _loadSchedules() async {
    final User? user = FirebaseAuth.instance.currentUser;

    List<Schedule> allSchedules = [];

    if (user != null) {
      // Firestore에서 로드
      try {
        allSchedules = await _firestoreService.loadSchedules(user);
        print('reminder_page: Firestore에서 ${allSchedules.length}개의 스케줄 로드');
      } catch (e) {
        print('reminder_page: Firestore 로드 실패: $e');
      }
    }

    // Firestore 로드 실패 시 로컬에서 로드
    if (allSchedules.isEmpty) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final String? schedulesJson = prefs.getString(_schedulesKey);

        if (schedulesJson != null && schedulesJson.isNotEmpty) {
          final List<dynamic> decoded = jsonDecode(schedulesJson);
          allSchedules = decoded
              .map((json) => Schedule.fromJson(json as Map<String, dynamic>))
              .toList();
          print('reminder_page: 로컬에서 ${allSchedules.length}개의 스케줄 로드');
        }
      } catch (e) {
        print('reminder_page: 로컬 로드 실패: $e');
      }
    }

    setState(() {
      _allSchedules = allSchedules;
    });

    // 스케줄 로드 후 필터링
    _filterSchedulesForDate();
  }

  // ==================== 날짜별 필터링 ====================

  void _filterSchedulesForDate() {
    final now = _selectedDate;

    setState(() {
      _todaySchedules = _allSchedules.where((schedule) {
        if (schedule.startTime == null) return false;

        final scheduleDate = schedule.startTime!.toDate();

        if (schedule.isRecurring) {
          // 매주 반복: 요일이 같고, 시작일이 선택 날짜 이전이면 표시
          return scheduleDate.weekday == now.weekday &&
              scheduleDate.isBefore(now.add(Duration(days: 1)));
        } else {
          // 일회성: 정확히 같은 날짜
          return scheduleDate.year == now.year &&
              scheduleDate.month == now.month &&
              scheduleDate.day == now.day;
        }
      }).toList();

      // 시간순 정렬
      _todaySchedules.sort((a, b) {
        if (a.startTime == null && b.startTime == null) return 0;
        if (a.startTime == null) return 1;
        if (b.startTime == null) return -1;
        return a.startTime!.compareTo(b.startTime!);
      });
    });

    // 필터링 후 Completion 객체 생성
    _createCompletionsForFilteredSchedules();
  }

  // ==================== Completion 객체 생성 ====================

  void _createCompletionsForFilteredSchedules() {
    bool isChangeExist = false;
    // 선택된 날짜를 Timestamp로 변환 (시간은 00:00:00으로 설정)
    final selectedDateTimestamp = Timestamp.fromDate(
        DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day)
    );

    // 1단계: 오늘의 스케줄에 대해 Completion 생성/업데이트
    for (var schedule in _todaySchedules) {
      // 이미 해당 제목의 Completion이 있는지 확인
      final existingCompletion = _completions.firstWhere(
            (c) => c.title == schedule.title,
        orElse: () => Completion(title: '', progress: []),
      );

      if (existingCompletion.title.isEmpty) {
        // 새로운 Completion 생성
        final newCompletion = Completion(
          title: schedule.title,
          progress: [
            ProgressRecord(
              date: selectedDateTimestamp,
              isCompleted: false,
            )
          ],
        );
        setState(() {
          _completions.add(newCompletion);
        });
        isChangeExist = true;
      } else {
        // 기존 Completion에 오늘 날짜의 progress가 있는지 확인
        final hasToday = existingCompletion.progress.any((p) {
          final pDate = p.date.toDate();
          return pDate.year == _selectedDate.year &&
              pDate.month == _selectedDate.month &&
              pDate.day == _selectedDate.day;
        });

        if (!hasToday) {
          // 오늘 날짜의 progress 추가
          existingCompletion.progress.add(
              ProgressRecord(
                date: selectedDateTimestamp,
                isCompleted: false,
              )
          );
          isChangeExist = true;
        }
      }
    }

    // 2단계: 스케줄이 없는 Completion 제거
    // _allSchedules에 존재하지 않는 제목의 Completion을 찾아서 삭제
    final schedulesTitles = _allSchedules.map((s) => s.title).toSet();
    final completionsToRemove = <Completion>[];

    for (var completion in _completions) {
      if (!schedulesTitles.contains(completion.title)) {
        completionsToRemove.add(completion);
        print('reminder_page: 스케줄이 없는 Completion 발견: "${completion.title}"');
      }
    }

    if (completionsToRemove.isNotEmpty) {
      setState(() {
        _completions.removeWhere((c) => completionsToRemove.contains(c));
      });
      isChangeExist = true;
      print('reminder_page: ${completionsToRemove.length}개의 Completion 삭제됨');
    }

    if(isChangeExist){
      print('reminder_page: 변경사항발견');
      // Completion 저장 (로컬 + Firestore)
      _saveCompletionsToLocal();
      final User? user = FirebaseAuth.instance.currentUser;
      if(user != null)
        _saveCompletionsToFirestore(user);
    }

    // 오늘 날짜의 Completion만 필터링
    _filterCompletionsForToday();
  }

  // ==================== 오늘 날짜 Completion 필터링 ====================

  void _filterCompletionsForToday() {
    setState(() {
      if(_completions.length == 0){
        _todayCompletions = [];
        return;
      }
      _todayCompletions = _completions.where((completion) {
        // 이 Completion이 오늘 날짜의 progress를 가지고 있는지 확인
        return completion.progress.any((p) {
          final pDate = p.date.toDate();
          return pDate.year == _selectedDate.year &&
              pDate.month == _selectedDate.month &&
              pDate.day == _selectedDate.day;
        });
      }).toList();

      // 스케줄 순서와 동일하게 정렬 (제목 기준)
      _todayCompletions.sort((a, b) {
        final scheduleA = _todaySchedules.firstWhere(
              (s) => s.title == a.title,
          orElse: () => Schedule(title: '', startTime: null, isRecurring: false, isAllDay: false),
        );
        final scheduleB = _todaySchedules.firstWhere(
              (s) => s.title == b.title,
          orElse: () => Schedule(title: '', startTime: null, isRecurring: false, isAllDay: false),
        );

        if (scheduleA.startTime == null && scheduleB.startTime == null) return 0;
        if (scheduleA.startTime == null) return 1;
        if (scheduleB.startTime == null) return -1;
        return scheduleA.startTime!.compareTo(scheduleB.startTime!);
      });
    });
  }

  // ==================== Completion 체크/언체크 ====================

  void _toggleCompletion(Completion completion) {
    // 오늘 날짜의 progress 찾기
    final todayProgress = completion.progress.firstWhere(
          (p) {
        final pDate = p.date.toDate();
        return pDate.year == _selectedDate.year &&
            pDate.month == _selectedDate.month &&
            pDate.day == _selectedDate.day;
      },
      orElse: () => ProgressRecord(date: Timestamp.now(), isCompleted: false),
    );

    setState(() {
      // isCompleted 토글
      final index = completion.progress.indexOf(todayProgress);
      if (index != -1) {
        completion.progress[index] = ProgressRecord(
          date: todayProgress.date,
          isCompleted: !todayProgress.isCompleted,
        );
      }
    });

    // 저장 (로컬 + Firestore)
    _saveCompletionsToLocal();
    final User? user = FirebaseAuth.instance.currentUser;
    if(user != null)
      _saveCompletionsToFirestore(user);
  }

  // ==================== Completion 로컬 저장 ====================

  Future<void> _saveCompletionsToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> completionsMap =
      _completions.map((c) => c.toJson()).toList();
      final String completionsJson = jsonEncode(completionsMap);
      await prefs.setString(_completionsKey, completionsJson);
      print('reminder_page: ${_completions.length}개의 Completion을 로컬에 저장했습니다.');
    } catch (e) {
      print('reminder_page: Completion 로컬 저장 실패: $e');
    }
  }

  // ==================== Completion 로컬 로드 ====================

  Future<void> _loadCompletionsFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? completionsJson = prefs.getString(_completionsKey);

      if (completionsJson != null && completionsJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(completionsJson);
        setState(() {
          _completions = decoded
              .map((json) => Completion.fromJson(json as Map<String, dynamic>))
              .toList();
          _filterCompletionsForToday();
        });
        print('reminder_page: 로컬에서 ${_completions.length}개의 Completion을 불러왔습니다.');
      } else {
        print('reminder_page: 저장된 Completion이 없습니다.');
      }
    } catch (e) {
      print('reminder_page: 로컬 Completion 로드 실패: $e');
    }
  }

  // ==================== Completion Firestore 저장 ====================

  Future<void> _saveCompletionsToFirestore(User user) async {
    try {
      await _firestoreService.saveCompletions(user, _completions);
      print('reminder_page: ${_completions.length}개의 completion 목록을 Firestore에 성공적으로 저장했습니다.');
    } catch (e) {
      print('reminder_page: Firestore 저장 실패: $e');
    }
  }

  // ==================== Completion Firestore 로드 ====================

  Future<void> _loadCompletionsFromFirestore() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('reminder_page: Firestore 스케줄을 로드하려면 로그인이 필요합니다.');
      return;
    }
    try {
      final List<Completion> firestoreCompletions = await _firestoreService.loadCompletions(user);

      setState(() {
        // Firestore 데이터로 완전히 교체
        _completions = firestoreCompletions;
        _filterCompletionsForToday();
      });

      print('reminder_page: Firestore에서 ${_completions.length}개의 completion을 성공적으로 불러왔습니다.');

      // 로컬에도 Firestore 데이터로 덮어쓰기
      _saveCompletionsToLocal();

    } catch (e) {
      print('reminder_page: Firestore Completion 로드 실패: $e');
    }

    return;
  }

  //================== 스케줄이 삭제될 때 연결된 completion도 삭제 ===============
  void deleteCompletionByTitle(String title) {
    print('reminder_page: deleteCompletionByTitle 호출됨 - title: $title');

    setState(() {
      // Completion 삭제
      _completions.removeWhere((completion) => completion.title == title);

      // _allSchedules에서도 삭제
      _allSchedules.removeWhere((schedule) => schedule.title == title);
    });

    // 화면 새로고침
    _filterSchedulesForDate();

    // 저장
    _saveCompletionsToLocal();
    final User? user = FirebaseAuth.instance.currentUser;
    if(user != null) {
      _saveCompletionsToFirestore(user);
    }

    print('reminder_page: "$title" 제목의 Schedule과 Completion을 삭제했습니다.');
  }

  // ==================== 날짜 관련 함수 ====================

  String _getWeekdayName(int weekday) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return weekdays[weekday - 1];
  }

  String _getDateLabel() {
    final now = DateTime.now();

    if (_selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day) {
      return '오늘';
    }

    final month = _selectedDate.month;
    final day = _selectedDate.day;
    final weekday = _getWeekdayName(_selectedDate.weekday);

    return '$month-${day.toString().padLeft(2, '0')} ($weekday)';
  }

  void _goToPreviousDay() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    });
    _filterSchedulesForDate();
  }

  void _goToNextDay() {
    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 1));
    });
    _filterSchedulesForDate();
  }

  // ==================== UI ====================

  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveClientMixin 필수 호출

    final screenWidth = MediaQuery.of(context).size.width;

    // 선택된 날짜가 오늘인지 확인하는 변수
    final isSelectedDateToday = _selectedDate.year == _todayMidnight.year &&
        _selectedDate.month == _todayMidnight.month &&
        _selectedDate.day == _todayMidnight.day;

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
                  '오늘의 할일',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

            // Date Navigator
            Container(
              color: const Color(0xFFFFFBF5),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _getDateLabel(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: _goToPreviousDay,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      // 다음 날짜로 이동 버튼: 오늘 이상일 경우 비활성화
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        // 오늘이 선택된 경우 onPressed를 null로 설정하여 버튼 비활성화
                        onPressed: isSelectedDateToday ? null : _goToNextDay,
                        color: isSelectedDateToday ? Colors.grey : Colors.black, // 비활성화 시 색상 변경
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Completion List
            Expanded(
              child: _todayCompletions.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.event_available_outlined,
                      size: 64,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '할 일이 없습니다',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _todayCompletions.length,
                itemBuilder: (context, index) {
                  final completion = _todayCompletions[index];
                  final schedule = _todaySchedules.firstWhere(
                        (s) => s.title == completion.title,
                    orElse: () => Schedule(
                      title: completion.title,
                      startTime: null,
                      isRecurring: false,
                      isAllDay: false,
                    ),
                  );

                  // 오늘 날짜의 progress 찾기
                  final todayProgress = completion.progress.firstWhere(
                        (p) {
                      final pDate = p.date.toDate();
                      return pDate.year == _selectedDate.year &&
                          pDate.month == _selectedDate.month &&
                          pDate.day == _selectedDate.day;
                    },
                    orElse: () => ProgressRecord(
                      date: Timestamp.now(),
                      isCompleted: false,
                    ),
                  );

                  return GestureDetector(
                    onTap: () => _toggleCompletion(completion),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildCompletionItem(
                        completion: completion,
                        schedule: schedule,
                        isCompleted: todayProgress.isCompleted,
                        screenWidth: screenWidth,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionItem({
    required Completion completion,
    required Schedule schedule,
    required bool isCompleted,
    required double screenWidth,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: screenWidth * 0.025,
      ),
      decoration: BoxDecoration(
        color: isCompleted
            ? const Color(0xFFEBEBFF).withOpacity(0.5)
            : const Color(0xFFEBEBFF),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 왼쪽 컨텐츠
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 제목
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: TextStyle(
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.w500,
                    color: isCompleted
                        ? Colors.black45
                        : Colors.black,
                  ),
                  child: Text(completion.title),
                ),
                SizedBox(height: screenWidth * 0.01),
                // 시간
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: TextStyle(
                    fontSize: screenWidth * 0.042,
                    fontWeight: FontWeight.w400,
                    color: isCompleted
                        ? Colors.black38
                        : Colors.black.withOpacity(0.6),
                  ),
                  child: Text(
                    schedule.formattedTime,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // 체크박스 애니메이션
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isCompleted
                  ? const Color(0xFF7C6FDB)
                  : Colors.white,
              border: Border.all(
                color: const Color(0xFF7C6FDB),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: AnimatedScale(
              duration: const Duration(milliseconds: 200),
              scale: isCompleted ? 1.0 : 0.0,
              child: const Icon(
                Icons.check,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}