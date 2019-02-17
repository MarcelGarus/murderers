import 'dart:async';

import 'package:flutter/material.dart';

import '../bloc/bloc.dart';
import '../widgets/button.dart';
import '../widgets/theme.dart';
import '../widgets/victim_name.dart';
import 'kill_warning.dart';
import 'players.dart';

class MainScreen extends StatelessWidget {
  MainScreen(this.game);

  final Game game;

  void _showGames(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (ctx) => GamesSelector()
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: <Widget>[
          Align(
            child: InkWell(
              onTap: () => _showGames(context),
              child: CircleAvatar(
                backgroundImage: NetworkImage(Bloc.of(context).accountPhotoUrl),
                radius: 24,
              ),
            ),
          ),
          SizedBox(width: 8)
        ],
      ),
      body: SafeArea(
        child: (game.state == GameState.notStartedYet)
          ? PreparationContent(game)
          : (game.me.state == PlayerState.dying)
          ? Dying(game)
          : (game.victim?.state == PlayerState.alive)
          ? ActiveContent(game)
          : (game.me.state == PlayerState.dead)
          ? Dead(game)
          : WaitingForVictimsDeath(game)
      ),
    );
  }
}

class GamesSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: Bloc.of(context).allGames.map((game) {
          return ListTile(
            leading: CircleAvatar(child: Text(game.code)),
            title: Text(game.name),
            subtitle: Text(game.code),
            onTap: () {
              Bloc.of(context).currentGame = game;
            },
            trailing: IconButton(
              icon: Icon(Icons.close),
              onPressed: () => Bloc.of(context).removeGame(game),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class PreparationContent extends StatelessWidget {
  PreparationContent(this.game);
  final Game game;

  Future<void> _startGame(BuildContext context) {
    return Bloc.of(context).startGame();
  }

  Future<Game> _joinGame(BuildContext context) {
    return Bloc.of(context).joinGame(code: game.code);
  }

  @override
  Widget build(BuildContext context) {
    print('Building the preparation content.');
    final theme = MyTheme.of(context);

    final items = <Widget>[
      Spacer(),
      Text(game.code, style: theme.headerText),
      SizedBox(height: 8),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          "Share this code with other people\nto let them join.",
          textAlign: TextAlign.center,
          style: theme.bodyText,
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

    if (!game.isPlayer) {
      items.addAll([
        SizedBox(height: 16),
        Button(
          text: 'Join the game',
          onPressed: () => _joinGame(context),
          onSuccess: (game) => print('Joined the game.'),
        ),
      ]);
    }

    items.addAll([
      Spacer(),
      InkResponse(
        onTap: () {
          print('Showing all the players');
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => PlayersScreen(game)
          ));
        },
        child: Container(
          height: 48,
          alignment: Alignment.center,
          child: Text('all players'.toUpperCase()),
        ),
      ),
    ]);

    return Center(child: Column(children: items));
  }
}

class ActiveContent extends StatelessWidget {
  ActiveContent(this.game);
  final Game game;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[ Spacer(flex: 2) ];

    if (game.victim != null) {
      items.addAll([
        VictimName(name: game.victim?.name ?? 'some victim'),
        Button(
          text: 'Victim killed',
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (ctx) => KillWarning(game)
            ));
          },
        ),
        SizedBox(height: 8),
        Button(
          text: 'More actions',
          isRaised: false,
          onPressed: () {},
        ),
      ]);
    }

    items.addAll([
      Spacer(),
      Divider(height: 1),
      Statistics(rank: 2, killedByUser: 2, alive: 5, total: 13),
    ]);

    return Column(children: items);
  }
}

class WaitingForVictimsDeath extends StatelessWidget {
  WaitingForVictimsDeath(this.game);
  final Game game;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: <Widget>[
          Spacer(),
          Text('Waiting for your victim\'s approval.',
            style: MyTheme.of(context).bodyText,
          ),
          Spacer(),
          Statistics(rank: 2, killedByUser: 2, alive: 5, total: 13),
        ]
      )
    );
  }
}

class Dying extends StatelessWidget {
  Dying(this.game);
  final Game game;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: <Widget>[
          Spacer(),
          Text("Did you get killed?",
            style: MyTheme.of(context).headerText,
          ),
          SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Weapon',
            ),
            style: TextStyle(
              fontFamily: 'Signature',
              color: Colors.white,
              fontSize: 32
            ),
            //onChanged: (name) => setState(() => config.gameName = name),
          ),
          SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Last words',
            ),
            style: TextStyle(
              fontFamily: 'Signature',
              color: Colors.white,
              fontSize: 32
            ),
            //onChanged: (name) => setState(() => config.gameName = name),
          ),
          SizedBox(height: 16),
          Row(
            children: <Widget>[
              Spacer(),
              Button(
                text: "I didn't get killed",
                isRaised: false,
                onPressed: () {},
              ),
              SizedBox(width: 8),
              Button(
                text: 'Confirm murder',
                onPressed: () {
                  return Bloc.of(context).confirmDeath(
                    weapon: 'Some weapon',
                    lastWords: 'Last words',
                  );
                },
              ),
            ],
          ),
          Spacer(),
          Statistics(rank: 2, killedByUser: 2, alive: 5, total: 13),
        ]
      )
    );
  }
}

class Dead extends StatelessWidget {
  Dead(this.game);
  final Game game;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("You're dead.", style: MyTheme.of(context).headerText),
    );
  }
}

class Statistics extends StatelessWidget {
  Statistics({
    @required this.rank,
    @required this.killedByUser,
    @required this.alive,
    @required this.total,
  });

  final int rank;
  final int killedByUser;
  final int alive;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Spacer(),
        _buildItem('#$rank', 'rank', () {}),
        Spacer(flex: 2),
        _buildItem('$killedByUser', 'killed by you', () {}),
        Spacer(flex: 2),
        _buildItem('$alive/$total', 'still alive', () {}),
        Spacer(),
      ],
    );
  }

  Widget _buildItem(String number, String text, VoidCallback onTap) {
    return InkResponse(
      highlightShape: BoxShape.rectangle,
      containedInkWell: true,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(height: 16),
          Text(number,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold
            ),
          ),
          SizedBox(height: 8),
          Text(text, style: TextStyle(color: Colors.white)),
          SizedBox(height: 16),
        ],
      )
    );
  }
}
