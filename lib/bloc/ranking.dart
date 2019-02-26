/*List<_RankedPlayer> rankPlayers(List<Player> players) {
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
}*/
