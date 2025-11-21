import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:all_in_one_scheduler/services/alarm/alarm.dart';
import 'package:all_in_one_scheduler/services/alarm/quiz_type.dart';
import 'alarm_sound_setting_page.dart';
import 'alarm_puzzle_setting_page.dart';
import 'package:intl/intl.dart';

class AlarmSettingPage extends StatefulWidget {
  final Alarm? initialAlarm;
  final bool isEditMode;

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
  late List<bool> selectedDays;
  late String _soundAsset;
  late QuizType? _quizSetting;

  @override
  void initState() {
    super.initState();

    if (widget.initialAlarm != null) {
      final alarm = widget.initialAlarm!;
      selectedHour = alarm.alarmTime.hour;
      selectedMinute = alarm.alarmTime.minute;
      selectedDays = List.generate(7, (index) => alarm.repeatDays.contains(index + 1));
      _soundAsset = alarm.soundAsset;
      _quizSetting = alarm.quizSetting;
    } else {
      selectedHour = 6;
      selectedMinute = 0;
      selectedDays = [false, false, false, false, false, false, false];
      _soundAsset = '공사소리';
      _quizSetting = null;
    }
  }

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

  void _navigateToPuzzleSetting() async {
    final initialQuiz = _quizSetting ?? QuizType(
      difficulty: QuizDifficulty.easy,
      requiredCount: 3,
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

  void _saveAlarm() {
    List<int> repeatDays = [];
    for (int i = 0; i < selectedDays.length; i++) {
      if (selectedDays[i]) {
        repeatDays.add(i + 1);
      }
    }

    final alarm = Alarm(
      alarmTime: TimeOfDay(hour: selectedHour, minute: selectedMinute),
      repeatDays: repeatDays,
      soundAsset: _soundAsset,
      quizSetting: _quizSetting,
      isEnabled: widget.initialAlarm?.isEnabled ?? true,
    );

    Navigator.pop(context, alarm);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF7B68A6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.isEditMode ? '알람 수정' : '알람 추가',
          style: TextStyle(
            color: Colors.white,
            fontSize: screenWidth * 0.045,
          ),
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
                  _buildTimeColumn(
                    value: selectedHour,
                    maxValue: 24,
                    onChanged: (newValue) {
                      setState(() {
                        selectedHour = newValue;
                      });
                    },
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  Text(
                    ':',
                    style: TextStyle(
                      fontSize: screenWidth * 0.16,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.03),
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
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                  ),
                ],
              ),
            ),
          ),
          // 설정 카드
          Container(
            margin: EdgeInsets.all(screenWidth * 0.05),
            padding: EdgeInsets.all(screenWidth * 0.045),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildRepeatText(screenWidth),
                SizedBox(height: screenWidth * 0.025),
                _buildDaySelector(screenWidth),
                SizedBox(height: screenWidth * 0.04),
                _buildSettingItem(
                  title: '알람음',
                  subtitle: _soundAsset,
                  onTap: _navigateToSoundSetting,
                  screenWidth: screenWidth,
                ),
                SizedBox(height: screenWidth * 0.02),
                _buildSettingItem(
                  title: '퍼즐 종류',
                  subtitle: _quizSetting != null
                      ? '${_quizSetting!.typeName} (${_getDifficultyText(_quizSetting!.difficulty)})'
                      : '설정 안 함',
                  onTap: _navigateToPuzzleSetting,
                  screenWidth: screenWidth,
                ),
                SizedBox(height: screenWidth * 0.04),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: const Color(0xFF7B68A6),
                          fontSize: screenWidth * 0.04,
                        ),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    TextButton(
                      onPressed: _saveAlarm,
                      child: Text(
                        'OK',
                        style: TextStyle(
                          color: const Color(0xFF7B68A6),
                          fontSize: screenWidth * 0.04,
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
    required double screenWidth,
    required double screenHeight,
  }) {
    final int itemCount = 10000;
    final int initialIndex = itemCount ~/ 2 + value;

    final FixedExtentScrollController scrollController =
    FixedExtentScrollController(initialItem: initialIndex);

    final double itemHeight = screenHeight * 0.11;
    final double mainFontSize = screenWidth * 0.16;
    final double sideFontSize = screenWidth * 0.115;
    final double spacing = screenHeight * 0.025;

    return SizedBox(
      width: screenWidth * 0.25,
      height: itemHeight * 3 + spacing * 2,
      child: Stack(
        children: [
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
              itemExtent: itemHeight + spacing,
              diameterRatio: 2.0,
              perspective: 0.003,
              physics: const FixedExtentScrollPhysics(),
              squeeze: 1.0,
              useMagnifier: false,
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
                      style: TextStyle(
                        fontSize: mainFontSize,
                        fontWeight: FontWeight.w300,
                        color: Colors.transparent,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          IgnorePointer(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  ((value - 1 + maxValue) % maxValue).toString().padLeft(2, '0'),
                  style: TextStyle(
                    fontSize: sideFontSize,
                    fontWeight: FontWeight.w300,
                    color: const Color(0xFF9B8BB8),
                  ),
                ),
                SizedBox(height: spacing),
                GestureDetector(
                  onTap: () {
                    _showKeyboard(context, value, maxValue, onChanged);
                  },
                  child: Text(
                    value.toString().padLeft(2, '0'),
                    style: TextStyle(
                      fontSize: mainFontSize,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: spacing),
                Text(
                  ((value + 1) % maxValue).toString().padLeft(2, '0'),
                  style: TextStyle(
                    fontSize: sideFontSize,
                    fontWeight: FontWeight.w300,
                    color: const Color(0xFF9B8BB8),
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

  Widget _buildRepeatText(double screenWidth) {
    final days = ['월', '화', '수', '목', '금', '토', '일'];
    final selectedCount = selectedDays.where((d) => d).length;

    String repeatText;

    if (selectedCount == 0) {
      final now = DateTime.now();
      final tomorrow = DateTime.now().add(Duration(days: 1));
      if (DateTime.now().hour < selectedHour || DateTime.now().hour == selectedHour && DateTime.now().minute < selectedMinute) {
        final formatter = DateFormat('M월 d일');
        final weekday = days[now.weekday - 1];
        repeatText = '오늘 - ${formatter.format(now)} ($weekday)';
      }
      else
      {
        final formatter = DateFormat('M월 d일');
        final weekday = days[tomorrow.weekday - 1];
        repeatText = '내일 - ${formatter.format(tomorrow)} ($weekday)';
      }
    } else if (selectedCount == 7) {
      repeatText = '매일';
    } else {
      List<String> selectedDayNames = [];
      for (int i = 0; i < selectedDays.length; i++) {
        if (selectedDays[i]) {
          selectedDayNames.add(days[i]);
        }
      }
      repeatText = '${selectedDayNames.join(', ')}';
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenWidth * 0.01),
      child: Text(
        repeatText,
        style: TextStyle(
          fontSize: screenWidth * 0.038,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildDaySelector(double screenWidth) {
    final days = ['월', '화', '수', '목', '금', '토', '일'];
    final buttonSize = (screenWidth - screenWidth * 0.09 - screenWidth * 0.09) / 7 - 4;

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
            width: buttonSize,
            height: buttonSize,
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
                  fontSize: screenWidth * 0.035,
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
    required double screenWidth,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.01),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.settings,
              color: Colors.grey[600],
              size: screenWidth * 0.06,
            ),
          ],
        ),
      ),
    );
  }
}