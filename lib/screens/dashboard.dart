import 'package:flutter/material.dart';

import '../bloc/bloc.dart';
import '../widgets/gradient_background.dart';
import '../widgets/theme.dart';
import 'dashboard/active.dart';
import 'dashboard/dead.dart';
import 'dashboard/dying.dart';
import 'dashboard/preparation.dart';
import 'dashboard/waiting_for_victims_death.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen(this.game) : assert(game != null);

  final Game game;

  void _showGames(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (ctx) => GamesSelector()
    ));
  }

  @override
  Widget build(BuildContext context) {
    MyThemeData theme;
    Widget body;

    // The game didn't start yet.
    if (game.state == GameState.notStartedYet) {
      theme = kThemeLight;
      body = PreparationDashboard(game);
    }

    // TODO: add screen for admin
    // TODO: add screen for watchers

    // The player's dying.
    if (game.me.state == PlayerState.dying) {
      theme = kThemeDark;
      body = DyingDashboard(game);
    }

    // The player is playing and didn't kill the victim yet.
    if (game.victim?.state == PlayerState.alive) {
      theme = kThemeAccent;
      body = ActiveDashboard(game);
    }

    // The player is dead.
    if (game.me.state == PlayerState.dead) {
      theme = kThemeDark;
      body = DeadDashboard(game);
    }

    // The player is waiting for the victim to confirm its death.
    theme = kThemeAccent;
    body = WaitingForVictimsDeathDashboard(game);

    // Now, actually build the content.
    return MyTheme(
      data: theme,
      child: Stack(
        children: <Widget>[
          GradientBackground(),
          Scaffold(
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
                SizedBox(width: 8),
              ],
            ),
            body: SafeArea(
              child: Column(
                children: <Widget>[
                  Expanded(child: body),
                  Statistics(rank: 2, killedByUser: 3, alive: 4, total: 8),
                ],
              ),
            ),
          ),
        ],
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
