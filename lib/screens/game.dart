import 'package:flutter/material.dart';

import '../bloc/bloc.dart';
import '../widgets/game_scaffold.dart';
import 'events.dart';
import 'dashboard.dart';
import 'players.dart';

class GameScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Bloc.of(context).currentGameStream,
      builder: (BuildContext context, AsyncSnapshot<Game> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final game = snapshot.data;
        return GameScaffold(
          main: DashboardScreen(game),
          left: PlayersScreen(game),
          right: EventsScreen(game),
        );
      }
    );
  }
}
