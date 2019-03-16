import 'package:flutter/material.dart';

import '../bloc/bloc.dart';

class DashboardAppBar extends StatelessWidget {
  void _showGames(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (ctx) => GameSelector()
    ));
  }

  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      actionsIconTheme: IconThemeData(color: Colors.black),
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
      ],
    );
  }
}

class GameSelector extends StatelessWidget {
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
