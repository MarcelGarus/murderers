import 'package:flutter/material.dart';

import '../bloc/bloc.dart';
import '../widgets/theme.dart';

class DeathsScreen extends StatefulWidget {
  DeathsScreen(this.game);
  
  final Game game;

  @override
  _DeathsScreenState createState() => _DeathsScreenState();
}

class _DeathsScreenState extends State<DeathsScreen> {
  Game _lastGame;
  List<Player> _deadPlayers;

  @override
  Widget build(BuildContext context) {
    if (widget.game != _lastGame) {
      _lastGame = widget.game;
      _deadPlayers = _lastGame.players.where((player) => !player.isAlive).toList();
    }

    return Container(
      color: kThemeDark.backgroundColor,
      child: SafeArea(
        child: ListView.builder(
          itemBuilder: (BuildContext context, int i) {
            if (i == 0) {
              return _buildHeader();
            }
            i--;
            return i >= _deadPlayers.length ? null : _buildDeath(_deadPlayers[i]);
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(height: 200, child: Placeholder(color: Colors.green)),
        Text('Recent deaths'),
      ],
    );
  }

  Widget _buildDeath(Player player) {
    final death = player.death;
    final theme = MyTheme.of(context);
    assert(death != null);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('"${death.lastWords}"',
                style: theme.headerText.copyWith(fontSize: 20),
              ),
              SizedBox(height: 8),
              Text('${player.name}, murdered with a ${death.weapon}'),
            ],
          ),
        ),
      ),
    );
  }
}
