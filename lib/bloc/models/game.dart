import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:rxdart/rxdart.dart';

import '../streamed_property.dart';
import 'player.dart';
import 'user_role.dart';

part 'game.g.dart';

enum GameState {
  notStartedYet,
  running,
  paused,
  over
}

GameState intToGameState(int i) {
  switch (i) {
    case 0: return GameState.notStartedYet;
    case 1: return GameState.running;
    case 2: return GameState.paused;
    case 3: return GameState.over;
    default:
      print("Error: Unknown player state $i.");
      throw ArgumentError();
  }
}

/// A game.
@JsonSerializable()
class Game {
  static const int CODE_LENGTH = 4;


  /// Whether this user is the creator.
  bool isCreator;

  /// This game's code.
  String code;

  /// This game's name.
  StreamedProperty<String> _name;
  ValueObservable<String> get nameStream => _name.stream;
  String get name => _name.value;
  set name(String name) => _name.value = name;

  /// This game's state.
  StreamedProperty<GameState> _state;
  ValueObservable<GameState> get stateStream => _state.stream;
  GameState get state => _state.value;
  set state(GameState state) => _state.value = state;

  /// The creation timestamp.
  DateTime created;

  /// The estimated start timestamp. May change.
  StreamedProperty<DateTime> _start;
  ValueObservable<DateTime> get startStream => _start.stream;
  DateTime get start => _start.value;
  set start(DateTime start) => _start.value = start;

  /// The estimated end timestamp. May change.
  StreamedProperty<DateTime> _end;
  ValueObservable<DateTime> get endStream => _end.stream;
  DateTime get end => _end.value;
  set end(DateTime end) => _end.value = end;

  /// All the players.
  StreamedProperty<List<Player>> _players;
  ValueObservable<List<Player>> get playersStream => _players.stream;
  List<Player> get players => _players.value;
  set players(List<Player> players) => _players.value = players;

  /// This user as a player.
  /// 
  /// May be null if this user is not a player.
  Player me;

  Player murderer;

  /// This player's victim.
  /// 
  /// May be null if the user is not a player, the game didn't start yet or the
  /// player is already dead.
  StreamedProperty<Player> _victim;
  ValueObservable<Player> get victimStream => _victim.stream;
  Player get victim => _victim.value;
  set victim(Player player) => _victim.value = player;

  bool wasOutsmarted;


  Game({
    @required this.isCreator,
    @required this.code,
    @required String name,
    GameState state = GameState.notStartedYet,
    @required this.created,
    @required DateTime start,
    @required DateTime end,
    List<Player> players = const [],
    this.me,
    this.murderer,
    Player victim,
    bool wasOutsmarted,
  }) :
    _name = StreamedProperty(initial: name),
    _state = StreamedProperty(initial: state),
    _start = StreamedProperty(initial: start),
    _end = StreamedProperty(initial: end),
    _players = StreamedProperty(initial: players),
    _victim = StreamedProperty(initial: victim);

  factory Game.fromJson(Map<String, dynamic> json) => _$GameFromJson(json);
  Map<String, dynamic> toJson() => _$GameToJson(this);

  /// Disposes all streamed properties.
  void dispose() {
    _state.dispose();
    _victim.dispose();
  }
}
