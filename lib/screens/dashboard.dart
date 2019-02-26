import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_villains/villain.dart';

import '../bloc/bloc.dart';
import '../widgets/gradient_background.dart';
import '../widgets/theme.dart';
import 'dashboard/active.dart';
import 'dashboard/dead.dart';
import 'dashboard/dying.dart';
import 'dashboard/preparation.dart';
import 'dashboard/waiting_for_victims_death.dart';

enum _DashboardContent {
  preparation,
  admin,
  watcher,
  active,
  dying,
  dead,
  waitingForVictim,
}

class DashboardScreen extends StatefulWidget {
  DashboardScreen(
    this.game, {
    this.goToPlayersCallback,
    this.goToEventsCallback,
  }) : assert(game != null);

  final Game game;
  final VoidCallback goToPlayersCallback;
  final VoidCallback goToEventsCallback;

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Game get game => widget.game;

  _DashboardContent _lastContent;

  void _showGames(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (ctx) => GamesSelector()
    ));
  }

  @override
  Widget build(BuildContext context) {
    _DashboardContent content;

    // Select the right content to display.
    if (game.state == GameState.notStartedYet) {
      content = _DashboardContent.preparation;
    } else if (game.me?.state == PlayerState.dying) {
      content = _DashboardContent.dying;
    } else if (game.victim?.state == PlayerState.alive) {
      content = _DashboardContent.active;
    } else if (game.me?.state == PlayerState.dead) {
      content =_DashboardContent.dead;
    } else {
      content =_DashboardContent.waitingForVictim;
    }

    // Actually choose a body and a theme to display.
    MyThemeData theme;
    Widget body;

    switch (content) {
      case _DashboardContent.preparation:
        theme = kThemeLight;
        body = PreparationDashboard(game);
        break;
      case _DashboardContent.admin:
      case _DashboardContent.watcher:
      case _DashboardContent.active:
        theme = kThemeAccent;
        body = ActiveDashboard(game);
        break;
      case _DashboardContent.dying:
        theme = kThemeDark;
        body = DyingDashboard(game);
        break;
      case _DashboardContent.dead:
        theme = kThemeDark;
        body = DeadDashboard(game);
        break;
      case _DashboardContent.waitingForVictim:
        theme = kThemeAccent;
        body = WaitingForVictimsDeathDashboard(game);
        break;
      default:
        print('Unknown content: $content');
    }

    // If the content changed since the last frame, animate all villains.
    if (content != _lastContent) {
      _lastContent = content;
      Future.delayed(Duration.zero, () {
        VillainController.playAllVillains(context);
      });
    }

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
                  Statistics(
                    game: widget.game,
                    goToPlayersCallback: widget.goToPlayersCallback,
                    goToEventsCallback: widget.goToEventsCallback,
                  ),
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
    @required this.game,
    this.goToPlayersCallback,
    this.goToEventsCallback,
  }) : assert(game != null);

  final Game game;
  final VoidCallback goToPlayersCallback;
  final VoidCallback goToEventsCallback;

  int get _killedByMe => game.me?.kills ?? 0;
  int get _alive => game.players.where((p) => p.isAlive).length;
  int get _total => game.players.length;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        _buildItem(
          number: '#2',
          text: 'rank',
          onTap: goToPlayersCallback,
        ),
        _buildItem(
          number: '$_killedByMe',
          text: 'killed by you',
        ),
        _buildItem(
          number: '$_alive/$_total',
          text: 'still alive',
          onTap: goToEventsCallback,
        ),
      ],
    );
  }

  Widget _buildItem({ String number, String text, VoidCallback onTap }) {
    return Expanded(
      child: InkResponse(
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
      ),
    );
  }
}
