import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_villains/villain.dart';

import 'bloc/bloc.dart';
import 'bloc/bloc_provider.dart';
import 'screens/game.dart';
import 'screens/intro.dart';
import 'screens/setup.dart';
import 'screens/sign_in.dart';
import 'screens/splash.dart';
import 'widgets/theme.dart';

void main() => runApp(BlocProvider(child: MurderersApp()));

class MurderersApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MyTheme(
      data: kThemeLight,
      child: MaterialApp(
        title: 'The Murderer Game',
        theme: ThemeData(primarySwatch: Colors.red),
        navigatorObservers: [
          VillainTransitionObserver(),
          Bloc.of(context).firebaseAnalyticsObserver,
        ],
        home: SplashScreen(),
        routes: {
          '/intro': (ctx) => IntroScreen(),
          '/signin': (ctx) => SignInScreen(),
          '/setup': (ctx) => SetupJourney(),
          '/game': (ctx) => GameScreen(),
        },
      ),
    );
  }
}
