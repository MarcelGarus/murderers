import 'package:rxdart/rxdart.dart';

import '../streamed_property.dart';
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
    GameState state = GameState.NOT_STARTED_YET,
    this.created,
    this.end,
    List<Player> players = const [],
    this.me,
    Player victim,
  }) :
    _state = StreamedProperty(initial: state),
    _players = StreamedProperty(initial: players),
    _victim = StreamedProperty(initial: victim);


  /// This user's role in this game.
  UserRole myRole;

  /// This game's code.
  /// 
  /// Every game can be uniquely identified with its code.
  String code;

  /// This game's name.
  String name;

  /// This game's state.
  StreamedProperty<GameState> _state;
  ValueObservable<GameState> get stateStream => _state.stream;
  GameState get state => _state.value;
  set state(GameState state) => _state.value = state;

  /// The creation timestamp.
  DateTime created;

  /// The estimated end timestamp. May change.
  DateTime end;

  /// All the players.
  StreamedProperty<List<Player>> _players;
  ValueObservable<List<Player>> get playersStream => _players.stream;
  List<Player> get players => _players.value;
  void add(Player player) {
    _players.value = _players.value.followedBy([ player ]).toList();
  }
  void remove(Player player) {
    _players.value = _players.value.where((p) => p != player).toList();
  }

  /// This user as a player.
  /// 
  /// May be null if this user is not a player.
  Player me;

  /// This player's victim.
  /// 
  /// May be null if the user is not a player, the game didn't start yet or the
  /// player is already dead.
  StreamedProperty<Player> _victim;
  ValueObservable<Player> get victimStream => _victim.stream;
  Player get victim => _victim.value;
  set victim(Player player) => _victim.value = player;


  /// Disposes all streamed properties.
  void dispose() {
    _state.dispose();
    _victim.dispose();
  }
}
