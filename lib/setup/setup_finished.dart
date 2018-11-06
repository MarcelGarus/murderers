import 'package:flutter/material.dart';
import '../bloc.dart';
import '../game.dart';
import 'configure_game.dart';
import 'join_game.dart';
import 'setup_utils.dart';
import 'sign_in.dart';

class SetupFinishedScreen extends StatefulWidget {
  SetupFinishedScreen({
    @required this.role,
    @required this.code,
  });
  
  final UserRole role;
  final String code;

  @override
  _SetupFinishedScreenState createState() => _SetupFinishedScreenState();
}

class _SetupFinishedScreenState extends State<SetupFinishedScreen> with TickerProviderStateMixin {

  void initState() {
    super.initState();

    final bloc = Bloc.of(context);
    final name = bloc.name;

    if (widget.code == null) {
      print('Creating a game for user $name.');
      bloc.createGame();
    } else {
      print('$name joins game ${widget.code}.');
      bloc.joinGame(widget.code);
    }
  }

  @override
  Widget build(BuildContext context) {
    String text = (widget.code == null)
      ? "Wait while your game\nis being created."
      : "Wait while you're\njoining the game.";

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CircularProgressIndicator(),
            SizedBox(height: 16.0),
            Text(text, style: TextStyle(fontFamily: 'Signature'), textAlign: TextAlign.center),
          ],
        ),
      )
    );
  }
}
