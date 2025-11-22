import 'package:alarm/alarm.dart';

class AlarmSoundService {
  static final AlarmSoundService _instance = AlarmSoundService._internal();
  factory AlarmSoundService() => _instance;
  AlarmSoundService._internal();

  bool _isPlaying = false;

  /// 알람 소리 재생 시작 (alarm 패키지가 자동으로 처리)
  Future<void> startAlarm({
    String soundPath = 'sounds/alarm.mp3',
    bool enableVibration = true,
  }) async {
    _isPlaying = true;
    print('알람 소리 재생 중 (alarm 패키지)');
  }

  /// 알람 소리 정지
  Future<void> stopAlarm() async {
    if (!_isPlaying) return;

    try {
      // 현재 울리고 있는 알람 모두 정지
      await Alarm.stopAll();
      _isPlaying = false;
      print('알람 소리 정지');
    } catch (e) {
      print('알람 정지 오류: $e');
    }
  }

  /// 알람이 재생 중인지 확인
  bool get isPlaying => _isPlaying;

  /// 서비스 정리
  void dispose() {
    // alarm 패키지가 자동으로 처리
  }
}