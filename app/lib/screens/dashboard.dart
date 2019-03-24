import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_villains/villain.dart';

import '../bloc/bloc.dart';
import '../widgets/app_bar.dart';
import '../widgets/gradient_background.dart';
import '../widgets/statistics.dart';
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
                content = _DashboardContent.waitingForVictim;
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
            body: CustomScrollView(
              slivers: [
                SliverPersistentHeader(
                  delegate: DashboardSliverDelegate(
                    maxExtent: MediaQuery.of(context).size.height,
                    child: body,
                    bottom: Statistics(
                      goToPlayersCallback: widget.goToPlayersCallback,
                      goToEventsCallback: widget.goToEventsCallback,
                      color: theme.bodyText.color,
                    ),
                    showSwipeUpIndicator: Bloc.of(context).currentGame.isCreator,
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate([
                    CreatorScreen(),
                  ]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardSliverDelegate extends SliverPersistentHeaderDelegate {
  DashboardSliverDelegate({
    @required this.maxExtent,
    @required this.child,
    @required this.bottom,
    @required this.showSwipeUpIndicator,
  });

  final double maxExtent;
  final Widget child;
  final Widget bottom;
  final bool showSwipeUpIndicator;

  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    var items = <Widget>[
      MyAppBar(),
      Expanded(child: child),
      bottom,
    ];

    if (showSwipeUpIndicator) {
      items.add(Text(
        'Scroll down to see creator actions which are only visible to you.',
        style: MyTheme.of(context).bodyText,
        textAlign: TextAlign.center,
      ));
    }

    return Column(children: items);
  }

  double get minExtent => 0;

  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true; // TODO: optimize
}
