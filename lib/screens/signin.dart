import 'dart:async';

import 'package:flutter/material.dart';

import '../bloc/bloc.dart';
import '../widgets/button.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> with TickerProviderStateMixin {
  bool signingIn = false;

  Future<void> _signIn(SignInType type) async {
    setState(() => signingIn = true);

    try {
      await Bloc.of(context).signIn(type);
    } catch (e) { /* User aborted sign in or timeout (no internet). */ }
    setState(() { signingIn = false; });

    await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => EnterNameScreen()
    ));
  }

  Future<void> _signInWithGoogle() => _signIn(SignInType.google);
  Future<void> _signInAnonymously() => _signIn(SignInType.anonymous);

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
                height: 300,
                child: Placeholder(),
              ),
              Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  "If you sign in, your games will be synchronized across all "
                  "your devices.\nAlso, you'll be able to create your own games.",
                  textAlign: TextAlign.center,
                  textScaleFactor: 1.2,
                )
              ),
              Button(
                onPressed: _signInWithGoogle,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.g_translate),
                    SizedBox(width: 8),
                    Text('Sign in'),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Button(
                text: 'Skip',
                isRaised: false,
                onPressed: _signInAnonymously,
              ),
              Spacer(),
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("Only the game creator will be able to see your email address.",
                  textAlign: TextAlign.center,
                  textScaleFactor: 0.9,
                )
              ),
            ],
          ),
        ),
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
              Button(
                text: "Continue",
                onPressed: _onNameEntered,
              ),
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
