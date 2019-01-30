import 'package:flutter/material.dart';

import '../bloc/bloc.dart';
import 'players.dart';
import '../widgets/primary_button.dart';
import '../widgets/victim_name.dart';

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
        return Scaffold(
          backgroundColor: _getBackgroundColor(game),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            title: GestureDetector(
              onTap: () => Bloc.of(context).removeGame(game),
              child: Text('The Murderer Game',
                style: TextStyle(color: Colors.red)
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
    return Colors.yellow;
    return !(game.me?.isAlive ?? true) ? Colors.black
      : (game.state == GameState.running) ? Colors.red
      : Colors.white;
  }  
}


class PreparationContent extends StatelessWidget {
  PreparationContent({
    @required this.game
  });
  
  final Game game;


  void _startGame(BuildContext context) {
    Bloc.of(context).startGame();
  }

  @override
  Widget build(BuildContext context) {
    print('Building the preparation content.');

    final items = <Widget>[
      Spacer(),
      Text(game.code,
        style: TextStyle(
          color: Colors.black,
          fontFamily: 'Signature',
          fontSize: 92.0,
        )
      ),
      SizedBox(height: 8.0),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(
          "Share this code with other people \n to let them join.",
          style: TextStyle(
            fontFamily: 'Signature'
          ),
          textAlign: TextAlign.center,
        ),
      ),
    ];

    /*if (game.myRole == UserRole.creator) {
      items.addAll([
        SizedBox(height: 16.0),
        MainActionButton(
          onPressed: () => _startGame(context),
          color: Colors.black,
          text: 'Start the game',
          textColor: Colors.white,
        )
      ]);
    }*/

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
          height: 48.0,
          alignment: Alignment.center,
          child: Text('all players'.toUpperCase()),
        ),
      ),
    ]);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
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
      items.add(PrimaryButton(
        color: Colors.white,
        text: 'Victim killed',
        textColor: Colors.red,
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
              fontSize: 24.0,
              fontWeight: FontWeight.bold
            ),
          ),
          SizedBox(height: 8.0),
          Text(text),
          SizedBox(height: 16.0),
        ],
      )
    );
  }
}

