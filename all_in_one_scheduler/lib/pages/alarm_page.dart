import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; //로컬 저장
import 'dart:convert'; // JSON 인코딩/디코딩용
import 'package:all_in_one_scheduler/services/alarm/alarm.dart';
import 'package:all_in_one_scheduler/services/alarm/quiz_type.dart';

import 'alarm/alarm_puzzle_setting_page.dart';
import 'alarm/alarm_sound_setting_page.dart';
import 'alarm/alarm_setting_page.dart';

class AlarmPage extends StatefulWidget {
  const AlarmPage({Key? key}) : super(key: key);

  @override
  State<AlarmPage> createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  List<Alarm> _alarms = [];
  // scheduler_page.dart의 스타일을 참고한 배경색
  static const Color _cardColor = Color(0xFFEBEBFF); // 연한 보라색 계열
  //SharedPreference 키
  static const String _alarmsKey = 'saved_alarms';

  @override
  void initState() {
    super.initState();
    _loadAlarmsFromLocal(); // 앱 시작 시 로컬에서 알람 불러오기
  }
  Future<void> _loadAlarmsFromLocal() async { //로컬에서 알람 불러오기
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? alarmsJson = prefs.getString(_alarmsKey);

      if (alarmsJson != null && alarmsJson.isNotEmpty) {
        // JSON 문자열을 List<dynamic>으로 디코딩
        final List<dynamic> decoded = jsonDecode(alarmsJson);

        // List<dynamic>을 List<Alarm>으로 변환
        setState(() {
          _alarms = decoded
              .map((json) => Alarm.fromJson(json as Map<String, dynamic>))
              .toList();
        });

        print('alarm_page: 로컬에서 ${_alarms.length}개의 알람을 불러왔습니다.');
      } else {
        print('alarm_page: 저장된 알람이 없습니다.');
      }
    } catch (e) {
      print('alarm_page: 알람 불러오기 실패: $e');
    }
  }
  Future<void> _saveAlarmsToLocal() async { //로컬에 알람 저장하기
    try {
      final prefs = await SharedPreferences.getInstance();

      // List<Alarm>을 List<Map>으로 변환
      final List<Map<String, dynamic>> alarmsMap =
      _alarms.map((alarm) => alarm.toJson()).toList();

      // JSON 문자열로 인코딩
      final String alarmsJson = jsonEncode(alarmsMap);

      // SharedPreferences에 저장
      await prefs.setString(_alarmsKey, alarmsJson);

      print('alarm_page: ${_alarms.length}개의 알람을 로컬에 저장했습니다.');
    } catch (e) {
      print('alarm_page: 알람 저장 실패: $e');
    }
  }
  // 알람 설정 페이지를 Full-Screen Modal로 띄우는 함수
  void _showAlarmSettings({Alarm? alarmToEdit, int? index}) {
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
            // 저장(확인) 버튼을 눌러 Alarm 객체가 반환된 경우
            if (index != null) {
              // 기존 알람 수정
              _alarms[index] = result;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('알람이 수정되었습니다.')),
              );
            } else {
              // 새 알람 추가
              _alarms.add(result);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('새 알람이 추가되었습니다.')),
              );
            }
          } else if (result == 'delete' && index != null) {
            // 삭제 버튼을 눌러 'delete' 문자열이 반환된 경우
            _alarms.removeAt(index);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('알람이 삭제되었습니다.')),
            );
          }
          //변경사항을 로컬에 저장
          _saveAlarmsToLocal();
        });
      }
    });
  }

  //알람의 isEnabled 상태를 토글하는 함수
  void _toggleAlarm(int index, bool newValue) {
    setState(() {
      _alarms[index].isEnabled = newValue;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // SafeArea는 scheduler_page.dart에서 사용되었으므로 여기서도 사용
      body: SafeArea(
        child: Column(
          children: [
            // Header (scheduler_page.dart의 '캘린더' 헤더와 유사하게 구현)
            Container(
              color: const Color(0xFFD4D4E8), // scheduler_page.dart의 Header 배경색
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
                  // '알람 추가' 버튼 (사진의 '+' 아이콘)
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, size: 30),
                    color: Colors.black,
                    onPressed: () {
                      _showAlarmSettings();
                    },
                  ),
                ],
              ),
            ),

            // ---

            // 알람 목록을 표시할 영역
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: _alarms.asMap().entries.map((entry) {
                    final index = entry.key;
                    final alarm = entry.value;
                    return GestureDetector(
                      onTap: () => _showAlarmSettings(alarmToEdit: alarm, index: index),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildAlarmItem(
                          title: alarm.formattedTime,
                          subtitle: alarm.repeatDaysString,
                          value: alarm.isEnabled,
                          onChanged: (newValue) => _toggleAlarm(index, newValue),
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

  // 알람 아이템 위젯을 생성하는 Helper Method
  Widget _buildAlarmItem({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    // scheduler_page.dart의 Container 스타일을 참고하여 구현
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        color: _cardColor, // 연한 보라색 배경
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
          // 타이틀과 서브 타이틀
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              // 타이틀 (알람 시간)
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              //간격
              const SizedBox(width: 24),
              //알람 실행 요일( ex)월 화 ... 금 )
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: Colors.black.withOpacity(0.6),
                ),
              ),
            ],
          ),

          // 스위치 버튼
          Transform.scale(
            scale: 1.2,
            child: Switch(
              value: value,
              onChanged: onChanged,
              // 사진과 비슷한 둥근 모양의 스위치 색상 설정
              activeThumbColor: Colors.white,
              activeTrackColor: Colors.green, // 트랙색상도 카드의 배경색 계열로 설정
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