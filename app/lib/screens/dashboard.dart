import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_villains/villain.dart';

import '../bloc/bloc.dart';
import '../widgets/gradient_background.dart';
import '../widgets/theme.dart';
import 'creator.dart';
import 'dashboard/active.dart';
import 'dashboard/dead.dart';
import 'dashboard/dying.dart';
import 'dashboard/preparation.dart';
import 'dashboard/waiting_for_victims_death.dart';

enum _DashboardContent {
  joining,
  preparation,
  watcher,
  alive,
  dying,
  dead,
  waitingForVictim,
  gameOver,
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
    // Select the right content to display.
    _DashboardContent content;

    switch (game.state) {
      case GameState.notStartedYet:
        content = _DashboardContent.preparation;
        break;
      case GameState.over:
        content =_DashboardContent.gameOver;
        break;
      case GameState.running:
        if (game.me == null) {
          // User is not a player, but a creator or a watcher.
          // TODO: handle this case
          break;
        }
        switch (game.me.state) {
          case PlayerState.joining:
            content = _DashboardContent.joining;
            break;
          case PlayerState.dying:
            content = _DashboardContent.dying;
            break;
          case PlayerState.dead:
            content = _DashboardContent.dead;
            break;
          case PlayerState.alive:
            switch (game.victim?.state) {
              case PlayerState.joining:
              case PlayerState.dead:
                assert(false, "The victim can never be joining or dead.");
                break;
              case PlayerState.alive:
                content = _DashboardContent.alive;
                break;
              case PlayerState.dying:
                content = _DashboardContent.gameOver;
                break;
            }
        }
    }

    assert(content != null);

    // Actually choose a body and a theme to display.
    MyThemeData theme;
    Widget body;

    switch (content) {
      case _DashboardContent.preparation:
        theme = kThemeLight;
        body = PreparationDashboard(game);
        Bloc.of(context).logEvent(AnalyticsEvent.dashboard_not_started_yet);
        break;
      case _DashboardContent.watcher:
      case _DashboardContent.alive:
        theme = kThemeAccent;
        body = ActiveDashboard(game);
        Bloc.of(context).logEvent(AnalyticsEvent.dashboard_active);
        break;
      case _DashboardContent.dying:
        theme = kThemeDark;
        body = DyingDashboard(game);
        Bloc.of(context).logEvent(AnalyticsEvent.dashboard_dying);
        break;
      case _DashboardContent.dead:
        theme = kThemeDark;
        body = DeadDashboard(game);
        Bloc.of(context).logEvent(AnalyticsEvent.dashboard_dead);
        break;
      case _DashboardContent.waitingForVictim:
        theme = kThemeAccent;
        body = WaitingForVictimsDeathDashboard(game);
        Bloc.of(context).logEvent(AnalyticsEvent.dashboard_waiting_for_victim);
        break;
      default:
        print('Unknown content: $content');
    }

    assert(body != null);
    assert(theme != null);

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
                IconButton(
                  icon: Icon(Icons.account_circle),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (ctx) => CreatorScreen(),
                    ));
                  },
                ),
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

  int get _myRank => game.me?.rank;
  int get _killedByMe => game.me?.kills ?? 0;
  int get _alive => game.players.where((p) => p.isAlive).length;
  int get _total => game.players.length;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        _buildItem(
          number: _myRank == null ? '-' : '#$_myRank',
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
