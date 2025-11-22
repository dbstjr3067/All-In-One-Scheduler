import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

class AlarmSoundService {
  static final AlarmSoundService _instance = AlarmSoundService._internal();
  factory AlarmSoundService() => _instance;
  AlarmSoundService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  /// 알람 소리 재생 시작
  Future<void> startAlarm({
    String soundPath = 'sounds/alarm.mp3', // assets 폴더의 알람 소리
    bool enableVibration = true,
  }) async {
    if (_isPlaying) return;

    try {
      _isPlaying = true;

      // 볼륨 최대로 설정
      await _audioPlayer.setVolume(1.0);

      // 반복 재생 모드
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);

      // 알람 소리 재생
      await _audioPlayer.play(AssetSource(soundPath));

      // 진동 시작 (가능한 경우)
      if (enableVibration && await Vibration.hasVibrator() == true) {
        // 500ms 진동, 500ms 멈춤을 반복
        Vibration.vibrate(pattern: [500, 500], repeat: 0);
      }
    } catch (e) {
      print('알람 재생 오류: $e');
      _isPlaying = false;
    }
  }

  /// 알람 소리 정지
  Future<void> stopAlarm() async {
    if (!_isPlaying) return;

    try {
      await _audioPlayer.stop();
      await Vibration.cancel();
      _isPlaying = false;
    } catch (e) {
      print('알람 정지 오류: $e');
    }
  }

  /// 알람이 재생 중인지 확인
  bool get isPlaying => _isPlaying;

  /// 서비스 정리
  void dispose() {
    _audioPlayer.dispose();
  }
}