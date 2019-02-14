import 'dart:async';

import 'package:flutter/material.dart';

import '../bloc/bloc.dart';
import '../widgets/button.dart';
import '../widgets/game_scaffold.dart';
import '../widgets/victim_name.dart';
import '../widgets/theme.dart';
import 'players.dart';

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  Widget build(BuildContext context) {
    print('Building the game screen');
    return StreamBuilder(
      stream: Bloc.of(context).currentGameStream,
      builder: (BuildContext context, AsyncSnapshot<Game> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final game = snapshot.data;
        return MyTheme(
          data: getThemeData(game),
          child: GameScaffold(
            main: Stack(
              children: [
                GradientBackground(),
                SafeArea(
                  child: game.state == GameState.notStartedYet
                    ? PreparationContent(game: game)
                    : ActiveContent(game: game)
                ),
              ],
            ),
            bar: Material(
              elevation: 6,
              child: Container(color: Colors.yellow, height: 72)
            ),
            players: Placeholder(color: Colors.green),
          ),
        );
      }
    );
  }

  MyThemeData getThemeData(Game game) {
    final theme = MyTheme.of(context);

    if (!(game.me?.isAlive ?? true)) {
      // The player is dead.
      return theme.copyWith(
        backgroundColor: Colors.black,
        backgroundGradientColor: Colors.deepPurple,
        textColor: Colors.white,
        buttonColor: Colors.black,
        primaryButtonTextColor: Colors.black,
      );
    } else if (game.state == GameState.running) {
      // The game is running.
      return theme.copyWith(
        backgroundColor: Colors.red,
      );
    } else {
      // The game is currently not running.
      return theme.copyWith(
        backgroundColor: Colors.white,
        backgroundGradientColor: Color.lerp(Colors.white, Colors.pink, 0.1),
        textColor: Colors.black,
        buttonColor: Colors.red,
        primaryButtonTextColor: Colors.white,
      );
    }
  }
}

class GradientBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            MyTheme.of(context).backgroundColor,
            MyTheme.of(context).backgroundGradientColor,
          ],
          begin: Alignment.bottomCenter,
        )
      ),
    );
  }
}


class PreparationContent extends StatelessWidget {
  PreparationContent({
    @required this.game
  });
  
  final Game game;

  Future<void> _startGame(BuildContext context) {
    return Bloc.of(context).startGame();
  }

  @override
  Widget build(BuildContext context) {
    print('Building the preparation content.');
    final theme = MyTheme.of(context);

    final items = <Widget>[
      Spacer(),
      Text(game.code, textScaleFactor: 3, style: theme.headerText),
      SizedBox(height: 8),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          "Share this code with other people \n to let them join.",
          textAlign: TextAlign.center,
          style: theme.headerText
        ),
      ),
    ];

    if (game.isCreator) {
      items.addAll([
        SizedBox(height: 16),
        Button(
          text: 'Start the game',
          onPressed: () => _startGame(context),
          onSuccess: (result) {
            print(result);
          },
        )
      ]);
    }

    items.addAll([
      Spacer(),
      InkResponse(
        onTap: () {
          print('Showing all the players');
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => PlayersScreen()
          ));
        },
        child: Container(
          height: 48,
          alignment: Alignment.center,
          child: Text('all players'.toUpperCase()),
        ),
      ),
    ]);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: items
      )
    );
  }
}



class ActiveContent extends StatelessWidget {
  ActiveContent({
    @required this.game
  });
  
  final Game game;


  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      Spacer()
    ];

    if (game.victim != null) {
      items.add(VictimName());
      items.add(Button(
        text: 'Victim killed',
        onPressed: () {},
      ));
    }

    items.addAll([
      Spacer(),
      Divider(height: 1.0),
      Statistics(alive: 4, dead: 4, killedByUser: 2)
    ]);

    return Column(children: items);
  }
}


class Statistics extends StatelessWidget {
  Statistics({
    @required this.alive,
    @required this.dead,
    @required this.killedByUser
  });

  final int alive;
  final int dead;
  final int killedByUser;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Spacer(),
        _buildItem(alive, 'alive', () {}),
        Spacer(flex: 2),
        _buildItem(killedByUser, 'killed by you', () {}),
        Spacer(flex: 2),
        _buildItem(dead, 'dead', () {}),
        Spacer(),
      ],
    );
  }

  Widget _buildItem(int number, String text, VoidCallback onTap) {
    return InkResponse(
      highlightShape: BoxShape.rectangle,
      containedInkWell: true,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(height: 16.0),
          Text(number.toString(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.0,
              fontWeight: FontWeight.bold
            ),
          ),
          SizedBox(height: 8.0),
          Text(text, style: TextStyle(color: Colors.white)),
          SizedBox(height: 16.0),
        ],
      )
    );
  }
}

