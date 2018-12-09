import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';

import 'bloc/bloc.dart';
import 'bloc/bloc_provider.dart';
import 'screens/game.dart';
import 'screens/intro.dart';

void main() => runApp(BlocProvider(child: MyApp()));

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of the application.
  @override
  Widget build(BuildContext context) {
    final bloc = Bloc.of(context);
    return MaterialApp(
      title: 'The Murderer Game',
      theme: ThemeData(primarySwatch: Colors.red),
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: bloc.analytics),
      ],
      home: StreamBuilder(
        stream: bloc.activeGameStream,
        builder: (BuildContext context, AsyncSnapshot<Game> snapshot) {
          print('Rebuilding the adaptive screen. Are data available? ${snapshot.hasData}');
          return snapshot.hasData ? GameScreen() : IntroScreen();
        },
      ),
    );
  }
}
