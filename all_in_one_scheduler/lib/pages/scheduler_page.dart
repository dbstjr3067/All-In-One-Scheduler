import 'package:flutter/material.dart';

class SchedulerPage extends StatefulWidget {
  const SchedulerPage({Key? key}) : super(key: key);

  @override
  State<SchedulerPage> createState() => _SchedulerPageState();
}

class _SchedulerPageState extends State<SchedulerPage> {
  late DateTime selectedDate;
  late DateTime displayMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedDate = now;
    displayMonth = DateTime(now.year, now.month);
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
                  '캘린더',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

            // Calendar Section
            Container( //20xx년 xx월 < > 화면
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
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Weekday Headers
                  Row( //월 화 수 ... 일 화면
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
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
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
                  const Text(
                    'Ends',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '8:00 AM',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(displayMonth.year, displayMonth.month, 1);
    final lastDayOfMonth = DateTime(displayMonth.year, displayMonth.month + 1, 0);
    // weekday: 1=월, 7=일. For MON-SUN layout, use (weekday - 1)
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

      dayWidgets.add(
        GestureDetector(
          onTap: () {
            setState(() {
              selectedDate = date;
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