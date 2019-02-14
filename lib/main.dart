//import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';

import 'bloc/bloc.dart';
import 'bloc/bloc_provider.dart';
import 'screens/game.dart';
import 'screens/intro.dart';
import 'screens/setup.dart';
import 'screens/signin.dart';
import 'screens/splash.dart';
import 'widgets/theme.dart';

void main() => runApp(BlocProvider(child: MurderersApp()));

class MurderersApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MyTheme(
      data: MyThemeData(
        backgroundColor: Colors.white,
        backgroundGradientColor: Colors.white,
        headerText: TextStyle(fontFamily: 'Signature', color: Colors.red),
        bodyText: TextStyle(color: Colors.black),
        raisedButtonFillColor: Colors.red,
        raisedButtonTextColor: Colors.white,
        flatButtonColor: Colors.red,
      ),
      child: MaterialApp(
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
      ),
    );
  }
}
