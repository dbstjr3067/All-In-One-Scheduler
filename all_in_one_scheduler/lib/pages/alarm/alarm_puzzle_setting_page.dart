import 'package:flutter/material.dart';
import 'package:all_in_one_scheduler/services/alarm/alarm.dart';
import 'package:all_in_one_scheduler/services/alarm/quiz_type.dart';

// 사용자가 선택할 수 있는 퍼즐 목록
class PuzzleOption {
  final String typeName;
  final String description;
  final String imageUrl; // 이미지 URL 대체

  PuzzleOption({
    required this.typeName,
    required this.description,
    required this.imageUrl,
  });
}

final List<PuzzleOption> _puzzleOptions = [
  PuzzleOption(
    typeName: '없음',
    description: '알람에 퍼즐을 설정하지 않습니다.',
    imageUrl: 'https://placehold.co/100x100/D9E2F3/000?text=없음',
  ),
  PuzzleOption(
    typeName: '덧셈 퍼즐',
    description: '간단한 덧셈을 활용하여 뇌를 깨워보세요.',
    imageUrl: 'https://placehold.co/100x100/FAD7A0/000?text=덧셈퍼즐',
  ),
  PuzzleOption(
    typeName: '곱셈 퍼즐',
    description: '간단한 곱셈을 활용하여 뇌를 깨워보세요.',
    imageUrl: 'https://placehold.co/100x100/FAD7A0/000?text=곱셈퍼즐',
  ),
];

// 퍼즐 설정 페이지 (AlarmSettingPage에서 호출)
class AlarmPuzzleSettingPage extends StatefulWidget {
  final QuizType initialQuizSetting;

  const AlarmPuzzleSettingPage({
    Key? key,
    required this.initialQuizSetting,
  }) : super(key: key);

  @override
  State<AlarmPuzzleSettingPage> createState() => _AlarmPuzzleSettingPageState();
}

class _AlarmPuzzleSettingPageState extends State<AlarmPuzzleSettingPage> {
  late QuizType _currentQuizSetting;

  // 스타일 색상
  static const Color _cardColor = Color(0xFFEBEBFF);

  @override
  void initState() {
    super.initState();
    _currentQuizSetting = widget.initialQuizSetting;
  }

  void _selectQuiz(String name) {
    setState(() {
      _currentQuizSetting = QuizType(
        typeName: name,
        difficulty: _currentQuizSetting.difficulty,
        requiredCount: _currentQuizSetting.requiredCount,
      );
    });
  }

  void _changeDifficulty(QuizDifficulty difficulty) {
    setState(() {
      _currentQuizSetting = QuizType(
        typeName: _currentQuizSetting.typeName,
        difficulty: difficulty,
        requiredCount: _currentQuizSetting.requiredCount,
      );
    });
  }

  void _savePuzzleSetting() {
    Navigator.pop(context, _currentQuizSetting);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('퍼즐 설정', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: _cardColor,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '퍼즐 유형 선택',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ..._puzzleOptions.map((option) {
                    final isSelected = _currentQuizSetting.typeName == option.typeName;
                    return _buildPuzzleOption(option, isSelected);
                  }).toList(),

                  const Divider(height: 30, thickness: 1, color: Colors.black12),

                  const Text(
                    '난이도 설정',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _buildDifficultySelector(),
                ],
              ),
            ),
          ),
          _buildConfirmButton(context),
        ],
      ),
    );
  }

  Widget _buildPuzzleOption(PuzzleOption option, bool isSelected) {
    return GestureDetector(
      onTap: () => _selectQuiz(option.typeName),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Color(0xFF7C6FDB) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지 영역
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                option.imageUrl,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 70,
                  height: 70,
                  color: Colors.grey[300],
                  child: const Icon(Icons.extension, color: Colors.black54),
                ),
              ),
            ),
            const SizedBox(width: 15),
            // 텍스트 영역
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.typeName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    option.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            // 체크박스/라디오 버튼
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Icon(
                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isSelected ? Color(0xFF7C6FDB) : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultySelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: QuizDifficulty.values.map((diff) {
        final isSelected = _currentQuizSetting.difficulty == diff;
        String text;
        switch (diff) {
          case QuizDifficulty.easy: text = '쉬움'; break;
          case QuizDifficulty.medium: text = '보통'; break;
          case QuizDifficulty.hard: text = '어려움'; break;
        }

        return ActionChip(
          label: Text(text),
          backgroundColor: isSelected ? Color(0xFF7C6FDB) : Colors.grey[200],
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          onPressed: () => _changeDifficulty(diff),
        );
      }).toList(),
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소', style: TextStyle(color: Colors.black54, fontSize: 14)),
          ),
          const SizedBox(width: 10),
          TextButton(
            onPressed: _savePuzzleSetting,
            child: const Text('저장', style: TextStyle(color: Color(0xFF7C6FDB), fontSize: 14)),
          ),
        ],
      ),
    );
  }
}