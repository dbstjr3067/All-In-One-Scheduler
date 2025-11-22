import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:all_in_one_scheduler/services/alarm/alarm.dart'; // Alarm 모델 import
import 'package:all_in_one_scheduler/services/schedule/schedule.dart'; // Schedule 모델 import
import 'package:all_in_one_scheduler/services/schedule/completion.dart'; // Completion 모델 import

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ==================== 알람 관련 ====================

  // 알람 데이터를 Firestore에 저장하는 함수
  Future<void> saveAlarms(User user, List<dynamic> alarms) async {
    final CollectionReference alarmCollectionRef = _db
        .collection('users')
        .doc(user.uid)
        .collection('alarms');

    WriteBatch batch = _db.batch();

    try {
      final existingDocs = await alarmCollectionRef.get();
      for (var doc in existingDocs.docs) {
        batch.delete(doc.reference);
      }
    } catch (e) {
      print("FirestoreService: 기존 알람 삭제 중 오류: $e");
    }

    for (final alarm in alarms) {
      batch.set(alarmCollectionRef.doc(), alarm.toJson());
      print(alarmCollectionRef.doc());
    }
    print("firestore_service: 총 ${alarms.length}개의 알람을 저장했습니다.");
    await batch.commit();
  }

  // 알람 데이터를 불러오는 함수
  Future<List<MyAlarm>> loadAlarms(User user) async {
    try {
      final CollectionReference alarmCollectionRef = _db
          .collection('users')
          .doc(user.uid)
          .collection('alarms');

      final querySnapshot = await alarmCollectionRef.get();

      print("firestore_service: 총 ${querySnapshot.docs.length}개의 알람을 불러왔습니다.");
      return querySnapshot.docs
          .map((doc) => MyAlarm.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

    } catch (e) {
      print("FirestoreService: 알람 로드 오류: $e");
      return [];
    }
  }

  // ==================== 스케줄 관련 ====================

  Future<void> saveSchedules(User user, List<Schedule> schedules) async {
    final CollectionReference scheduleCollectionRef = _db
        .collection('users')
        .doc(user.uid)
        .collection('schedules');

    WriteBatch batch = _db.batch();

    try {
      final existingDocs = await scheduleCollectionRef.get();
      for (var doc in existingDocs.docs) {
        batch.delete(doc.reference);
      }
    } catch (e) {
      print("FirestoreService: 기존 스케줄 삭제 중 오류: $e");
    }

    for (final schedule in schedules) {
      batch.set(scheduleCollectionRef.doc(), schedule.toJson());
      print(scheduleCollectionRef.doc());
    }
    print("firestore_service: 총 ${schedules.length}개의 스케줄을 저장했습니다.");
    await batch.commit();
  }

  Future<List<Schedule>> loadSchedules(User user) async {
    try {
      final CollectionReference scheduleCollectionRef = _db
          .collection('users')
          .doc(user.uid)
          .collection('schedules');

      final querySnapshot = await scheduleCollectionRef.get();

      print("firestore_service: 총 ${querySnapshot.docs.length}개의 스케줄을 불러왔습니다.");
      return querySnapshot.docs
          .map((doc) => Schedule.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

    } catch (e) {
      print("FirestoreService: 스케줄 로드 오류: $e");
      return [];
    }
  }

  // ==================== Completion 관련 ====================

  // Completion 리스트를 Firestore에 저장하는 함수
  // users/uid/completions 컬렉션에 각 Completion을 Auto-ID를 가진 독립 문서로 저장
  Future<void> saveCompletions(User user, List<Completion> completions) async {
    final CollectionReference completionCollectionRef = _db
        .collection('users')
        .doc(user.uid)
        .collection('completions');

    WriteBatch batch = _db.batch();

    try {
      // 1. 기존 문서 모두 삭제
      final existingDocs = await completionCollectionRef.get();
      for (var doc in existingDocs.docs) {
        batch.delete(doc.reference);
      }
    } catch (e) {
      print("FirestoreService: 기존 Completion 삭제 중 오류: $e");
    }

    // 2. 새로운 Completion들을 Auto-ID를 가진 독립 문서로 저장
    for (final completion in completions) {
      batch.set(completionCollectionRef.doc(), completion.toJson());
    }

    print("firestore_service: 총 ${completions.length}개의 Completion을 저장했습니다.");
    await batch.commit();
  }

  // Completion 데이터를 불러오는 함수
  Future<List<Completion>> loadCompletions(User user) async {
    try {
      final CollectionReference completionCollectionRef = _db
          .collection('users')
          .doc(user.uid)
          .collection('completions');

      final querySnapshot = await completionCollectionRef.get();

      print("firestore_service: 총 ${querySnapshot.docs.length}개의 Completion을 불러왔습니다.");

      return querySnapshot.docs
          .map((doc) => Completion.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

    } catch (e) {
      print("FirestoreService: Completion 로드 오류: $e");
      return [];
    }
  }
}