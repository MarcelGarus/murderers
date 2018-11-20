import 'package:flutter/material.dart';

import '../bloc/bloc.dart';
import '../widgets/active_content.dart';
import '../widgets/preparation_content.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Bloc.of(context).game,
      builder: (BuildContext context, AsyncSnapshot<Game> snapshot) {
        if (!snapshot.hasData) {
          print('No data to display.');
          return Container();
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
