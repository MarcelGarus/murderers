import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';

import 'player.dart';

part 'game.g.dart';

enum GameState { notStartedYet, running, over }

GameState intToGameState(int i) {
  switch (i) {
    case 0:
      return GameState.notStartedYet;
    case 1:
      return GameState.running;
    case 2:
      return GameState.over;
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
  final String code;
  final String name;
  final GameState state;
  final DateTime created;
  final DateTime end;
  final List<Player> players;
  final Player me; // This user's player. May be [null].
  final Player murderer; // This player's murderer. May be [null].
  final Player victim; // This player's victim. May be [null].
  final bool wantsNewVictim; // Whether this player wants a new victim.

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
    this.wantsNewVictim,
  })  : assert(isCreator != null),
        assert(code != null),
        assert(name != null),
        assert(state != null),
        assert(created != null),
        assert(created != null),
        assert(end != null),
        assert(players != null);

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
      wantsNewVictim: wasOutsmarted ?? this.wantsNewVictim,
    );
  }

  String toString() {
    return 'Game $code with state $state and ' +
        (players.isEmpty ? 'no players.' : 'players ${players.join(', ')}.');
  }
}
