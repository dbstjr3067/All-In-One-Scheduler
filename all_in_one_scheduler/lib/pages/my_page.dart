import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:all_in_one_scheduler/pages/alarm_page.dart';
import 'package:all_in_one_scheduler/services/alarm/alarm.dart';
import 'package:all_in_one_scheduler/services/alarm/quiz_type.dart';
import 'package:all_in_one_scheduler/services/firestore_service.dart';

import 'package:permission_handler/permission_handler.dart';

class MyPage extends StatefulWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  User? _user;
  final FirestoreService _firestoreService = FirestoreService();
  bool _reminderEnabled = false;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    // Firebase Auth 상태 변경 리스너 추가
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (mounted) {
        setState(() {
          _user = user;
        });
      }
    });
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);

      final user = userCredential.user;
      if (user == null) return;

      setState(() {
        _user = user;
      });

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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인 실패: $e')),
        );
      }
    }
  }

  Future<void> _signOut() async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            '로그아웃 하시겠습니까?',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: const Text(
            '게스트 상태에서의 알람, 스케줄 저장 및 수정은 서버에 반영되지 않습니다.\n다른 계정에 로그인할 시 게스트 상태의 저장정보는 지워집니다.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                '로그아웃',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (shouldSignOut == true) {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
      setState(() {
        _user = null;
      });
    }
  }

  Future<void> _requestOverlayPermission() async {
    final status = await Permission.systemAlertWindow.request();

    if (status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('권한이 허용되었습니다')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: const Color(0xFFD4D4E8),
              padding: const EdgeInsets.all(16),
              child: const Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  '내 정보',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // 사용자 프로필 카드
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8DEFF),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: _user?.photoURL != null
                                ? NetworkImage(_user!.photoURL!)
                                : null,
                            radius: 32,
                            backgroundColor: Colors.white,
                            child: _user == null
                                ? const Icon(Icons.person, size: 32, color: Color(0xFF7C6FDB))
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _user?.displayName ?? "게스트",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _user == null
                                    ? ElevatedButton.icon(
                                  icon: const Icon(Icons.login, size: 16),
                                  label: const Text(
                                    "구글 계정으로 로그인",
                                    style: TextStyle(fontSize: 13),
                                  ),
                                  onPressed: _signInWithGoogle,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF7C6FDB),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    elevation: 0,
                                  ),
                                )
                                    : Text(
                                  _user!.email ?? "",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 메뉴 리스트
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _buildMenuItem(
                            icon: Icons.person_outline,
                            iconColor: const Color(0xFF7C6FDB),
                            title: "내 계정",
                            subtitle: "계정 설정",
                            onTap: () {},
                          ),
                          _buildDivider(),
                          _buildMenuItem(
                            icon: Icons.color_lens_outlined,
                            iconColor: const Color(0xFF7C6FDB),
                            title: "앱 테마 변경",
                            subtitle: "다크 모드로 변경하기/ UI 색상 변경",
                            onTap: () {},
                          ),
                          _buildDivider(),
                          _buildMenuItemWithSwitch(
                            icon: Icons.lock_outline,
                            iconColor: const Color(0xFF7C6FDB),
                            title: "리마인더 기능",
                            subtitle: "리마인더 기능 On/Off",
                            value: _reminderEnabled,
                            onChanged: (value) {
                              setState(() {
                                _reminderEnabled = value;
                              });
                            },
                          ),
                          _buildDivider(),
                          _buildMenuItem(
                            icon: Icons.security_outlined,
                            iconColor: const Color(0xFF7C6FDB),
                            title: "접근성 설정",
                            subtitle: "앱 내 허용되는 기능 설정",
                            onTap: () async {
                              await _requestOverlayPermission();
                            },
                          ),
                          if (_user != null) ...[
                            _buildDivider(),
                            _buildMenuItem(
                              icon: Icons.logout_outlined,
                              iconColor: const Color(0xFF7C6FDB),
                              title: "로그아웃",
                              subtitle: "계정 로그아웃하기",
                              onTap: _signOut,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.black26,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItemWithSwitch({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black45,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF7C6FDB),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 72),
      child: Divider(
        height: 1,
        thickness: 1,
        color: Colors.grey.shade200,
      ),
    );
  }
}