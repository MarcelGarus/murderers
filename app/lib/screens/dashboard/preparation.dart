import 'dart:async';

import 'package:flutter/material.dart';

import '../../bloc/bloc.dart';
import '../../widgets/button.dart';
import '../../widgets/staggered_column.dart';
import '../../widgets/theme.dart';

class PreparationDashboard extends StatelessWidget {
  PreparationDashboard(this.game);
  final Game game;

  Future<void> _startGame(BuildContext context) {
    return Bloc.of(context).startGame();
  }

  Future<Game> _joinGame(BuildContext context) {
    return Bloc.of(context).joinGame(code: game.code);
  }

  @override
  Widget build(BuildContext context) {
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

    if (!game.isPlayer) {
      items.addAll([
        Text('You can also join the game yourself.', style: theme.bodyText),
        SizedBox(height: 16),
        Button.text('Join the game',
          onPressed: () => _joinGame(context),
          onSuccess: (game) => print('Joined the game.'),
        ),
      ]);
    }

    if (game.isCreator && game.players.length >= 4) { // TODO: don't hardcode
      items.addAll([
        SizedBox(height: 16),
        Button.text('Start the game',
          onPressed: () => _startGame(context),
          onSuccess: (result) {
            print(result);
          },
          onError: (error) {
            // TOOD: handle the error
          },
        ),
      ]);
    }

    items.add(Spacer());

    return StaggeredColumn(children: items);
  }
}
