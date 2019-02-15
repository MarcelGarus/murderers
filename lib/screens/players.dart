import 'package:flutter/material.dart';

import '../bloc/bloc.dart';

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
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        title: Text('The players',
          style: TextStyle(color: Colors.black)
        ),
      ),
      body: SafeArea(
        child: _buildList()
      )
    );
  }

  Widget _buildList() {
    final players = widget.game.players;

    return ListView.builder(
      itemBuilder: (BuildContext context, int i) {
        return i >= players.length ? null : _buildPlayer(players[i]);
      },
    );
  }

  Widget _buildPlayer(Player player) {
    return Container(
      color: Colors.white,
      child: ListTile(
        leading: CircleAvatar(child: Text(player.id)),
        title: Text(player.name),
        subtitle: Text('Is alive? ${player.isAlive} Deaths: ${player.deaths}'),
        trailing: Text('${player.kills ?? 0}'),
        onTap: () {},
      ),
    );
  }
}
