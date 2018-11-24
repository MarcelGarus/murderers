import 'package:flutter/material.dart';

import '../bloc/bloc.dart';

class PlayersScreen extends StatefulWidget {
  @override
  _PlayersScreenState createState() => _PlayersScreenState();
}

class _PlayersScreenState extends State<PlayersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Text('Some players',
          style: TextStyle(color: Colors.black)
        ),
      ),
      body: SafeArea(
        child: _buildList()
      )
    );
  }

  Widget _buildList() {
    return StreamBuilder(
      stream: Bloc.of(context).activeGameStream,
      builder: (BuildContext context, AsyncSnapshot<Game> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final game = snapshot.data;

        return StreamBuilder(
          stream: game.playersStream,
          builder: (BuildContext context, AsyncSnapshot<List<Player>> snapshot) {
            if (!snapshot.hasData) {
              return Center(child: LinearProgressIndicator());
            }

            final players = snapshot.data;

            return ListView.builder(
              itemBuilder: (BuildContext context, int i) {
                return i >= players.length ? null : _buildItem(players[i]);
              },
            );
          },
        );
      }
    );
  }

  Widget _buildItem(Player player) {
    return ListTile(
      title: Text(player.id),
      subtitle: Text('aka ${player.name}'),
    );
  }
}
