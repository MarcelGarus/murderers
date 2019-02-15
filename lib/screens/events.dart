import 'package:flutter/material.dart';

import '../bloc/bloc.dart';

class EventsScreen extends StatefulWidget {
  EventsScreen(this.game);
  
  final Game game;

  @override
  _EventsScreenState createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  @override
  Widget build(BuildContext context) {
    return _buildList();
  }

  Widget _buildList() {
    final players = widget.game.players;

    return ListView.builder(
      itemBuilder: (BuildContext context, int i) {
        return i >= players.length ? null : _buildDeath(players[i]);
      },
    );
  }

  Widget _buildDeath(Player player) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 4,
        child: ListTile(
          leading: CircleAvatar(child: Text(player.id)),
          title: Text(player.name),
          subtitle: Text('Is alive? ${player.isAlive} Deaths: ${player.deaths}'),
          trailing: Text('${player.kills ?? 0}'),
          onTap: () {},
        ),
      ),
    );
  }
}
