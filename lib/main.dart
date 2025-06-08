import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'pages/home.dart';

void main() {
  debugCheckIntrinsicSizes = true;
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: '电商工具箱',
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
