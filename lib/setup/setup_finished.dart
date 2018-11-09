import 'package:flutter/material.dart';
import '../bloc.dart';
import '../game.dart';
import '../game/game.dart';
import 'setup_bloc.dart';

class SetupFinishedScreen extends StatefulWidget {
  @override
  _SetupFinishedScreenState createState() => _SetupFinishedScreenState();
}

class _SetupFinishedScreenState extends State<SetupFinishedScreen> with TickerProviderStateMixin {

  @override
  void initState() {
    super.initState();

    final bloc = SetupBloc.of(context);
    final name = bloc.name;

    if (bloc.role == UserRole.CREATOR) {
      print('Creating a game for user $name.');
      bloc.createGame().then(_finished);
    } else {
      print('$name joins game ${bloc.code}.');
      bloc.joinGame(bloc.code).then(_finished);
    }
  }

  void _finished(GameSetupResult result) {
    if (result == GameSetupResult.SUCCESS) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => HomeScreen(),
      ));
    } else {
      print('Game couldnt be created.');
      // TODO: display appropriate error and offer to retry
    }
  }

  @override
  Widget build(BuildContext context) {
    String text = (SetupBloc.of(context).role == UserRole.CREATOR)
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
