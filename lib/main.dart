import 'package:flutter/material.dart';

import 'bloc/bloc.dart';
import 'bloc/bloc_provider.dart';
import 'screens/game.dart';
import 'screens/intro.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      child: MaterialApp(
        title: 'The Murderer Game',
        theme: ThemeData(primarySwatch: Colors.red),
        home: AdaptiveScreen(),
      )
    );
  }
}

class AdaptiveScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Bloc.of(context).activeGameStream,
      builder: (BuildContext context, AsyncSnapshot<Game> snapshot) {
        print('Rebuilding the adaptive screen. Are data available? ${snapshot.hasData}');
        return snapshot.hasData ? GameScreen() : IntroScreen();
      },
    );
  }
}
