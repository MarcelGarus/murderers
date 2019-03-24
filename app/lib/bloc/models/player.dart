import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';

import 'death.dart';

part 'player.g.dart';

enum PlayerState {
  joining, // The creator didn't accept the player yet.
  alive, // The player is alive.
  dying, // Someone else killed the player, but he still needs to confirm.
  dead, // The player got killed by someone else.
}

PlayerState intToPlayerState(int i) {
  switch (i) {
    case 0:
      return PlayerState.joining;
    case 1:
      return PlayerState.alive;
    case 2:
      return PlayerState.dying;
    case 3:
      return PlayerState.dead;
    default:
      print("Error: Unknown player state $i.");
      throw ArgumentError();
  }
}

/// A player.
///
/// The term player refers to all users participating in a game. Players only
/// exist in the context and scope of games - if a user plays in two games, he
/// is represented by two distinct players.
@JsonSerializable()
class Player {
  final String id; // A unique id.
  final String name; // A given name.
  final PlayerState state;
  final int kills; // How many other players this player killed.
  int rank; // The player's rank.
  Death death; // The player's deaths.

  bool get isJoining => state == PlayerState.joining;
  bool get isAlive => state == PlayerState.alive || state == PlayerState.dying;
  bool get isDead => state == PlayerState.dead;

  Player({
    @required this.id,
    @required this.name,
    @required this.state,
    this.death,
    this.kills = 0,
    this.rank,
  })  : assert(id != null),
        assert(name != null),
        assert(state != null),
        assert(kills != null);

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);
  Map<String, dynamic> toJson() => _$PlayerToJson(this);

  @override
  String toString() => name;
}
