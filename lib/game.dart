/// The roles the user can take in each game.
enum UserRole { PLAYER, WATCHER, CREATOR }

/// A player.
///
/// The term player refers to all users participating in a game. Players only
/// exist in the context and scope of games - if a user plays in two games, he
/// is represented by two distinct players.
class Player {
  String id;
  String name;
  Death death;
  bool get isAlive => death != null;
}

/// A class that holds some information about how a player died.
class Death {
  Player murderer;
  String weapon;
  String lastWords;
}

/// A game.
enum GameState { NOT_STARTED_YET, RUNNING, PAUSED, OVER }
class Game {
  UserRole myRole;

  String code;
  String name;
  GameState state;

  DateTime start;
  DateTime end;

  List<Player> players;
  Player me;

  /// This player's victim.
  Player victim;
}
