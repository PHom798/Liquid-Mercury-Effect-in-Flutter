import 'package:flutter/material.dart';

import 'metalbutton.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Epic Habit Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'SF Pro Display',
      ),
      home:LiquidMetalShowcase(),
      debugShowCheckedModeBanner: false,
    );
  }
}