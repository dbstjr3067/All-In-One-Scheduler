enum QuizDifficulty {
  easy,    // 쉬움
  medium,  // 보통
  hard,    // 어려움
}

class QuizType {
  final String typeName;
  final QuizDifficulty difficulty; // 퀴즈 난이도
  final int requiredCount;        // 알람을 끄기 위해 풀어야 하는 퀴즈 횟수

  QuizType({
    this.typeName = '수학 퀴즈',
    this.difficulty = QuizDifficulty.medium,
    this.requiredCount = 3,
  });
}