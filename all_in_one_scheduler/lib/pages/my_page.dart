import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:all_in_one_scheduler/pages/alarm_page.dart';
import 'package:all_in_one_scheduler/services/alarm/alarm.dart';
import 'package:all_in_one_scheduler/services/alarm/quiz_type.dart';
import 'package:all_in_one_scheduler/services/firestore_service.dart';

class MyPage extends StatefulWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  User? _user;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
  }

  Future<void> _signInWithGoogle() async {
    try {
      //1. Google 로그인 창 열기
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;
      //2. 인증 토큰 받아오기
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      //3. Firebase 인증 자격 증명 생성
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      //4. Firebase에 로그인 (Google 계정 연동)
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final user = userCredential.user;
      if (user == null) return;

      setState(() {
        _user = user; //화면에 표시하기 위해 저장
      });

      //5. FireStore에 사용자 정보 저장
      await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set({
        'uid': user.uid,
        'name': user.displayName,
        'email': user.email,
        'photoUrl': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint("Firestore에 사용자 정보 저장 완료: ${user.email}");
    } catch (e) {
      debugPrint("로그인 오류: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인 실패: $e')),
      );
    }
  }

  //로그아웃 함수
  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    setState(() {
      _user = null;
    });
  }

  /* 알람 데이터를 Firestore에 저장하는 함수 (서비스 호출)
  Future<void> _saveAlarms() async {
    final user = _user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }

    try {
      // FirestoreService를 통해 데이터 저장
      await _firestoreService.saveAlarms(user, );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('알람 목록이 개인 서버에 성공적으로 저장되었습니다!')),
      );

    } catch (e) {
      debugPrint("알람 저장 오류: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('알람 저장 실패: $e')),
      );
    }
  }*/

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text("내 정보")),
      body: Center(
        child: _user == null
        //로그인 한 상태(user값이 null이 아닌 상태) -> 유저 이름, 계정바꾸기&로그아웃 버튼 뜸
            ? ElevatedButton.icon(
          icon: const Icon(Icons.login),
          label: const Text("Google 계정으로 로그인"),
          onPressed: _signInWithGoogle,
        )
        //로그인을 아직 하지 않은 상태(Guest 상태) -> 게스트, 로그인버튼 뜸
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(_user!.photoURL ?? ""),
              radius: 40,
            ),
            const SizedBox(height: 12),
            Text(_user!.displayName ?? "",
                style: const TextStyle(fontSize: 18)),
            Text(_user!.email ?? "",
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            // 알람 저장 버튼
            /*ElevatedButton.icon(
              icon: const Icon(Icons.cloud_upload),
              label: const Text("알람 목록 서버에 저장하기 (샘플)"),
              onPressed: pass,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
              ),
            ),*/
            ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text("로그아웃"),
              onPressed: _signOut,
            )
          ],
        ),
      ),
    );
  }
}