part of 'network.dart';

/// Parses a game from the body of the server.
Game _parseServerGame({
  @required String body,
  @required String code,
  @required String id
}) {
  assert(body != null);
  assert(code != null);
  assert(id != null);

  final data = json.decode(body);
  final playersData = data['players'] as List;
  final players = <Player>[];
  
  // First, save all players in players.
  for (final player in playersData) {
    players.add(Player(
      id: player['id'],
      name: player['name'],
      state: intToPlayerState(player['state']),
      kills: player['kills'],
    ));
  }

  // Then, evaluate the deaths (which depend on players).
  for (final player in players) {
    final death = playersData.singleWhere((p) => p['id'] == player.id)['death'];
    player.death = death == null ? null : Death(
      time:_parseTime(death['time']),
      murderer: players
        .singleWhere((p) => p.id == death['murderer'], orElse: () => null),
      lastWords: death['lastWords'],
      weapon: death['weapon'],
    );
  }

  // Finally, construct the game.
  final myData = playersData
    .singleWhere((p) => p['id'] == id, orElse: () => null);
  return Game(
    isCreator: (data['creator'] == id),
    code: code,
    name: data['name'],
    state: intToGameState(data['state']),
    created: _parseTime(data['created']),
    end: _parseTime(data['end']),
    players: _ranked(players),
    me: players.singleWhere((p) => p.id == id, orElse: () => null),
    victim: (myData == null) ? null : players
      .singleWhere((p) => p.id == myData['victim'], orElse: () => null),
  );
}

/// Ranks the players.
List<Player> _ranked(List<Player> players) {
  int rank = 0; // The current rank.

  // Filter players who actually participate in the game.
  players = players.where((p) =>
    p.state != PlayerState.idle && p.state != PlayerState.waiting
  ).toList();

  // First, divide the players into alive and dead ones.
  final alive = players.where((p) => p.isAlive).toList();
  final dead = players.where((p) => p.isDead).toList();
  final rest = players.where((p) => !p.isAlive && !p.isDead).toList();
  
  // Sort the alive players according to their kills and give them ranks.
  alive.sort((a, b) => b.kills.compareTo(a.kills));
  int lastKills;
  alive.forEach((player) {
    if (lastKills != player.kills) {
      lastKills = player.kills;
      rank++;
    }
    player.rank = rank;
  });

  // Sort the dead players according to their times of death and give them
  // ranks.
  DateTime lastTime;
  dead.sort((a, b) => (a.death.time.compareTo(b.death.time)));
  dead.forEach((player) {
    if (lastTime != player.death.time) {
      lastTime = player.death.time;
      rank++;
    }
    player.rank = rank;
  });

  return alive.followedBy(dead).followedBy(rest).toList();
}
