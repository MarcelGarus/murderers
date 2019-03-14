import 'dart:async';

import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';

import '../bloc/bloc.dart';

/// Screen with the logo. Is displayed when the app is openend.
/// 
/// Redirects to the next appropriate screen.
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  void initState() {
    super.initState();

    Future.delayed(Duration(milliseconds: 5000), () {
      final bloc = Bloc.of(context);
      String targetRoute;

      if (!bloc.hasAccount) {
        targetRoute = '/intro';
      } else if (bloc.hasCurrentGame) {
        targetRoute = '/game';
      } else {
        targetRoute = '/setup';
      }

      Navigator.pushReplacementNamed(context, targetRoute);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      alignment: Alignment.center,
      child: Center(
        child: SizedBox(
          width: 92,
          height: 92,
          child: FlareActor('images/logo.flr', animation: 'intro'),
        ),
      ),
    );
  }
}
