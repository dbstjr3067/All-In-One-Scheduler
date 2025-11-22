import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

// 프로젝트 경로에 맞게 수정
import 'package:all_in_one_scheduler/services/alarm/alarm.dart';
import 'package:all_in_one_scheduler/services/alarm/quiz_type.dart';
import 'package:all_in_one_scheduler/services/firestore_service.dart';
import 'package:all_in_one_scheduler/pages/alarm/alarm_puzzle_setting_page.dart';
import 'package:all_in_one_scheduler/pages/alarm/alarm_sound_setting_page.dart';
import 'package:all_in_one_scheduler/pages/alarm/alarm_setting_page.dart';

// 알람 스케줄러 서비스 추가
import 'package:all_in_one_scheduler/services/alarm/alarm_scheduler_service.dart';

class AlarmPage extends StatefulWidget {
  const AlarmPage({Key? key}) : super(key: key);

  @override
  State<AlarmPage> createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  List<dynamic> _alarms = []; // Alarm 타입
  static const Color _cardColor = Color(0xFFEBEBFF);
  static const String _alarmsKey = 'saved_alarms';

  // final FirestoreService _firestoreService = FirestoreService();
  final AlarmSchedulerService _alarmScheduler = AlarmSchedulerService();

  @override
  void initState() {
    super.initState();
    final User? user = FirebaseAuth.instance.currentUser;
    if(user != null) {
      _loadAlarmsFromFirestore();
    } else {
      _loadAlarmsFromLocal();
    }
  }

  Future<void> _loadAlarmsFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? alarmsJson = prefs.getString(_alarmsKey);

      if (alarmsJson != null && alarmsJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(alarmsJson);

        setState(() {
          // _alarms = decoded.map((json) => Alarm.fromJson(json as Map<String, dynamic>)).toList();
          _alarms = decoded; // 임시
        });

        print('alarm_page: 로컬에서 ${_alarms.length}개의 알람을 불러왔습니다.');

        // 알람 스케줄러에 모든 알람 재등록
        await _alarmScheduler.rescheduleAllAlarms(_alarms);
      } else {
        print('alarm_page: 저장된 알람이 없습니다.');
      }
    } catch (e) {
      print('alarm_page: 알람 불러오기 실패: $e');
    }
  }

  Future<void> _saveAlarmsToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final alarmsMap =
      _alarms.map((alarm) => alarm.toJson() as Map<String, dynamic>).toList();
      final String alarmsJson = jsonEncode(alarmsMap);
      await prefs.setString(_alarmsKey, alarmsJson);
      print('alarm_page: ${_alarms.length}개의 알람을 로컬에 저장했습니다.');

      // 저장 후 스케줄러 업데이트
      await _alarmScheduler.rescheduleAllAlarms(_alarms);
    } catch (e) {
      print('alarm_page: 알람 저장 실패: $e');
    }
  }

  Future<void> _loadAlarmsFromFirestore() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('alarm_page: Firestore 알람을 로드하려면 로그인이 필요합니다.');
      return;
    }

    try {
      // final List<Alarm> firestoreAlarms = await _firestoreService.loadAlarms(user);
      final List<dynamic> firestoreAlarms = []; // 임시

      if (firestoreAlarms.isNotEmpty) {
        setState(() {
          _alarms = firestoreAlarms;
        });
        print('alarm_page: Firestore에서 ${_alarms.length}개의 알람을 성공적으로 불러왔습니다.');
        _saveAlarmsToLocal();
      } else {
        print('alarm_page: Firestore에 저장된 알람이 없습니다.');
      }
    } catch (e) {
      print('alarm_page: Firestore 알람 로드 실패: $e');
    }
  }

  Future<void> _saveAlarmsToFirestore(User user) async {
    try {
      // await _firestoreService.saveAlarms(user, _alarms);
      print('alarm_page: ${_alarms.length}개의 알람 목록을 Firestore에 성공적으로 저장했습니다.');
    } catch (e) {
      print('alarm_page: 알람 목록 Firestore 저장 실패: $e');
    }
  }

  void showAlarmSettings({dynamic alarmToEdit, int? index}) {
    // AlarmSettingPage로 이동
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AlarmSettingPage(
          initialAlarm: alarmToEdit,
          isEditMode: alarmToEdit != null,
        ),
      ),
    ).then((result) {
      if (result != null) {
        setState(() {
          if (result is Alarm) {
            if (index != null) {
              // 수정
              _alarms[index] = result;
              _alarmScheduler.scheduleAlarmFromObject(result, index);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('알람이 수정되었습니다.')),
              );
            } else {
              // 추가
              _alarms.add(result);
              _alarmScheduler.scheduleAlarmFromObject(result, _alarms.length - 1);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('새 알람이 추가되었습니다.')),
              );
            }
          } else if (result == 'delete' && index != null) {
            // 삭제
            _alarmScheduler.cancelAlarm(index);
            _alarms.removeAt(index);
            // 인덱스 재정렬을 위해 전체 재스케줄링
            _alarmScheduler.rescheduleAllAlarms(_alarms);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('알람이 삭제되었습니다.')),
            );
          }
          _saveAlarmsToLocal();
          final User? user = FirebaseAuth.instance.currentUser;
          if(user != null) {
            _saveAlarmsToFirestore(user);
          }
        });
      }
    });

  }

  void _toggleAlarm(int index, bool newValue) async {
    setState(() {
      _alarms[index].isEnabled = newValue;
    });

    // 알람 스케줄러 업데이트
    if (newValue) {
      // 알람 활성화 - 스케줄링
      await _alarmScheduler.scheduleAlarmFromObject(_alarms[index], index);
    } else {
      // 알람 비활성화 - 취소
      await _alarmScheduler.cancelAlarm(index);
    }

    _saveAlarmsToLocal();
    final User? user = FirebaseAuth.instance.currentUser;
    if(user != null) {
      _saveAlarmsToFirestore(user);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: const Color(0xFFD4D4E8),
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '알람',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.add_circle_outline,
                      size: screenWidth * 0.075,
                    ),
                    color: Colors.black,
                    onPressed: () {
                      showAlarmSettings();
                    },
                  ),
                ],
              ),
            ),

            // 알람 목록
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Column(
                  children: _alarms.asMap().entries.map((entry) {
                    final index = entry.key;
                    final alarm = entry.value;
                    return GestureDetector(
                      onTap: () => showAlarmSettings(alarmToEdit: alarm, index: index),
                      child: Padding(
                        padding: EdgeInsets.only(bottom: screenWidth * 0.04),
                        child: _buildAlarmItem(
                          title: alarm.formattedTime,
                          subtitle: alarm.repeatDaysString,
                          value: alarm.isEnabled,
                          onChanged: (newValue) => _toggleAlarm(index, newValue),
                          screenWidth: screenWidth,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlarmItem({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required double screenWidth,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: screenWidth * 0.045,
      ),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(12),
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
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                // 시간
                Text(
                  title,
                  style: TextStyle(
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                SizedBox(width: screenWidth * 0.04),
                // 요일
                Flexible(
                  child: Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: screenWidth * 0.042,
                      fontWeight: FontWeight.w400,
                      color: Colors.black.withOpacity(0.6),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 1.0,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: Colors.white,
              activeTrackColor: Colors.green,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: const Color(0xFFD4D4E8).withOpacity(0.5),
              splashRadius: 0.0,
            ),
          ),
        ],
      ),
    );
  }
}