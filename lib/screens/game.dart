import 'package:flutter/material.dart';

import '../bloc/bloc.dart';
import '../widgets/active_content.dart';
import '../widgets/preparation_content.dart';

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Bloc.of(context).activeGameStream,
      builder: (BuildContext context, AsyncSnapshot<Game> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final game = snapshot.data;
        return Scaffold(
          backgroundColor: _getBackgroundColor(game),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            title: Text('The Murderer Game',
              style: TextStyle(color: Colors.black)
            ),
          ),
          body: SafeArea(
            child: game.state == GameState.NOT_STARTED_YET
              ? PreparationContent(game: game)
              : ActiveContent(game: game)
          )
        );
      }
    );
  }

  Color _getBackgroundColor(Game game) {
    return (game.state == GameState.NOT_STARTED_YET)
      ? Colors.white
      : !(game.me?.isAlive ?? true)
      ? Colors.black
      : (game.state == GameState.RUNNING)
      ? Colors.red
      : Colors.white;
  }  
}
