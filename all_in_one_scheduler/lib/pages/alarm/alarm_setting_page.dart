import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:all_in_one_scheduler/services/alarm/alarm.dart';
import 'package:all_in_one_scheduler/services/alarm/quiz_type.dart';
import 'alarm_sound_setting_page.dart';
import 'alarm_puzzle_setting_page.dart';
import 'package:intl/intl.dart';

class AlarmSettingPage extends StatefulWidget {
  final Alarm? initialAlarm; // 수정할 알람 (null이면 새 알람 생성)
  final bool isEditMode; // 수정 모드 여부

  const AlarmSettingPage({
    Key? key,
    this.initialAlarm,
    this.isEditMode = false,
  }) : super(key: key);

  @override
  State<AlarmSettingPage> createState() => _AlarmSettingPageState();
}

class _AlarmSettingPageState extends State<AlarmSettingPage> {
  late int selectedHour;
  late int selectedMinute;

  // 요일 선택 상태 (월화수목금토일) - 1~7로 매핑
  late List<bool> selectedDays;

  // 알람음 설정
  late String _soundAsset;

  // 퀴즈 설정
  late QuizType? _quizSetting;

  @override
  void initState() {
    super.initState();

    if (widget.initialAlarm != null) {
      // 기존 알람 수정
      final alarm = widget.initialAlarm!;
      selectedHour = alarm.alarmTime.hour;
      selectedMinute = alarm.alarmTime.minute;

      // repeatDays를 selectedDays로 변환 (1=월, 7=일)
      selectedDays = List.generate(7, (index) => alarm.repeatDays.contains(index + 1));

      _soundAsset = alarm.soundAsset;
      _quizSetting = alarm.quizSetting;
    } else {
      // 새 알람 생성
      selectedHour = 6;
      selectedMinute = 0;
      selectedDays = [false, false, false, false, false, false, false];
      _soundAsset = '공사소리'; // 기본값
      _quizSetting = null; // 기본값은 알람음 모드
    }
  }

  // 알람음 설정 페이지로 이동
  void _navigateToSoundSetting() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AlarmSoundSettingPage(
          initialSoundAsset: _soundAsset,
        ),
      ),
    );

    if (result != null && result is String) {
      setState(() {
        _soundAsset = result;
      });
    }
  }

  // 퍼즐 설정 페이지로 이동
  void _navigateToPuzzleSetting() async {
    final initialQuiz = _quizSetting ?? QuizType(
      difficulty: QuizDifficulty.easy,
      requiredCount: 1,
    );

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AlarmPuzzleSettingPage(
          initialQuizSetting: initialQuiz,
        ),
      ),
    );

    if (result != null && result is QuizType) {
      setState(() {
        _quizSetting = result;
      });
    }
  }

  // 알람 저장 (OK 버튼)
  void _saveAlarm() {
    // selectedDays를 repeatDays로 변환
    List<int> repeatDays = [];
    for (int i = 0; i < selectedDays.length; i++) {
      if (selectedDays[i]) {
        repeatDays.add(i + 1); // 1=월, 7=일
      }
    }

    final alarm = Alarm(
      alarmTime: TimeOfDay(hour: selectedHour, minute: selectedMinute),
      repeatDays: repeatDays,
      soundAsset: _soundAsset,
      quizSetting: _quizSetting,
      isEnabled: widget.initialAlarm?.isEnabled ?? true,
    );

    Navigator.pop(context, alarm); // Alarm 객체 반환
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF7B68A6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.isEditMode ? '알람 수정' : '알람 추가',
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: widget.isEditMode
            ? [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            onPressed: () {
              Navigator.pop(context, 'delete');
            },
          ),
        ]
            : null,
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 시간 선택
                  _buildTimeColumn(
                    value: selectedHour,
                    maxValue: 24,
                    onChanged: (newValue) {
                      setState(() {
                        selectedHour = newValue;
                      });
                    },
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    ':',
                    style: TextStyle(
                      fontSize: 70,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 14),
                  // 분 선택
                  _buildTimeColumn(
                    value: selectedMinute,
                    maxValue: 60,
                    onChanged: (newValue) {
                      setState(() {
                        if (selectedMinute == 59 && newValue == 0) {
                          selectedHour = (selectedHour + 1) % 24;
                        } else if (selectedMinute == 0 && newValue == 59) {
                          selectedHour = (selectedHour - 1 + 24) % 24;
                        }
                        selectedMinute = newValue;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          // 설정 카드
          Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 알람 반복 텍스트
                _buildRepeatText(),
                const SizedBox(height: 12),
                // 요일 선택
                _buildDaySelector(),
                const SizedBox(height: 20),
                _buildSettingItem(
                  title: '알람음',
                  subtitle: _soundAsset,
                  onTap: _navigateToSoundSetting,
                ),
                const SizedBox(height: 10),
                _buildSettingItem(
                  title: '퍼즐 종류',
                  subtitle: _quizSetting != null
                      ? '${_quizSetting!.typeName} (${_getDifficultyText(_quizSetting!.difficulty)})'
                      : '설정 안 함',
                  onTap: _navigateToPuzzleSetting,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // 취소
                      },
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFF7B68A6),
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    TextButton(
                      onPressed: _saveAlarm,
                      child: const Text(
                        'OK',
                        style: TextStyle(
                          color: Color(0xFF7B68A6),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getDifficultyText(QuizDifficulty difficulty) {
    switch (difficulty) {
      case QuizDifficulty.easy:
        return '쉬움';
      case QuizDifficulty.medium:
        return '보통';
      case QuizDifficulty.hard:
        return '어려움';
    }
  }

  Widget _buildTimeColumn({
    required int value,
    required int maxValue,
    required Function(int) onChanged,
  }) {
    // 무한 스크롤을 위한 큰 초기 인덱스
    final int itemCount = 10000;
    final int initialIndex = itemCount ~/ 2 + value;

    final FixedExtentScrollController scrollController =
    FixedExtentScrollController(initialItem: initialIndex);

    return SizedBox(
      width: 105,
      height: 315,
      child: Stack(
        children: [
          // ListWheelScrollView로 부드러운 스크롤
          NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollEndNotification) {
                final int centerIndex = scrollController.selectedItem;
                final int newValue = centerIndex % maxValue;
                if (newValue != value) {
                  onChanged(newValue);
                }
              }
              return true;
            },
            child: ListWheelScrollView.useDelegate(
              controller: scrollController,
              itemExtent: 91, // 각 아이템 높이 (49 + 21 + 21)
              diameterRatio: 2.0,
              perspective: 0.003,
              physics: const FixedExtentScrollPhysics(),
              squeeze: 1.0, // 아이템 간격 조절
              useMagnifier: false, // 확대 효과 끄기
              magnification: 1.0,
              onSelectedItemChanged: (index) {
                final int newValue = index % maxValue;
                if (newValue != value) {
                  onChanged(newValue);
                }
              },
              childDelegate: ListWheelChildLoopingListDelegate(
                children: List.generate(maxValue, (index) {
                  return Center(
                    child: Text(
                      index.toString().padLeft(2, '0'),
                      style: const TextStyle(
                        fontSize: 70,
                        fontWeight: FontWeight.w300,
                        color: Colors.transparent, // 투명하게 (오버레이로 표시)
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          // 고정된 숫자 표시 오버레이
          IgnorePointer(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 위쪽 숫자
                Text(
                  ((value - 1 + maxValue) % maxValue).toString().padLeft(2, '0'),
                  style: const TextStyle(
                    fontSize: 49,
                    fontWeight: FontWeight.w300,
                    color: Color(0xFF9B8BB8),
                  ),
                ),
                const SizedBox(height: 21),
                // 가운데 숫자 (클릭 가능)
                GestureDetector(
                  onTap: () {
                    _showKeyboard(context, value, maxValue, onChanged);
                  },
                  child: Text(
                    value.toString().padLeft(2, '0'),
                    style: const TextStyle(
                      fontSize: 70,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 21),
                // 아래쪽 숫자
                Text(
                  ((value + 1) % maxValue).toString().padLeft(2, '0'),
                  style: const TextStyle(
                    fontSize: 49,
                    fontWeight: FontWeight.w300,
                    color: Color(0xFF9B8BB8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showKeyboard(BuildContext context, int currentValue, int maxValue, Function(int) onChanged) {
    final TextEditingController controller = TextEditingController();
    final OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: 0,
        right: 0,
        bottom: MediaQuery.of(context).viewInsets.bottom,
        child: Material(
          color: Colors.transparent,
          child: Container(
            height: 0,
            child: TextField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(2),
              ],
              style: const TextStyle(fontSize: 0, color: Colors.transparent),
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ),
    );

    controller.addListener(() {
      String text = controller.text;
      if (text.isEmpty) return;

      int? inputValue = int.tryParse(text);
      if (inputValue == null) return;

      bool isHour = maxValue == 24;

      if (isHour) {
        if (text.length == 1) {
          if (inputValue >= 3) {
            if (inputValue <= 23) {
              onChanged(inputValue);
              overlayEntry.remove();
              controller.dispose();
            }
          }
        } else if (text.length == 2) {
          if (inputValue >= 0 && inputValue <= 23) {
            onChanged(inputValue);
            overlayEntry.remove();
            controller.dispose();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('0부터 23 사이의 값을 입력해주세요.'),
                duration: Duration(seconds: 1),
              ),
            );
            controller.clear();
          }
        }
      } else {
        if (text.length == 1) {
          if (inputValue >= 6) {
            onChanged(inputValue);
            overlayEntry.remove();
            controller.dispose();
          }
        } else if (text.length == 2) {
          if (inputValue >= 0 && inputValue <= 59) {
            onChanged(inputValue);
            overlayEntry.remove();
            controller.dispose();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('0부터 59 사이의 값을 입력해주세요.'),
                duration: Duration(seconds: 1),
              ),
            );
            controller.clear();
          }
        }
      }
    });

    Overlay.of(context).insert(overlayEntry);
  }

  // 선택한 요일에 따른 반복 텍스트 생성
  Widget _buildRepeatText() {
    final days = ['월', '화', '수', '목', '금', '토', '일'];
    final selectedCount = selectedDays.where((d) => d).length;

    String repeatText;

    if (selectedCount == 0) {
      // 모두 체크 해제: 오늘 날짜 표시
      final now = DateTime.now();
      final tomorrow = DateTime.now().add(Duration(days: 1));
      if (DateTime.now().hour < selectedHour || DateTime.now().hour == selectedHour && DateTime.now().minute > selectedMinute) {
        final formatter = DateFormat('M월 d일');
        final weekday = days[now.weekday - 1]; // DateTime.weekday는 1(월)~7(일)
        repeatText = '오늘 - ${formatter.format(now)} ($weekday)';
      }
      else
      {
        final formatter = DateFormat('M월 d일');
        final weekday = days[tomorrow.weekday - 1]; // DateTime.weekday는 1(월)~7(일)
        repeatText = '내일 - ${formatter.format(tomorrow)} ($weekday)';
      }
    } else if (selectedCount == 7) {
      // 모두 체크: 매일
      repeatText = '매일';
    } else {
      // 일부 체크: 매주 x, x, x
      List<String> selectedDayNames = [];
      for (int i = 0; i < selectedDays.length; i++) {
        if (selectedDays[i]) {
          selectedDayNames.add(days[i]);
        }
      }
      repeatText = '${selectedDayNames.join(', ')}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        repeatText,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildDaySelector() {
    final days = ['월', '화', '수', '목', '금', '토', '일'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedDays[index] = !selectedDays[index];
            });
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: selectedDays[index]
                  ? const Color(0xFF7B68A6)
                  : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                days[index],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: selectedDays[index]
                      ? Colors.white
                      : Colors.grey[600],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSettingItem({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.settings,
              color: Colors.grey[600],
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}