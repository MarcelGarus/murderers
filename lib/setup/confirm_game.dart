import 'package:flutter/material.dart';
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
    Navigator.of(context).push(SetupRoute(SignInScreen(
      onSignedIn: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => HomeScreen()
        ));
      },
      onSkipped: () {
        Navigator.of(context).push(SetupRoute(EnterNameScreen()));
      },
    )));
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
