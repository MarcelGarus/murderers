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
    final players = widget.game.players;

    return ListView.builder(
      itemBuilder: (BuildContext context, int i) {
        if (i == 0) {
          return _buildHeader();
        }
        i--;
        if (i >= players.length) return null;
        final player = players[i];
        return _buildPlayer(player);
      },
    );
  }

  Widget _buildHeader() {
    return Placeholder(fallbackHeight: 200);
  }

  Widget _buildPlayer(Player player) {
    final theme = MyTheme.of(context);
    final style = theme.headerText.copyWith(fontSize: 20, color: kAccentColor);

    return Container(
      color: Colors.white,
      child: ListTile(
        leading: Container(
          width: 48,
          alignment: Alignment.center,
          child: Text('#${player.rank}', style: style),
        ),
        title: Text(player.name, style: style.copyWith(color: Colors.black)),
        trailing: Text('${player.kills}', style: style),
        onTap: () {},
      ),
    );
  }
}
