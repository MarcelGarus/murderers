import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:rxdart/rxdart.dart';

import '../streamed_property.dart';
import 'player.dart';
import 'user_role.dart';

part 'game.g.dart';

enum GameState { notStartedYet, running, paused, over }

/// A game.
@JsonSerializable()
class Game {
  static const int CODE_LENGTH = 4;


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

  /// This player's auth token.
  /// 
  /// May be null if this user is only watching.
  String authToken;

  /// This player's victim.
  /// 
  /// May be null if the user is not a player, the game didn't start yet or the
  /// player is already dead.
  StreamedProperty<Player> _victim;
  ValueObservable<Player> get victimStream => _victim.stream;
  Player get victim => _victim.value;
  set victim(Player player) => _victim.value = player;


  Game({
    @required this.myRole,
    @required this.code,
    @required this.name,
    GameState state = GameState.notStartedYet,
    @required this.created,
    @required this.end,
    List<Player> players = const [],
    this.me,
    this.authToken,
    Player victim,
  }) :
    _state = StreamedProperty(initial: state),
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
