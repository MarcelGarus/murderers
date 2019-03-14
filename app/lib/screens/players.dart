import 'package:flutter/material.dart';

import '../bloc/bloc.dart';
import '../widgets/theme.dart';

/// Displays a list of players.
class PlayersScreen extends StatefulWidget {
  PlayersScreen(this.game);
  
  final Game game;

  @override
  _PlayersScreenState createState() => _PlayersScreenState();
}

class _PlayersScreenState extends State<PlayersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _buildList()
      )
    );
  }

  Widget _buildList() {
    final players = List.from(widget.game.players);
    players.sort((a, b) {
      if (a.rank == null) return 1;
      if (b.rank == null) return -1;
      return a.rank.compareTo(b.rank);
    });

    return ListView.builder(
      itemBuilder: (BuildContext context, int i) {
        if (i == 0) {
          return _buildHeader();
        }
        i--;
        if (i >= players.length) return null;
        final player = players[i];
        return _buildPlayer(player, widget.game.me == player);
      },
    );
  }

  Widget _buildHeader() {
    return Placeholder(fallbackHeight: 200);
  }

  Widget _buildPlayer(Player player, bool isMe) {
    final theme = MyTheme.of(context);
    final style = theme.headerText.copyWith(fontSize: 20, color: kAccentColor);

    return Container(
      color: player.isDead ? Color(0xFFDDDDDD) : Colors.white,
      child: ListTile(
        leading: Material(
          shape: CircleBorder(),
          color: isMe ? kAccentColor : Colors.transparent,
          child: Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            child: Text(player.rank == null ? '?' : '#${player.rank}',
              style: style.copyWith(color: isMe ? Colors.white : kAccentColor),
            ),
          ),
        ),
        title: Text(player.name, style: style.copyWith(color: Colors.black)),
        trailing: Text('${player.kills}', style: style),
        onTap: () {},
      ),
    );
  }
}
