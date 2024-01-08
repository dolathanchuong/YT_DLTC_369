import 'package:flutter/material.dart';
import 'package:yt_dltc_369/constants.dart';
import 'package:yt_dltc_369/pages/home/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
      theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: primaryColor,
          scaffoldBackgroundColor: primaryColor),
    );
  }

  String get newMethod => backGroundImage;
}
