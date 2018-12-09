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
    print('Building the game screen');
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
            title: GestureDetector(
              onTap: () => Bloc.of(context).removeGame(game),
              child: Text('The Murderer Game',
                style: TextStyle(color: Colors.black)
              )
            ),
          ),
          body: SafeArea(
            child: game.state == GameState.notStartedYet
              ? PreparationContent(game: game)
              : ActiveContent(game: game)
          )
        );
      }
    );
  }

  Color _getBackgroundColor(Game game) {
    return (game.state == GameState.notStartedYet)
      ? Colors.white
      : !(game.me?.isAlive ?? true)
      ? Colors.black
      : (game.state == GameState.running)
      ? Colors.red
      : Colors.white;
  }  
}
