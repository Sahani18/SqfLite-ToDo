import 'package:flutter/material.dart';
import 'splash.dart';

void main()=>runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'List Task',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(backgroundColor: Color(0xff5267d1)),
      home: SplashScreen(),
    );
  }
}
