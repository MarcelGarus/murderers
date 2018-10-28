import 'package:flutter/material.dart';
import 'home.dart';
import 'intro.dart';
import 'choose_name.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Murderer Game',
      theme: ThemeData(
        primarySwatch: Colors.red,
        fontFamily: 'Signature',
      ),
      home: Intro(),
    );
  }
}
