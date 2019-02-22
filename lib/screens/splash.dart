import 'dart:async';

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

    Future.delayed(Duration(seconds: 1), () {
      final bloc = Bloc.of(context);
      final targetRoute = (bloc.currentGame == null) ? '/intro' : '/game';
      Navigator.pushReplacementNamed(context, targetRoute);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.amber,
      alignment: Alignment.center,
      child: FlutterLogo(),
    );
  }
}
