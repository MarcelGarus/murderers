import 'package:flutter/material.dart';
import '../bloc.dart';
import '../game.dart';
import '../home.dart';
import 'enter_name.dart';
import 'setup_utils.dart';
import 'sign_in.dart';

class ConfirmGameScreen extends StatefulWidget {
  ConfirmGameScreen({
    @required this.role,
    @required this.code,
  });

  final UserRole role;
  final String code;

  @override
  _ConfirmGameScreenState createState() => _ConfirmGameScreenState();
}

class _ConfirmGameScreenState extends State<ConfirmGameScreen> with TickerProviderStateMixin {
  void _onJoin() {
    final navigator = Navigator.of(context);
    Widget nextScreen = (Bloc.of(context).isSignedIn)
      // If already signed in, we got a name and can directly continue to the
      // game.
      ? HomeScreen()
      // Otherwise, we need a name. Offer the user to sign in, then continue to
      // the game or let the user enter a name manually if sign in is skipped.
      : SignInScreen(
        onSignedIn: () => navigator.push(SetupRoute(HomeScreen())),
        onSkipped: () => navigator.push(SetupRoute(EnterNameScreen())),
      );

    navigator.push(SetupRoute(nextScreen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          SetupAppBar(
            title: widget.role == UserRole.ADMIN ? 'Create a game' : 'Join a game'
          ),
          SizedBox(height: 24.0),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text("You'll be joining"),
              Text('<this game>'),
              Text('as a'),
              Text(widget.role.toString())
            ],
          ),
          SizedBox(height: 16.0),
        ],
      ),
      bottomNavigationBar: SetupBottomBar(
        primary: "Join",
        onPrimary: _onJoin,
        secondary: 'Cancel',
        onSecondary: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
