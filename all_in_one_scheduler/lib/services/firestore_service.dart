import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:all_in_one_scheduler/services/alarm/alarm.dart'; // Alarm 모델 import
import 'package:all_in_one_scheduler/services/schedule/schedule.dart'; // Schedule 모델 import

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 알람 데이터를 Firestore에 저장하는 함수
  // 이제 각 Alarm을 고유 문서로 저장하기 위해 Write Batch를 사용합니다.
  Future<void> saveAlarms(User user, List<Alarm> alarms) async {
    final CollectionReference alarmCollectionRef = _db
        .collection('users')
        .doc(user.uid)
        .collection('alarms');

    // 배치 쓰기(Write Batch)를 시작하여 모든 작업을 한 번의 트랜잭션처럼 처리합니다.
    WriteBatch batch = _db.batch();

    // 1. 기존 알람 문서들을 모두 삭제하는 작업을 배치에 추가 (전체 덮어쓰기 시뮬레이션)
    //    실제 앱에서는 단일 알람 추가/수정/삭제 함수가 따로 필요합니다.
    try {
      final existingDocs = await alarmCollectionRef.get();
      for (var doc in existingDocs.docs) {
        batch.delete(doc.reference);
      }
    } catch (e) {
      // 삭제 중 오류가 발생해도 계속 진행하거나, 여기서 예외를 던질 수 있습니다.
      print("FirestoreService: 기존 알람 삭제 중 오류: $e");
    }

    // 2. 새로운 알람들을 고유 ID를 가진 문서로 추가하는 작업을 배치에 추가
    for (final alarm in alarms) {
      // .doc()을 호출하지 않고 .set()을 호출할 때 .doc()에 인수를 비워두면
      // Firestore가 자동 ID를 생성합니다. (add()와 유사하게 동작)
      // 또는 add()를 사용해도 됩니다. 여기서는 set(doc()) 방식을 사용했습니다.
      batch.set(alarmCollectionRef.doc(), alarm.toJson());
      print(alarmCollectionRef.doc());
    }
    print("firestore_service: 총 ${alarms.length}개의 알람을 저장했습니다.");
    // 3. 배치 작업을 커밋 (실행)
    await batch.commit();
  }

  // 알람 데이터를 불러오는 함수
  // 컬렉션에서 모든 문서를 읽어옵니다.
  Future<List<Alarm>> loadAlarms(User user) async {
    try {
      final CollectionReference alarmCollectionRef = _db
          .collection('users')
          .doc(user.uid)
          .collection('alarms');

      // 컬렉션 전체를 가져옵니다.
      final querySnapshot = await alarmCollectionRef.get();

      // 문서 리스트를 Alarm 객체 리스트로 변환 (fromJson을 통해 역변환)
      print("firestore_service: 총 ${querySnapshot.docs.length}개의 알람을 불러왔습니다.");
      return querySnapshot.docs
          .map((doc) => Alarm.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

    } catch (e) {
      print("FirestoreService: 알람 로드 오류: $e");
      return [];
    }
  }

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
      print("FirestoreService: 기존 알람 삭제 중 오류: $e");
    }

    for (final schedule in schedules) {
      batch.set(scheduleCollectionRef.doc(), schedule.toJson());
      print(scheduleCollectionRef.doc());
    }
    print("firestore_service: 총 ${schedules.length}개의 스케쥴을 저장했습니다.");
    await batch.commit();
  }

  Future<List<Schedule>> loadSchedules(User user) async {
    try {
      final CollectionReference scheduleCollectionRef = _db
          .collection('users')
          .doc(user.uid)
          .collection('schedules');

      // 컬렉션 전체를 가져옵니다.
      final querySnapshot = await scheduleCollectionRef.get();

      // 문서 리스트를 Alarm 객체 리스트로 변환 (fromJson을 통해 역변환)
      print("firestore_service: 총 ${querySnapshot.docs.length}개의 알람을 불러왔습니다.");
      return querySnapshot.docs
          .map((doc) => Schedule.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

    } catch (e) {
      print("FirestoreService: 알람 로드 오류: $e");
      return [];
    }
  }
}