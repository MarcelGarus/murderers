import 'player.dart';
import 'user_role.dart';

/// A game.


enum GameState { NOT_STARTED_YET, RUNNING, PAUSED, OVER }

/// 
class Game {
  static const int CODE_LENGTH = 4;

  Game({
    this.myRole,
    this.code,
    this.name,
    this.state = GameState.NOT_STARTED_YET,
    this.created,
    this.end,
    this.players = const [],
    this.me,
    this.victim,
  });

  UserRole myRole;

  String code;
  String name;
  GameState state;

  DateTime created;
  DateTime end;

  List<Player> players;
  Player me; // May be null if the user is not a player.

  /// This player's victim.
  Player victim;
}
