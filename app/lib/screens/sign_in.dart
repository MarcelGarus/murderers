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
  Future<bool> _onSignInSuccess() async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (ctx) => _EnterNameScreen()
    ));
    return false; // Make the button stop spinning.
  }

  void _onSignInError(dynamic error) {
    // TODO: display an image or error
  }

  @override
  Widget build(BuildContext context) {
    final theme = MyTheme.of(context);

    return MyTheme(
      data: theme.copyWith(
        primaryButtonBackgroundColor: Colors.white,
        primaryButtonTextColor: Colors.black,
      ),
      child: Center(
        child: Column(
          children: <Widget>[
            Spacer(flex: 2),
            Text("Sign in to synchronize your games across all your devices.",
              textAlign: TextAlign.center,
              style: theme.bodyText,
            ),
            SizedBox(height: 16),
            Button<void>.icon(
              onPressed: () => Bloc.of(context).signIn(SignInType.google),
              onSuccess: (_) => _onSignInSuccess(),
              onError: _onSignInError,
              icon: SvgPicture.asset('images/google_icon.svg',
                width: 36,
                height: 36,
                semanticsLabel: 'Google logo',
              ),
              text: 'Sign in with Google',
            ),
            SizedBox(height: 16),
            Button.text('Sign in anonymously\n(erstmal nicht nehmen)',
              isRaised: false,
              onPressed: () => Bloc.of(context).signIn(SignInType.anonymous),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}

class _EnterNameScreen extends StatefulWidget {
  _EnterNameScreenState createState() => _EnterNameScreenState();
}

class _EnterNameScreenState extends State<_EnterNameScreen> {
  final _controller = TextEditingController();

  void initState() {
    super.initState();
    _controller.text = Bloc.of(context).name;
  }

  Future<void> _onNameEntered() async {
    final name = _controller.text;
    final bloc = Bloc.of(context);

    bloc.logEvent(AnalyticsEvent.name_entered);
    try {
      await bloc.createAccount(name);
      bloc.logEvent(AnalyticsEvent.signed_up);
      await Navigator.of(context).pushNamedAndRemoveUntil('/setup', (route) => false);
    } catch (e) {
      print('Something went wrong: $e');
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          alignment: Alignment.center,
          child: Column(
            children: <Widget>[
              Spacer(),
              Container(
                width: 200,
                height: 150,
                child: Placeholder(),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Enter first and last name",
                ),
              ),
              SizedBox(height: 16),
              Button.text("Continue", onPressed: _onNameEntered),
              Spacer(),
              Text(
                "Other players will be able to see it. To counter confusion "
                "in large groups, it's recommended to enter both your first "
                "and last name.",
                textAlign: TextAlign.center,
                style: MyTheme.of(context).bodyText.copyWith(fontSize: 12),
              ),
            ],
          ),
        )
      ),
    );
  }
}
