import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:all_in_one_scheduler/services/schedule/schedule.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduleSetter extends StatefulWidget {
  final Schedule? initialSchedule;
  final bool isEditMode;
  final DateTime? Date;

  const ScheduleSetter({
    Key? key,
    this.initialSchedule,
    this.isEditMode = false,
    this.Date,
  }) : super(key: key);

  @override
  State<ScheduleSetter> createState() => _ScheduleSetterState();
}

class _ScheduleSetterState extends State<ScheduleSetter> {
  final TextEditingController _hourController = TextEditingController();
  final TextEditingController _minuteController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  late bool _isTodaySelected;
  late bool _isRecurring;
  late bool _isAllDay;

  @override
  void initState() {
    super.initState();

    if (widget.initialSchedule != null) {
      final schedule = widget.initialSchedule!;
      _hourController.text = schedule.startTime!.toDate().hour.toString();
      _minuteController.text = schedule.startTime!.toDate().minute.toString();
      _valueController.text = schedule.title;
      _isTodaySelected = !schedule.isRecurring;
      _isRecurring = schedule.isRecurring;
      _isAllDay = schedule.isAllDay;
    } else {
      _hourController.text = '8';
      _minuteController.text = '00';
      _isTodaySelected = true;
      _isRecurring = false;
      _isAllDay = true;
    }
  }


  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 하루 종일 스위치
              Container(
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7C6FDB).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.access_time,
                            color: Color(0xFF7C6FDB),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          '하루 종일',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value: _isAllDay,
                      onChanged: (value) {
                        setState(() {
                          _isAllDay = value;
                        });
                      },
                      activeColor: const Color(0xFF7C6FDB),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 시간 입력 영역 (하루 종일이 OFF일 때만 표시)
              if (!_isAllDay) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Hour 입력
                    Column(
                      children: [
                        Container(
                          width: 100,
                          height: 80,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFF7C6FDB),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: const Color(0xFFE8DEFF),
                          ),
                          child: Center(
                            child: TextField(
                              controller: _hourController,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(2),
                              ],
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF7C6FDB),
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: '00',
                                hintStyle: TextStyle(
                                  color: Color(0xFF7C6FDB),
                                ),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '시간',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        ':',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    // Minute 입력
                    Column(
                      children: [
                        Container(
                          width: 100,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8E8E8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: TextField(
                              controller: _minuteController,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(2),
                              ],
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: '00',
                                hintStyle: TextStyle(
                                  color: Colors.black38,
                                ),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '분',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],

              // Value 입력 영역
              Container(
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _valueController,
                  decoration: const InputDecoration(
                    hintText: '스케줄 제목',
                    hintStyle: TextStyle(
                      color: Colors.black38,
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 체크박스 및 버튼 영역
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8DEFF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    // 체크박스들
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: _isTodaySelected,
                                  onChanged: (value) {
                                    setState(() {
                                      _isTodaySelected = value ?? false;
                                      if (_isTodaySelected) {
                                        _isRecurring = false;
                                      }
                                      else{
                                        _isRecurring = true;
                                      }
                                    });
                                  },
                                  activeColor: const Color(0xFF7C6FDB),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                '오늘만',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: _isRecurring,
                                  onChanged: (value) {
                                    setState(() {
                                      _isRecurring = value ?? false;
                                      if (_isRecurring) {
                                        _isTodaySelected = false;
                                      }
                                      else{
                                        _isTodaySelected = true;
                                      }
                                    });
                                  },
                                  activeColor: const Color(0xFF7C6FDB),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                '매주',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // 버튼들
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // 확인 버튼
                        InkWell(
                          onTap: () {
                            final selectedDateTime = widget.Date ?? DateTime.now();

                            Timestamp startTime;
                            if (_isAllDay) {
                              // 하루 종일: 00:00으로 설정
                              startTime = getStartTime(
                                originalDateTime: selectedDateTime,
                                newHour: 0,
                                newMinute: 0,
                              );
                            } else {
                              // 시간 지정
                              final int hour = int.tryParse(_hourController.text) ?? 0;
                              final int minute = int.tryParse(_minuteController.text) ?? 0;
                              startTime = getStartTime(
                                originalDateTime: selectedDateTime,
                                newHour: hour,
                                newMinute: minute,
                              );
                            }

                            final schedule = Schedule(
                              title: _valueController.text.isEmpty
                                  ? '제목 없음'
                                  : _valueController.text,
                              startTime: startTime,
                              isRecurring: _isRecurring,
                              isAllDay: _isAllDay,
                            );

                            Navigator.pop(context, schedule);
                          },
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Color(0xFF7C6FDB),
                              size: 24,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // 뒤로가기 버튼
                        InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Color(0xFF7C6FDB),
                              size: 24,
                            ),
                          ),
                        ),
                        if(widget.isEditMode) ...[
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () {
                              Navigator.pop(context, 'delete');
                            },
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.delete_outline,
                                color: Color(0xFF7C6FDB),
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Timestamp getStartTime({
    required DateTime originalDateTime,
    required int newHour,
    required int newMinute,
    bool? isUtc,
  }) {
    final year = originalDateTime.year;
    final month = originalDateTime.month;
    final day = originalDateTime.day;

    final bool utcMode = isUtc ?? originalDateTime.isUtc;

    final newDateTime = utcMode
        ? DateTime.utc(year, month, day, newHour, newMinute)
        : DateTime(year, month, day, newHour, newMinute);

    return Timestamp.fromDate(newDateTime);
  }
}