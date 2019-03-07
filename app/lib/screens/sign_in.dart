import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_villains/villain.dart';

import '../bloc/bloc.dart';
import '../widgets/button.dart';
import '../widgets/theme.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  Future<void> _signIn(SignInType type) async {
    Bloc.of(context).logEvent(AnalyticsEvent.sign_in_attempt, { 'type': type });
    try {
      await Bloc.of(context).signIn(type);

      // Signing in was successful.
      Bloc.of(context).logEvent(AnalyticsEvent.sign_in_success);
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => EnterNameScreen()
      ));
    } catch (e) {
      // User aborted sign in or timeout (no internet).
      Bloc.of(context).logEvent(AnalyticsEvent.sign_in_failure, { 'error': e });
      rethrow;
    }
  }

  Future<void> _signInWithGoogle() => _signIn(SignInType.google);
  Future<void> _signInAnonymously() => _signIn(SignInType.anonymous);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: <Widget>[
          Spacer(flex: 2),
          Text(
            "Sign in to synchronize your games across all your devices.",
            textAlign: TextAlign.center,
            textScaleFactor: 1.2,
          ),
          SizedBox(height: 16),
          _buildGoogleButton(context),
          SizedBox(height: 16),
          Button.text('Sign in anonymously\n(erstmal nicht nehmen)',
            isRaised: false,
            onPressed: _signInAnonymously,
          ),
          Spacer(),
        ],
      ),
    );
  }

  Widget _buildGoogleButton(BuildContext context) {
    return MyTheme(
      data: MyTheme.of(context).copyWith(
        primaryButtonBackgroundColor: Colors.white,
        primaryButtonTextColor: Colors.red,
      ),
      child: Button.icon(
        onPressed: _signInWithGoogle,
        icon: SvgPicture.asset('images/google_icon.svg',
          width: 36,
          height: 36,
          semanticsLabel: 'Google logo',
        ),
        text: 'Sign in with Google',
      ),
    );
  }
}

class EnterNameScreen extends StatefulWidget {
  @override
  _EnterNameScreenState createState() => _EnterNameScreenState();
}

class _EnterNameScreenState extends State<EnterNameScreen> with TickerProviderStateMixin {
  final controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.text = Bloc.of(context).name;
  }

  Future<void> _onNameEntered() async {
    final name = controller.text;
    await Bloc.of(context).createAccount(name);

    if (Bloc.of(context).isSignedIn) {
      await Navigator.of(context).pushNamedAndRemoveUntil('/setup', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            children: <Widget>[
              Spacer(),
              Container(
                width: 200,
                height: 150,
                child: Placeholder(),
              ),
              Padding(
                padding: EdgeInsets.all(32),
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Enter first and last name",
                  ),
                ),
              ),
              Button.text("Continue", onPressed: _onNameEntered),
              Spacer(),
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "Other players will be able to see it. To counter confusion "
                  "in large groups, it's recommended to enter both your first "
                  "and last name.",
                  textAlign: TextAlign.center,
                  textScaleFactor: 0.9,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
