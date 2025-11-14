import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AlarmSettingPage extends StatefulWidget {
  const AlarmSettingPage({Key? key}) : super(key: key);

  @override
  State<AlarmSettingPage> createState() => _AlarmSettingPageState();
}

class _AlarmSettingPageState extends State<AlarmSettingPage> {
  int selectedHour = 3;
  int selectedMinute = 50;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF7B68A6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          '알람 세부설정 화면',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
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
                  const SizedBox(width: 10),
                  const Text(
                    ':',
                    style: TextStyle(
                      fontSize: 80,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // 분 선택
                  _buildTimeColumn(
                    value: selectedMinute,
                    maxValue: 60,
                    onChanged: (newValue) {
                      setState(() {
                        if (selectedMinute == 59 && newValue == 0) {
                          // 59에서 0으로 넘어갈 때 시간 증가
                          selectedHour = (selectedHour + 1) % 24;
                        } else if (selectedMinute == 0 && newValue == 59) {
                          // 0에서 59로 넘어갈 때 시간 감소
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
                _buildSettingItem(
                  title: '알람음',
                  subtitle: '소리1',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TempSettingPage(title: '알람음 선택'),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                _buildSettingItem(
                  title: '퍼즐 종류',
                  subtitle: '퍼즐1',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TempSettingPage(title: '퍼즐 종류 선택'),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
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
                      onPressed: () {
                        Navigator.pop(context);
                      },
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

  Widget _buildTimeColumn({
    required int value,
    required int maxValue,
    required Function(int) onChanged,
  }) {
    int prevValue = (value - 1 + maxValue) % maxValue;
    int nextValue = (value + 1) % maxValue;

    return SizedBox(
      width: 120,
      height: 350,
      child: GestureDetector(
        onVerticalDragUpdate: (details) {
          if (details.delta.dy < -10) {
            // 위로 스와이프 (증가)
            onChanged((value + 1) % maxValue);
          } else if (details.delta.dy > 10) {
            // 아래로 스와이프 (감소)
            onChanged((value - 1 + maxValue) % maxValue);
          }
        },
        child: Container(
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 위쪽 숫자 (어둡게)
              Text(
                prevValue.toString().padLeft(2, '0'),
                style: const TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.w300,
                  color: Color(0xFF9B8BB8),
                ),
              ),
              const SizedBox(height: 20),
              // 선택된 숫자 (밝게) - 클릭 가능
              GestureDetector(
                onTap: () {
                  _showInputDialog(context, value, maxValue, onChanged);
                },
                child: Text(
                  value.toString().padLeft(2, '0'),
                  style: const TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // 아래쪽 숫자 (어둡게)
              Text(
                nextValue.toString().padLeft(2, '0'),
                style: const TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.w300,
                  color: Color(0xFF9B8BB8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInputDialog(BuildContext context, int currentValue, int maxValue, Function(int) onChanged) {
    final TextEditingController controller = TextEditingController();

    controller.addListener(() {
      String text = controller.text;
      if (text.isEmpty) return;

      int? inputValue = int.tryParse(text);
      if (inputValue == null) return;

      bool isHour = maxValue == 24;

      if (isHour) {
        // 시간 입력 로직
        if (text.length == 1) {
          if (inputValue >= 3) {
            // 3~9 입력 시 바로 적용
            if (inputValue <= 23) {
              onChanged(inputValue);
              Navigator.pop(context);
            }
          }
        } else if (text.length == 2) {
          if (inputValue >= 0 && inputValue <= 23) {
            onChanged(inputValue);
            Navigator.pop(context);
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
        // 분 입력 로직
        if (text.length == 1) {
          if (inputValue >= 6) {
            // 6~9 입력 시 바로 적용
            onChanged(inputValue);
            Navigator.pop(context);
          }
        } else if (text.length == 2) {
          if (inputValue >= 0 && inputValue <= 59) {
            onChanged(inputValue);
            Navigator.pop(context);
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

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF7B68A6),
          title: Text(
            maxValue == 24 ? '시간 입력' : '분 입력',
            style: const TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(2),
            ],
            style: const TextStyle(
              fontSize: 40,
              color: Colors.white,
            ),
            decoration: InputDecoration(
              hintText: currentValue.toString().padLeft(2, '0'),
              hintStyle: const TextStyle(color: Colors.white54),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white, width: 2),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                '취소',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
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

// 임시 설정 페이지
class TempSettingPage extends StatelessWidget {
  final String title;

  const TempSettingPage({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF7B68A6),
      ),
      body: Center(
        child: Text(
          '$title 페이지',
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}