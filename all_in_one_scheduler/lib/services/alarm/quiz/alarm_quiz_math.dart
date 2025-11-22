import 'package:flutter/material.dart';
import 'dart:math';
import 'package:all_in_one_scheduler/services/alarm/alarm_sound_service.dart';

class AlarmQuizMathScreen extends StatefulWidget {
  final dynamic alarm;

  const AlarmQuizMathScreen({
    Key? key,
    required this.alarm,
  }) : super(key: key);

  @override
  State<AlarmQuizMathScreen> createState() => _AlarmQuizMathScreenState();
}

class _AlarmQuizMathScreenState extends State<AlarmQuizMathScreen> {
  final AlarmSoundService _alarmService = AlarmSoundService();
  final TextEditingController _answerController = TextEditingController();

  int _currentQuestionIndex = 1;
  late int _totalQuestions;
  late int _num1;
  late int _num2;
  late String _operator;
  late int _correctAnswer;
  String _userAnswer = '';

  @override
  void initState() {
    super.initState();
    _totalQuestions = widget.alarm.quizSetting.requiredCount;
    _generateQuestion();
    _startAlarm();
  }

  Future<void> _startAlarm() async {
    await _alarmService.startAlarm();
  }

  void _generateQuestion() {
    final random = Random();
    final difficulty = widget.alarm.quizSetting.difficulty.index;

    // 난이도에 따라 숫자 범위 결정
    int maxNumber;
    switch (difficulty) {
      case 0: // 쉬움
        maxNumber = 20;
        break;
      case 1: // 보통
        maxNumber = 50;
        break;
      case 2: // 어려움
        maxNumber = 100;
        break;
      default:
        maxNumber = 50;
    }

    _num1 = random.nextInt(maxNumber) + 1;
    _num2 = random.nextInt(maxNumber) + 1;

    // 연산자 결정 (난이도에 따라)
    final operators = difficulty == 0 ? ['+', '-'] : ['+', '-', '×', '÷'];
    _operator = operators[random.nextInt(operators.length)];

    // 정답 계산
    switch (_operator) {
      case '+':
        _correctAnswer = _num1 + _num2;
        break;
      case '-':
      // 음수 방지
        if (_num1 < _num2) {
          final temp = _num1;
          _num1 = _num2;
          _num2 = temp;
        }
        _correctAnswer = _num1 - _num2;
        break;
      case '×':
        _correctAnswer = _num1 * _num2;
        break;
      case '÷':
      // 나누어 떨어지도록 조정
        _num1 = _num2 * (random.nextInt(10) + 1);
        _correctAnswer = _num1 ~/ _num2;
        break;
      default:
        _correctAnswer = 0;
    }

    _userAnswer = '';
    _answerController.clear();
  }

  void _onNumberPressed(String number) {
    setState(() {
      _userAnswer += number;
      _answerController.text = _userAnswer;
    });
  }

  void _onBackspace() {
    if (_userAnswer.isNotEmpty) {
      setState(() {
        _userAnswer = _userAnswer.substring(0, _userAnswer.length - 1);
        _answerController.text = _userAnswer;
      });
    }
  }

  void _checkAnswer() {
    if (_userAnswer.isEmpty) return;

    final userAnswerInt = int.tryParse(_userAnswer);
    if (userAnswerInt == null) return;

    if (userAnswerInt == _correctAnswer) {
      if (_currentQuestionIndex >= _totalQuestions) {
        // 모든 문제 완료
        _alarmService.stopAlarm();
        Navigator.of(context).pop(true); // 퀴즈 통과
      } else {
        // 다음 문제
        setState(() {
          _currentQuestionIndex++;
          _generateQuestion();
        });
      }
    } else {
      // 오답
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('틀렸습니다! 다시 시도하세요.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 1),
        ),
      );
      setState(() {
        _userAnswer = '';
        _answerController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            children: [
              // 상단 진행 표시
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        // 뒤로가기 (알람 화면으로)
                        Navigator.of(context).pop(false);
                      },
                    ),
                    const Spacer(),
                    Text(
                      '$_currentQuestionIndex / $_totalQuestions',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.volume_off, color: Colors.white),
                      onPressed: () {
                        // 음소거 토글
                      },
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // 문제 표시
              Text(
                '$_num1$_operator$_num2=',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 40),

              // 답 입력 필드
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    _userAnswer.isEmpty ? '' : _userAnswer,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // 숫자 키패드
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // 7 8 9
                    Row(
                      children: [
                        _buildNumberButton('7'),
                        const SizedBox(width: 8),
                        _buildNumberButton('8'),
                        const SizedBox(width: 8),
                        _buildNumberButton('9'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // 4 5 6
                    Row(
                      children: [
                        _buildNumberButton('4'),
                        const SizedBox(width: 8),
                        _buildNumberButton('5'),
                        const SizedBox(width: 8),
                        _buildNumberButton('6'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // 1 2 3
                    Row(
                      children: [
                        _buildNumberButton('1'),
                        const SizedBox(width: 8),
                        _buildNumberButton('2'),
                        const SizedBox(width: 8),
                        _buildNumberButton('3'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // 백스페이스 0 확인
                    Row(
                      children: [
                        _buildSpecialButton(
                          icon: Icons.backspace_outlined,
                          onPressed: _onBackspace,
                        ),
                        const SizedBox(width: 8),
                        _buildNumberButton('0'),
                        const SizedBox(width: 8),
                        _buildSpecialButton(
                          icon: Icons.check,
                          color: const Color(0xFFFF4757),
                          onPressed: _checkAnswer,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberButton(String number) {
    return Expanded(
      child: SizedBox(
        height: 70,
        child: ElevatedButton(
          onPressed: () => _onNumberPressed(number),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2C2C2E),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return Expanded(
      child: SizedBox(
        height: 70,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? const Color(0xFF2C2C2E),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: Icon(icon, size: 28),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }
}