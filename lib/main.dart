import 'package:flutter/material.dart';
import 'bloc_provider.dart';
import 'intro.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      child: MaterialApp(
        title: 'The Murderer Game',
        theme: ThemeData(primarySwatch: Colors.red),
        home: IntroScreen(),
      )
    );
  }
}
