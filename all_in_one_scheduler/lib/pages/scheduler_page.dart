import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:core';
import 'package:all_in_one_scheduler/services/schedule/schedule.dart';
import 'package:all_in_one_scheduler/pages/scheduler/schedule_setting_page.dart';
import 'package:all_in_one_scheduler/pages/scheduler/schedule_notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:all_in_one_scheduler/services/firestore_service.dart';

class SchedulerPage extends StatefulWidget {
  final Function(String title)? onScheduleDeleted;

  const SchedulerPage({Key? key, this.onScheduleDeleted}) : super(key: key);

  @override
  State<SchedulerPage> createState() => _SchedulerPageState();
}

class _SchedulerPageState extends State<SchedulerPage> {
  List<Schedule> _schedules = [];
  List<Schedule> _filteredSchedules = [];
  static const Color _cardColor = Color(0xFFEBEBFF);
  static const String _schedulesKey = 'saved_schedules';
  late DateTime selectedDate;
  late DateTime displayMonth;

  final FirestoreService _firestoreService = FirestoreService();
  final ScheduleNotificationService _notificationService = ScheduleNotificationService();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedDate = now;
    displayMonth = DateTime(now.year, now.month);

    final User? user = FirebaseAuth.instance.currentUser;
    if(user != null)
      _loadSchedulesFromFirestore();
    else
      _loadSchedulesFromLocal();
  }

  Future<void> _loadSchedulesFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? schedulesJson = prefs.getString(_schedulesKey);

      if (schedulesJson != null && schedulesJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(schedulesJson);

        setState(() {
          _schedules = decoded
              .map((json) => Schedule.fromJson(json as Map<String, dynamic>))
              .toList();
          _filterSchedulesForSelectedDate();
        });
        print('scheduler_page: 로컬에서 ${_schedules.length}개의 스케줄을 불러왔습니다.');

        await _scheduleNotifications();
      } else {
        print('scheduler_page: 저장된 스케줄이 없습니다.');
      }
    } catch (e) {
      print('scheduler_page: 스케줄 불러오기 실패: $e');
    }
  }

  Future<void> _saveSchedulesToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> alarmsMap =
      _schedules.map((alarm) => alarm.toJson()).toList();
      final String alarmsJson = jsonEncode(alarmsMap);
      await prefs.setString(_schedulesKey, alarmsJson);
      print('schedule_page: ${_schedules.length}개의 스케줄을 로컬에 저장했습니다.');
      await _scheduleNotifications();
    } catch (e) {
      print('schedule_page: 스케줄 저장 실패: $e');
    }
  }

  Future<void> _loadSchedulesFromFirestore() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('schedule_page: Firestore 스케줄을 로드하려면 로그인이 필요합니다.');
      return;
    }

    try {
      final List<Schedule> firestoreSchedules = await _firestoreService.loadSchedules(user);

      if (firestoreSchedules.isNotEmpty) {
        setState(() {
          _schedules = firestoreSchedules;
          _filterSchedulesForSelectedDate();
        });
        print('schedule_page: Firestore에서 ${_schedules.length}개의 스케줄을 성공적으로 불러왔습니다.');
        _saveSchedulesToLocal();
      } else {
        print('schedule_page: Firestore에 저장된 스케줄이 없습니다.');
      }
    } catch (e) {
      print('schedule_page: Firestore 스케줄 로드 실패: $e');
    }
  }

  Future<void> _saveSchedulesToFirestore(User user) async {
    try {
      await _firestoreService.saveSchedules(user, _schedules);
      print('schedule_page: ${_schedules.length}개의 스케줄 목록을 Firestore에 성공적으로 저장했습니다.');
    } catch (e) {
      print('schedule_page: 스케줄 목록 Firestore 저장 실패: $e');
    }
  }

  Future<void> _scheduleNotifications() async {
    // Schedule 객체를 Map으로 변환
    final schedulesJson = _schedules.map((s) => s.toJson()).toList();
    await _notificationService.scheduleNotificationsFromSchedules(schedulesJson);
  }
  // 선택된 날짜의 스케줄만 필터링
  void _filterSchedulesForSelectedDate() {
    setState(() {
      _filteredSchedules = _schedules.where((schedule) {
        if (schedule.startTime == null) return false;

        final scheduleDate = schedule.startTime!.toDate();

        if (schedule.isRecurring) {
          // 매주 반복: 요일이 같고, 시작일이 선택한 날짜 이전이면 표시
          return scheduleDate.weekday == selectedDate.weekday &&
              scheduleDate.isBefore(selectedDate.add(Duration(days: 1)));
        } else {
          // 일회성: 정확히 같은 날짜
          return scheduleDate.year == selectedDate.year &&
              scheduleDate.month == selectedDate.month &&
              scheduleDate.day == selectedDate.day;
        }
      }).toList();

      // 시간순 정렬
      _filteredSchedules.sort((a, b) {
        if (a.startTime == null && b.startTime == null) return 0;
        if (a.startTime == null) return 1;
        if (b.startTime == null) return -1;
        return a.startTime!.compareTo(b.startTime!);
      });
    });
  }

  // 특정 날짜에 스케줄이 있는지 확인
  bool _hasScheduleOnDate(DateTime date) {
    return _schedules.any((schedule) {
      if (schedule.startTime == null) return false;

      final scheduleDate = schedule.startTime!.toDate();

      if (schedule.isRecurring) {
        // 매주 반복: 요일이 같고, 시작일이 해당 날짜 이전
        return scheduleDate.weekday == date.weekday &&
            scheduleDate.isBefore(date.add(Duration(days: 1)));
      } else {
        // 일회성: 정확히 같은 날짜
        return scheduleDate.year == date.year &&
            scheduleDate.month == date.month &&
            scheduleDate.day == date.day;
      }
    });
  }

  String getMonthName(int month) {
    const months = [
      '1월', '2월', '3월', '4월', '5월', '6월',
      '7월', '8월', '9월', '10월', '11월', '12월'
    ];
    return months[month - 1];
  }

  Future<DateTime> getSelectedDate() async {
    return selectedDate;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Column(
        children: [
          // Header
          Container(
            color: const Color(0xFFD4D4E8),
            padding: const EdgeInsets.all(16),
            child: const Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                '스케줄',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Calendar Section
                  Container(
                    color: const Color(0xFFFFFBF5),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
                    child: Column(
                      children: [
                        // Month Navigation
                        Row(
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
                                  onPressed: () {
                                    setState(() {
                                      displayMonth = DateTime(
                                        displayMonth.year,
                                        displayMonth.month - 1,
                                      );
                                      selectedDate = DateTime(displayMonth.year, displayMonth.month, 1);
                                      _filterSchedulesForSelectedDate();
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.chevron_right),
                                  onPressed: () {
                                    setState(() {
                                      displayMonth = DateTime(
                                        displayMonth.year,
                                        displayMonth.month + 1,
                                      );
                                      selectedDate = DateTime(displayMonth.year, displayMonth.month, 1);
                                      _filterSchedulesForSelectedDate();
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
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
                        _buildCalendarGrid(),
                      ],
                    ),
                  ),

                  // Time Selector
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '일정 추가하기',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.add_circle_outline,
                            size: 32,
                          ),
                          color: Colors.black,
                          onPressed: () {
                            _showScheduleSettings();
                          },
                        ),
                      ],
                    ),
                  ),

                  // Schedule List (필터링된 스케줄만 표시)
                  _filteredSchedules.isEmpty
                      ? Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '이 날짜에 일정이 없습니다',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                      : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: _filteredSchedules.asMap().entries.map((entry) {
                        final schedule = entry.value;
                        final originalIndex = _schedules.indexOf(schedule);

                        return GestureDetector(
                          onTap: () => _showScheduleSettings(
                              scheduleToEdit: schedule,
                              index: originalIndex
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(bottom: screenWidth * 0.04),
                            child: _buildScheduleItem(
                              title: schedule.title,
                              time: schedule.formattedTime(selectedDate),
                              screenWidth: screenWidth,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  // Bottom padding for last item
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleItem({
    required String title,
    required String time,
    required double screenWidth,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: screenWidth * 0.025,
      ),
      decoration: BoxDecoration(
        color: _cardColor,
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              textBaseline: TextBaseline.alphabetic,
              children: [
                // 스케줄 제목
                Text(
                  title,
                  style: TextStyle(
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: screenWidth * 0.01),
                // 시작 시간
                Text(
                  time,
                  style: TextStyle(
                    fontSize: screenWidth * 0.042,
                    fontWeight: FontWeight.w400,
                    color: Colors.black.withOpacity(0.6),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _showScheduleSettings({Schedule? scheduleToEdit, int? index}) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ScheduleSetter(
        initialSchedule: scheduleToEdit,
        isEditMode: scheduleToEdit != null,
        Date: selectedDate,
      ),
    );
    if (result != null) {
      setState(() {
        if (result is Schedule) {
          if (index != null) {
            _schedules[index] = result;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('스케줄이 수정되었습니다.')),
            );
          } else {
            _schedules.add(result);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('새 스케줄이 추가되었습니다.')),
            );
          }
        } else if (result == 'delete' && index != null) {
          final deletedTitle = _schedules[index].title;
          _schedules.removeAt(index);
          if (widget.onScheduleDeleted != null) {
            widget.onScheduleDeleted!(deletedTitle);
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('스케줄이 삭제되었습니다.')),
          );
        }
        _filterSchedulesForSelectedDate();
        _saveSchedulesToLocal();
        final User? user = FirebaseAuth.instance.currentUser;
        if(user != null)
          _saveSchedulesToFirestore(user);
      });
    }
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(displayMonth.year, displayMonth.month, 1);
    final lastDayOfMonth = DateTime(
        displayMonth.year, displayMonth.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday - 1;

    List<Widget> dayWidgets = [];

    // Empty cells before the first day
    for (int i = 0; i < firstWeekday; i++) {
      dayWidgets.add(const SizedBox(width: 45, height: 45));
    }

    // Days of the month
    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      final date = DateTime(displayMonth.year, displayMonth.month, day);
      final isSelected = selectedDate.year == date.year &&
          selectedDate.month == date.month &&
          selectedDate.day == date.day;
      final hasSchedule = _hasScheduleOnDate(date);

      dayWidgets.add(
        GestureDetector(
          onTap: () {
            setState(() {
              selectedDate = date;
              _filterSchedulesForSelectedDate();
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFD4D4E8) : Colors.transparent,
              shape: BoxShape.circle,
              border: hasSchedule && !isSelected
                  ? Border.all(
                color: const Color(0xFF7C6FDB),
                width: 2,
              )
                  : null,
            ),
            child: Center(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 150),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: Colors.black,
                ),
                child: Text('$day'),
              ),
            ),
          ),
        ),
      );
    }

    // Fill remaining cells to complete the last row
    while (dayWidgets.length % 7 != 0) {
      dayWidgets.add(const SizedBox(width: 45, height: 45));
    }

    return Column(
      children: List.generate(
        (dayWidgets.length / 7).ceil(),
            (weekIndex) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: dayWidgets
                  .skip(weekIndex * 7)
                  .take(7)
                  .toList(),
            ),
          );
        },
      ),
    );
  }
}