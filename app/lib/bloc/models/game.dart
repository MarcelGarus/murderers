import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';

import 'player.dart';

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
@immutable
class Game {
  final bool isCreator; // Whether this user is the creator.
  final String code; // This game's code.
  final String name; // This game's name.
  final GameState state; // This game's state.
  final DateTime created; // The creation timestamp.
  final DateTime end; // The estimated end timestamp. May change.
  final List<Player> players; // All the players.
  final Player me; // This player. May be [null].
  final Player murderer; // This player's murderer. May be [null].
  final Player victim; // This player's victim. May be [null].
  final bool wasOutsmarted; // Whether this player's victim outsmarted this player.

  bool get isPlayer => me != null;

  const Game({
    @required this.isCreator,
    @required this.code,
    @required this.name,
    this.state = GameState.notStartedYet,
    @required this.created,
    @required this.end,
    this.players = const [],
    this.me,
    this.murderer,
    this.victim,
    this.wasOutsmarted,
  });

  factory Game.fromJson(Map<String, dynamic> json) => _$GameFromJson(json);
  Map<String, dynamic> toJson() => _$GameToJson(this);

  Game copyWith({
    bool isCreator,
    String code,
    String name,
    GameState state,
    DateTime created,
    DateTime start,
    DateTime end,
    List<Player> players,
    Player me,
    Player murderer,
    Player victim,
    bool wasOutsmarted,
  }) {
    return Game(
      isCreator: isCreator ?? this.isCreator,
      code: code ?? this.code,
      name: name ?? this.name,
      state: state ?? this.state,
      created: created ?? this.created,
      end: end ?? this.end,
      players: players ?? this.players,
      me: me ?? this.me,
      murderer: murderer ?? this.murderer,
      victim: victim ?? this.victim,
      wasOutsmarted: wasOutsmarted ?? this.wasOutsmarted
    );
  }
}
