import 'package:flutter/material.dart';

import '../bloc.dart';
import '../game.dart';
import 'enter_name.dart';
import 'setup_bloc.dart';
import 'setup_finished.dart';
import 'setup_utils.dart';
import 'sign_in.dart';

class ConfirmGameScreen extends StatefulWidget {
  @override
  _ConfirmGameScreenState createState() => _ConfirmGameScreenState();
}

class _ConfirmGameScreenState extends State<ConfirmGameScreen> with TickerProviderStateMixin {
  void _onConfirmed() {
    final navigator = Navigator.of(context);
    Widget nextScreen;
    
    // If the user doesn't want to play, the setup is finished. Otherwise, we
    // need a name. If already signed in, we use that, else we offer to sign in
    // and then continue to the game or - if skipped - enter the name manually.
    if (SetupBloc.of(context).role != UserRole.PLAYER || MainBloc.of(context).isSignedIn) {
      nextScreen = SetupFinishedScreen();
    } else {
      nextScreen = SignInScreen(
        onSignedIn: () => navigator.push(SetupRoute(SetupFinishedScreen())),
        onSkipped: () => navigator.push(SetupRoute(EnterNameScreen())),
      );
    }

    navigator.push(SetupRoute(nextScreen));
  }

  @override
  Widget build(BuildContext context) {
    final bloc = SetupBloc.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          SetupAppBar(
            title: bloc.role == UserRole.CREATOR ? 'Create a game' : 'Join a game'
          ),
          SizedBox(height: 24.0),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text("You'll be joining"),
              Text('${bloc.code}'),
              Text('as a'),
              Text(bloc.role.toString())
            ],
          ),
          SizedBox(height: 16.0),
        ],
      ),
      bottomNavigationBar: SetupBottomBar(
        primary: "Join",
        onPrimary: _onConfirmed,
        secondary: 'Cancel',
        onSecondary: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
