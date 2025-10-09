import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
//이 아래로 코드 작성, 위는 무시
    return MaterialApp(
      home: Center(
        child: Container(width:50, height:50, color: Colors.blue),
      )
    ); //MaterialApp
  }
}
