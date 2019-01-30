//import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';

import 'bloc/bloc.dart';
import 'bloc/bloc_provider.dart';
import 'screens/game.dart';
import 'screens/intro.dart';
import 'screens/setup.dart';
import 'screens/signin.dart';
import 'screens/splash.dart';

//void main() => runApp(BlocProvider(child: MyApp()));
void main() => runApp(BlocProvider(child: MurderersApp()));

class MurderersApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //final bloc = Bloc.of(context);
    return MaterialApp(
      title: 'The Murderer Game',
      theme: ThemeData(primarySwatch: Colors.red),
      /*navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: bloc.analytics),
      ],*/
      home: SplashScreen(),
      routes: {
        '/intro': (ctx) => IntroScreen(),
        '/signin': (ctx) => SignInScreen(),
        '/game': (ctx) => GameScreen(),
        '/setup': (ctx) => SetupJourney(),
      },
    );
  }
}
