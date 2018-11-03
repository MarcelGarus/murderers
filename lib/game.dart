
enum UserRole { PLAYER, WATCHER, ADMIN }

/// A user (can play multiple games, or only watch).
class User {
  String id;
  String name;
}

/// A player in a game (someone who's playing).
class Player {
  User user;
  
  Player victim;
  List<Player> pastVictims;

  Death death;
}

/// A death of a player.
class Death {
  Player murderer;
  String weapon;
  String lastWords;
}

/// A game.
class Game {
  bool isRunning;
  DateTime start;
  DateTime end;

  List<User> admins;
  List<Player> players;
  List<User> watchers;

  Player me;
}
