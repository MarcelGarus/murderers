import 'package:flutter/material.dart';

import '../bloc/bloc.dart';
import '../widgets/theme.dart';

/// Stores the player and the rank.
@immutable
class _RankedPlayer {
  _RankedPlayer(this.player, this.rank);

  final Player player;
  final int rank;
}

/// Stores the player as well as the time of death.
@immutable
class _PlayerAndTimeOfDeath {
  _PlayerAndTimeOfDeath({
    @required this.player,
    @required this.time
  });

  final Player player;
  final DateTime time;
}

/// Displays a list of players.
class PlayersScreen extends StatefulWidget {
  PlayersScreen(this.game);
  
  final Game game;

  @override
  _PlayersScreenState createState() => _PlayersScreenState();
}

class _PlayersScreenState extends State<PlayersScreen> {
  /// Method that gets some players and returns a list of ranked players.
  List<_RankedPlayer> rankPlayers(List<Player> players) {
    int rank = 0; // The current rank.

    // Filter players who actually participate in the game.
    players = players.where((p) =>
      p.state != PlayerState.idle && p.state != PlayerState.waiting
    ).toList();

    // First, divide the players into alive and dead ones.
    final alive = players.where((p) => p.isAlive).toList();
    final dead = players.where((p) => !p.isAlive).toList();
    
    // Sort the alive players and give them ranks.
    alive.sort((a, b) => (a.kills ?? 0).compareTo(b.kills ?? 0));
    int lastKills;
    final rankedAlive = alive.map((p) {
      if (lastKills != (p.kills ?? 0)) {
        lastKills = p.kills ?? 0;
        rank++;
      }
      return _RankedPlayer(p, rank);
    });

    // First, map the dead players to a structure containing them and the time
    // of their earliest death. Then sort them according to their times.
    DateTime lastTime;
    final deadPlayersAndTimes = dead.map((p) => _PlayerAndTimeOfDeath(
      player: p,
      time: p.deaths.reduce((a, b) => a.time.isBefore(b.time) ? a : b).time,
    )).toList()..sort();
    final rankedDead =deadPlayersAndTimes.map((p) {
      if (lastTime != p.time) {
        lastTime = p.time;
        rank++;
      }
      return _RankedPlayer(p.player, rank);
    });

    return rankedAlive.followedBy(rankedDead).toList();
  }

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
    final rankedPlayers = rankPlayers(widget.game.players);

    return ListView.builder(
      itemBuilder: (BuildContext context, int i) {
        if (i == 0) {
          return _buildHeader();
        }
        i--;
        if (i >= rankedPlayers.length) return null;
        final player = rankedPlayers[i];
        return _buildPlayer(player.rank, player.player);
      },
    );
  }

  Widget _buildHeader() {
    return Placeholder(fallbackHeight: 200);
  }

  Widget _buildPlayer(int rank, Player player) {
    final theme = MyTheme.of(context);
    final style = theme.headerText.copyWith(fontSize: 20, color: kAccentColor);

    return Container(
      color: Colors.white,
      child: ListTile(
        leading: Container(
          width: 48,
          alignment: Alignment.center,
          child: Text('#$rank', style: style),
        ),
        title: Text(player.name, style: style.copyWith(color: Colors.black)),
        trailing: Text('${player.kills ?? 0}', style: style),
        onTap: () {},
      ),
    );
  }
}
