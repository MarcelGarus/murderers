import 'package:flutter/material.dart';

import '../bloc/bloc.dart';
import '../widgets/theme.dart';

class CreatorScreen extends StatelessWidget {
  void _acceptPlayers(BuildContext context, List<Player> players) {
    Bloc.of(context).acceptPlayers(players: players);
  }

  void _denyPlayers(BuildContext context, List<Player> players) {
    //Bloc.of(context).denyPlayers(players: players);
    // TODO: implement
  }

  @override
  Widget build(BuildContext context) {
    final game = Bloc.of(context).currentGame;
    final joiningPlayers =
        game.players.where((p) => p.state == PlayerState.joining).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _AcceptPlayersCard(
            players: joiningPlayers.followedBy([
              Player(state: PlayerState.alive, name: 'Test player', id: '_'),
            ]).toList(),
            onAccept: (p) => _acceptPlayers(context, p),
            onDeny: (p) => _denyPlayers(context, p),
          ),
        ],
      ),
    );
  }
}

class _AcceptPlayersCard extends StatelessWidget {
  _AcceptPlayersCard({
    @required this.players,
    @required this.onAccept,
    @required this.onDeny,
  });

  final List<Player> players;
  final void Function(List<Player> players) onAccept;
  final void Function(List<Player> players) onDeny;

  @override
  Widget build(BuildContext context) {
    var theme = MyTheme.of(context);

    return _CreatorFeedCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'These players want to join the game.',
              style: theme.headerText.copyWith(color: Colors.black),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Swipe left or right to accept or deny them.',
              style: theme.bodyText,
            ),
          ),
        ].followedBy(players.map((player) {
          return Dismissible(
            key: Key(player.id),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 16),
              child: Icon(Icons.close, color: Colors.white),
            ),
            secondaryBackground: Container(
              color: Colors.green,
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 16),
              child: Icon(Icons.done, color: Colors.white),
            ),
            child: Container(
              color: Colors.white,
              child: ListTile(title: Text(player.name)),
            ),
            onDismissed: (direction) {
              if (direction == DismissDirection.endToStart) {
                onAccept([player]);
              } else {
                onDeny([player]);
              }
            },
          );
        })).followedBy([
          SizedBox(height: 16),
        ]).toList(),
      ),
    );
  }
}

class _CreatorFeedCard extends StatelessWidget {
  _CreatorFeedCard({
    @required this.child,
  });

  final child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black26),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        borderRadius: BorderRadius.circular(16),
        elevation: 0,
        child: child,
        color: Colors.white,
      ),
    );
  }
}
